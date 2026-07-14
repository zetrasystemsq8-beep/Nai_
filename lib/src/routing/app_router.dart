import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nai/src/features/auth/domain/entities/user.dart';
import 'package:nai/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:nai/src/features/auth/data/repositories/auth_repository_impl.dart';

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(ref.read(authRepositoryProvider));
});

class SessionState {
  final AppUser? user;
  bool get isAuthenticated => user != null;

  SessionState({this.user});
}

class SessionNotifier extends StateNotifier<SessionState> {
  final AuthRepository _repository;

  SessionNotifier(this._repository) : super(SessionState()) {
    // listen to backend auth state
    _repository.onAuthStateChanged.listen((user) {
      state = SessionState(user: user);
    });
  }

  /// Expose auth state changes as a stream for GoRouterRefreshStream
  Stream<AppUser?> get authStateChanges => _repository.onAuthStateChanged;

  Future<void> refreshSession() async {
    final result = await _repository.checkAuthState();
    result.fold(
      (_) => state = SessionState(user: null),
      (user) => state = SessionState(user: user),
    );
  }

  void clearSession() {
    state = SessionState(user: null);
  }
}
