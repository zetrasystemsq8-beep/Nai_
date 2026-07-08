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
    
    // Handle Dio errors if you're using Dio
    if (error is DioException) {
      // Add Dio error handling here
    }
    
    // Fallback
    try {
      if (error.message != null) return error.message.toString();
      if (error.toString() != null) return error.toString();
    } catch (_) {}
    
    return 'An unexpected error occurred. Please try again.';
  }
}
