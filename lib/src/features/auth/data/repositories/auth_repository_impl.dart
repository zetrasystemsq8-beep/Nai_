import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:nai/src/features/auth/domain/entities/user.dart';
import 'package:nai/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = "https://zetra-backend.onrender.com/api/auth";

  AppUser _mapBackendUser(Map<String, dynamic> json) {
    return AppUser(
      id: json["id"].toString(),
      email: json["email"],
      name: json["username"], // adjust if backend uses different field names
      photoUrl: json["photoUrl"], // adjust if backend uses avatar_url, etc.
    );
  }

  @override
  Stream<AppUser?> get onAuthStateChanged async* {
    final token = await _storage.read(key: "access_token");
    if (token == null) {
      yield null;
    } else {
      final user = await checkAuthState();
      yield user.fold((_) => null, (u) => u);
    }
  }

  @override
  FutureEither<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = "$baseUrl/login";
      final body = {"email": email, "password": password};
      
      debugPrint("===== LOGIN REQUEST =====");
      debugPrint("URL: $url");
      debugPrint("Method: POST");
      debugPrint("Headers: {\"Content-Type\": \"application/json\"}");
      debugPrint("Body: ${jsonEncode(body)}");
      
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("===== LOGIN RESPONSE =====");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Headers: ${response.headers}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: "access_token", value: data["access_token"]);
        await _storage.write(key: "refresh_token", value: data["refresh_token"]);
        await _storage.write(key: "user", value: jsonEncode(data["user"]));
        debugPrint("✅ Login successful, tokens stored");
        return right(_mapBackendUser(data["user"]));
      } else {
        debugPrint("❌ Login failed: ${response.body}");
        return left(ServerFailure("Login failed: ${response.body}"));
      }
    } catch (e) {
      debugPrint("❌ Login exception: ${e.toString()}");
      return left(ServerFailure("Login failed: ${e.toString()}"));
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
      final body = {
        "username": name,
        "email": email,
        "password": password,
      };
      
      debugPrint("===== SIGNUP REQUEST =====");
      debugPrint("URL: $url");
      debugPrint("Method: POST");
      debugPrint("Headers: {\"Content-Type\": \"application/json\"}");
      debugPrint("Body: ${jsonEncode(body)}");
      
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("===== SIGNUP RESPONSE =====");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Headers: ${response.headers}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _storage.write(key: "access_token", value: data["access_token"]);
        await _storage.write(key: "refresh_token", value: data["refresh_token"]);
        await _storage.write(key: "user", value: jsonEncode(data["user"]));
        debugPrint("✅ Signup successful, tokens stored, user: ${data["user"]}");
        return right(_mapBackendUser(data["user"]));
      } else {
        debugPrint("❌ Signup failed: ${response.body}");
        return left(ServerFailure("Signup failed: ${response.body}"));
      }
    } catch (e) {
      debugPrint("❌ Signup exception: ${e.toString()}");
      return left(ServerFailure("Signup failed: ${e.toString()}"));
    }
  }

  @override
  FutureEither<void> forgotPassword({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        return right(null);
      } else {
        return left(ServerFailure("Failed to send reset email: ${response.body}"));
      }
    } catch (e) {
      return left(ServerFailure("Failed to send reset email: ${e.toString()}"));
    }
  }

  @override
  FutureEither<void> logout() async {
    try {
      // Optional: call backend logout if implemented
      // await http.post(Uri.parse("$baseUrl/logout"), headers: {...});

      await _storage.delete(key: "access_token");
      await _storage.delete(key: "refresh_token");
      await _storage.delete(key: "user");
      return right(null);
    } catch (e) {
      return left(ServerFailure("Logout failed: ${e.toString()}"));
    }
  }

  @override
  FutureEither<AppUser?> checkAuthState() async {
    try {
      final token = await _storage.read(key: "access_token");
      if (token == null) {
        debugPrint("❌ checkAuthState: No token found in storage");
        return right(null);
      }

      debugPrint("✅ checkAuthState: Token found, validating with backend");
      final response = await http.get(
        Uri.parse("$baseUrl/me"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("✅ checkAuthState: Backend confirmed JWT valid");
        return right(_mapBackendUser(data));
      } else {
        debugPrint("❌ checkAuthState: Backend rejected token (${response.statusCode})");
        return right(null);
      }
    } catch (e) {
      debugPrint("❌ checkAuthState exception: ${e.toString()}");
      return right(null);
    }
  }
}
