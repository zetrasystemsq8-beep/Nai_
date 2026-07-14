import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import 'package:nai/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:nai/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nai/src/features/auth/presentation/providers/session_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    ref: ref,
    repository: ref.read(authRepositoryProvider),
  );
});

class AuthController extends StateNotifier<bool> {
  final Ref _ref;
  final AuthRepository _repository;

  AuthController({
    required Ref ref,
    required AuthRepository repository,
  })  : _ref = ref,
        _repository = repository,
        super(false);

  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    state = true;

    final result = await _repository.login(
      email: email,
      password: password,
    );

    state = false;

    result.fold(
      (failure) {
        if (context.mounted) {
          showToast(
            context,
            message: failure.message,
            status: 'error',
          );
        }
      },
      (user) async {
        await _ref.read(sessionProvider.notifier).refreshSession();

        if (context.mounted) {
          showToast(
            context,
            message: 'Login successful',
            status: 'success',
          );
        }
      },
    );
  }

  Future<void> signUp({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
  }) async {
    state = true;

    final result = await _repository.signUp(
      name: name,
      email: email,
      password: password,
    );

    state = false;

    result.fold(
      (failure) {
        if (context.mounted) {
          showToast(
            context,
            message: failure.message,
            status: 'error',
          );
        }
      },
      (user) async {
        await _ref.read(sessionProvider.notifier).refreshSession();

        if (context.mounted) {
          showToast(
            context,
            message: 'Signup successful',
            status: 'success',
          );
        }
      },
    );
  }

  Future<void> forgotPassword({
    required BuildContext context,
    required String email,
  }) async {
    state = true;

    final result = await _repository.forgotPassword(email: email);

    state = false;

    result.fold(
      (failure) {
        if (context.mounted) {
          showToast(
            context,
            message: failure.message,
            status: 'error',
          );
        }
      },
      (success) {
        if (context.mounted) {
          showToast(
            context,
            message: 'Password reset link sent successfully',
            status: 'success',
          );
          context.go(AppRoutes.login);
        }
      },
    );
  }
}
