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
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: "access_token", value: data["access_token"]);
        await _storage.write(key: "refresh_token", value: data["refresh_token"]);
        await _storage.write(key: "user", value: jsonEncode(data["user"]));
        return right(_mapBackendUser(data["user"]));
      } else {
        return left(ServerFailure("Login failed: ${response.body}"));
      }
    } catch (e) {
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
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": name,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _storage.write(key: "access_token", value: data["access_token"]);
        await _storage.write(key: "refresh_token", value: data["refresh_token"]);
        await _storage.write(key: "user", value: jsonEncode(data["user"]));
        return right(_mapBackendUser(data["user"]));
      } else {
        return left(ServerFailure("Signup failed: ${response.body}"));
      }
    } catch (e) {
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
      if (token == null) return right(null);

      final response = await http.get(
        Uri.parse("$baseUrl/me"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Adjust if backend wraps user in { "user": { ... } }
        final userJson = data is Map && data.containsKey("user") ? data["user"] : data;
        return right(_mapBackendUser(userJson));
      } else {
        return left(ServerFailure("Auth check failed: ${response.body}"));
      }
    } catch (e) {
      return left(ServerFailure("Auth check failed: ${e.toString()}"));
    }
  }
}
