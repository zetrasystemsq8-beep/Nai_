import 'package:dio/dio.dart';

class AppErrorHandler {
  static String format(dynamic error) {
    if (error is String) return error;

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
