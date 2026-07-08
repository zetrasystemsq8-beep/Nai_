import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

class AppErrorHandler {
  static String format(dynamic error) {
    if (error is String) return error;

    // Handle Firebase Auth errors
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password should be at least 6 characters.';
        default:
          return error.message ?? 'Authentication failed.';
      }
    }

    // Handle Dio errors
    if (error is DioException) {
      if (error.response?.data != null) {
        try {
          final data = error.response!.data as Map<String, dynamic>;
          return data['message'] ?? 'Network error occurred.';
        } catch (_) {
          return 'Network error occurred.';
        }
      }
      return 'Network error occurred. Please check your internet.';
    }

    // Fallback
    try {
      if (error.message != null) return error.message.toString();
      if (error.toString() != null) return error.toString();
    } catch (_) {}

    return 'An unexpected error occurred. Please try again.';
  }
}
