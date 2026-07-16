import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import 'package:nai/src/features/auth/domain/entities/user.dart';
import 'package:nai/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _storage = const FlutterSecureStorage();

  final String baseUrl = "https://zetra-backend.onrender.com/api/auth";

  final _authStateController = StreamController<AppUser?>.broadcast();

  AppUser _mapBackendUser(Map<String, dynamic> json) {
    return AppUser(
      id: json["id"].toString(),
      email: json["email"] ?? "",
      name: json["username"],
      photoUrl: json["photoUrl"],
      zetraId: json["zetra_id"],
      verified: json["verified"] == true,
    );
  }

  @override
  Stream<AppUser?> get onAuthStateChanged => _authStateController.stream;

  @override
  FutureEither<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = "$baseUrl/login";

      debugPrint("===== LOGIN REQUEST =====");
      debugPrint(url);

      final response = await http.post(
        Uri.parse(url),
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "identifier": email,
          "password": password,
        }),
      );

      debugPrint("===== LOGIN RESPONSE =====");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await _storage.write(
          key: "access_token",
          value: data["access_token"],
        );

        await _storage.write(
          key: "refresh_token",
          value: data["refresh_token"],
        );

        await _storage.write(
          key: "user",
          value: jsonEncode(data["user"]),
        );

        debugPrint("Access Token Saved");
        debugPrint(data["access_token"]);

        final user = _mapBackendUser(data["user"]);
        _authStateController.add(user);

        return right(user);
      }

      return left(ServerFailure(response.body));
    } catch (e) {
      debugPrint(e.toString());
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final url = "$baseUrl/register";

      debugPrint("===== SIGNUP REQUEST =====");
      debugPrint(url);

      final response = await http.post(
        Uri.parse(url),
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "username": name,
          "email": email,
          "password": password,
        }),
      );

      debugPrint("===== SIGNUP RESPONSE =====");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final data = jsonDecode(response.body);

        await _storage.write(
          key: "access_token",
          value: data["access_token"],
        );

        await _storage.write(
          key: "refresh_token",
          value: data["refresh_token"],
        );

        await _storage.write(
          key: "user",
          value: jsonEncode(data["user"]),
        );

        debugPrint("Access Token Saved");
        debugPrint(data["access_token"]);

        final user = _mapBackendUser(data["user"]);
        _authStateController.add(user);

        return right(user);
      }

      return left(ServerFailure(response.body));
    } catch (e) {
      debugPrint(e.toString());
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/forgot-password"),
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email,
        }),
      );

      if (response.statusCode == 200) {
        return right(null);
      }

      return left(ServerFailure(response.body));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> logout() async {
    await _storage.deleteAll();
    _authStateController.add(null);
    return right(null);
  }

  @override
  FutureEither<AppUser?> checkAuthState() async {
    try {
      final token = await _storage.read(key: "access_token");

      debugPrint("========== CHECK AUTH ==========");
      debugPrint("Stored Token:");
      debugPrint(token);

      if (token == null || token.isEmpty) {
        debugPrint("No token found.");
        return right(null);
      }

      final response = await http.get(
        Uri.parse("$baseUrl/me"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      debugPrint("===== /me RESPONSE =====");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Headers: ${response.headers}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return right(_mapBackendUser(data));
      }

      return right(null);
    } catch (e) {
      debugPrint("checkAuthState Exception:");
      debugPrint(e.toString());
      return right(null);
    }
  }

  @override
  FutureEither<AppUser> verifyCode({
    required String code,
  }) async {
    try {
      final token = await _storage.read(key: "access_token");
      if (token == null || token.isEmpty) {
        return left(ServerFailure("You're not signed in. Please log in again."));
      }

      final response = await http.post(
        Uri.parse("$baseUrl/verify"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"code": code}),
      );

      debugPrint("===== VERIFY RESPONSE =====");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await _storage.write(key: "user", value: jsonEncode(data));

        final user = _mapBackendUser(data);
        _authStateController.add(user);

        return right(user);
      }

      String message = "Invalid or expired code. Please try again.";
      try {
        final err = jsonDecode(response.body);
        if (err["error"] != null) message = err["error"].toString();
      } catch (_) {}

      return left(ServerFailure(message));
    } catch (e) {
      debugPrint(e.toString());
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> resendCode() async {
    try {
      final token = await _storage.read(key: "access_token");
      if (token == null || token.isEmpty) {
        return left(ServerFailure("You're not signed in. Please log in again."));
      }

      final response = await http.post(
        Uri.parse("$baseUrl/resend-code"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      debugPrint("===== RESEND CODE RESPONSE =====");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        return right(null);
      }

      return left(ServerFailure(response.body));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
