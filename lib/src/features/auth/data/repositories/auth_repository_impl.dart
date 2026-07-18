import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import 'package:nai/src/features/auth/domain/entities/user.dart';
import 'package:nai/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  final _authStateController = StreamController<AppUser?>.broadcast();

  AuthRepositoryImpl() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session == null) {
        _authStateController.add(null);
        return;
      }
      final user = await _fetchAppUser(session.user.id);
      _authStateController.add(user);
    });
  }

  Future<AppUser?> _fetchAppUser(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (profile == null) return null;

      return _mapProfile(profile);
    } catch (e) {
      debugPrint("_fetchAppUser error: $e");
      return null;
    }
  }

  AppUser _mapProfile(Map<String, dynamic> json) {
    return AppUser(
      id: json["id"].toString(),
      email: json["zetramail"] ?? "",
      name: json["full_name"] ?? json["username"],
      photoUrl: json["photo_url"],
      zetraId: json["zetra_id"],
      zetraMail: json["zetramail"],
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
      debugPrint("===== LOGIN (Supabase) =====");
      debugPrint(email);

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return left(ServerFailure("Invalid ZetraMail or password."));
      }

      final appUser = await _fetchAppUser(user.id);
      if (appUser == null) {
        return left(ServerFailure("Could not load your profile. Please try again."));
      }

      _authStateController.add(appUser);
      return right(appUser);
    } on AuthException catch (e) {
      debugPrint("Login AuthException: ${e.message}");
      return left(ServerFailure(e.message));
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
      debugPrint("===== SIGNUP (authenticate existing ZetraMail) =====");
      debugPrint(email);

      // NAI never creates new accounts. Accounts only exist if they were
      // created in the Zetra ID app. "Signing up" here means authenticating
      // against an existing ZetraMail + password — if it's valid, this is
      // effectively a login. If it's invalid, the ZetraMail doesn't exist
      // yet (or the password is wrong) and we tell the user to create it
      // in the Zetra ID app first.
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return left(ServerFailure(
          "No ZetraMail account found. Please create your ZetraMail in the Zetra ID app first.",
        ));
      }

      final appUser = await _fetchAppUser(user.id);
      if (appUser == null) {
        return left(ServerFailure("Could not load your profile. Please try again."));
      }

      _authStateController.add(appUser);
      return right(appUser);
    } on AuthException catch (e) {
      debugPrint("SignUp AuthException: ${e.message}");
      return left(ServerFailure(
        "No ZetraMail account found. Please create your ZetraMail in the Zetra ID app first.",
      ));
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
      debugPrint("===== REQUEST PASSWORD RESET (Supabase) =====");
      debugPrint(email);

      await _supabase.rpc('request_password_reset', params: {
        "p_zetramail": email,
      });

      return right(null);
    } on PostgrestException catch (e) {
      debugPrint("forgotPassword PostgrestException: ${e.message}");
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      debugPrint("===== CONFIRM PASSWORD RESET (Supabase) =====");
      debugPrint(email);

      final result = await _supabase.rpc('confirm_password_reset', params: {
        "p_zetramail": email,
        "p_code": code,
        "p_new_password": newPassword,
      });

      final bool success = result == true;

      if (!success) {
        return left(ServerFailure("Invalid or expired code. Please try again."));
      }

      return right(null);
    } on PostgrestException catch (e) {
      debugPrint("confirmPasswordReset PostgrestException: ${e.message}");
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> logout() async {
    try {
      await _supabase.auth.signOut();
      _authStateController.add(null);
      return right(null);
    } on AuthException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<AppUser?> checkAuthState() async {
    try {
      final session = _supabase.auth.currentSession;

      debugPrint("========== CHECK AUTH (Supabase) ==========");
      debugPrint(session?.user.id ?? "No session");

      if (session == null) {
        return right(null);
      }

      final appUser = await _fetchAppUser(session.user.id);
      return right(appUser);
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
      final session = _supabase.auth.currentSession;
      if (session == null) {
        return left(ServerFailure("You're not signed in. Please log in again."));
      }

      final result = await _supabase.rpc('verify_otp', params: {"p_code": code});

      debugPrint("===== VERIFY RESPONSE (Supabase) =====");
      debugPrint(result.toString());

      final bool success = result == true;

      if (!success) {
        return left(ServerFailure("Invalid or expired code. Please try again."));
      }

      final appUser = await _fetchAppUser(session.user.id);
      if (appUser == null) {
        return left(ServerFailure("Could not load your profile. Please try again."));
      }

      _authStateController.add(appUser);
      return right(appUser);
    } on PostgrestException catch (e) {
      debugPrint("verifyCode PostgrestException: ${e.message}");
      return left(ServerFailure(e.message));
    } catch (e) {
      debugPrint(e.toString());
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> resendCode() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        return left(ServerFailure("You're not signed in. Please log in again."));
      }

      await _supabase.rpc('request_otp');

      debugPrint("===== RESEND CODE (Supabase) =====");

      return right(null);
    } on PostgrestException catch (e) {
      debugPrint("resendCode PostgrestException: ${e.message}");
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
