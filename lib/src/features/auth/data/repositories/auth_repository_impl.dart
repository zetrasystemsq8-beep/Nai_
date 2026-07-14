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

  AppUser _mapBackendUser(Map<String, dynamic> json) {
    return AppUser(
      id: json["id"].toString(),
      email: json["email"] ?? "",
      name: json["username"],
      photoUrl: json["photoUrl"],
    );
  }

  @override
  Stream<AppUser?> get onAuthStateChanged async* {
    final result = await checkAuthState();
    yield result.fold((_) => null, (user) => user);
  }

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
          "email": email,
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

        return right(_mapBackendUser(data["user"]));
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

        return right(_mapBackendUser(data["user"]));
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
}
