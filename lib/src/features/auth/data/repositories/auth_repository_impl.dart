import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:nai/src/features/auth/domain/entities/user.dart';
import 'package:nai/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;

  AppUser _mapFirebaseUser(fb.User user) {
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  String _mapFirebaseError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Enter a valid email address';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return e.message ?? 'Authentication failed';
    }
  }

  @override
  Stream<AppUser?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapFirebaseUser(user);
    });
  }

  @override
  FutureEither<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        return left(const ServerFailure('Login failed: No user returned'));
      }
      return right(_mapFirebaseUser(credential.user!));
    } on fb.FirebaseAuthException catch (e) {
      return left(ServerFailure(_mapFirebaseError(e)));
    } catch (e) {
      return left(ServerFailure('Login failed: ${e.toString()}'));
    }
  }

  @override
  FutureEither<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        return left(const ServerFailure('Sign up failed: No user returned'));
      }
      await credential.user!.updateDisplayName(name);
      await credential.user!.reload();
      final updatedUser = _firebaseAuth.currentUser!;
      return right(_mapFirebaseUser(updatedUser));
    } on fb.FirebaseAuthException catch (e) {
      return left(ServerFailure(_mapFirebaseError(e)));
    } catch (e) {
      return left(ServerFailure('Sign up failed: ${e.toString()}'));
    }
  }

  @override
  FutureEither<void> forgotPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return right(null);
    } on fb.FirebaseAuthException catch (e) {
      return left(ServerFailure(_mapFirebaseError(e)));
    } catch (e) {
      return left(ServerFailure('Failed to send reset email: ${e.toString()}'));
    }
  }

  @override
  FutureEither<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      return right(null);
    } catch (e) {
      return left(ServerFailure('Logout failed: ${e.toString()}'));
    }
  }

  @override
  FutureEither<AppUser?> checkAuthState() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return right(null);
      return right(_mapFirebaseUser(user));
    } catch (e) {
      return left(ServerFailure('Failed to check auth state: ${e.toString()}'));
    }
  }
}
