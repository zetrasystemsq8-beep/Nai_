import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

import 'package:nai/src/features/auth/presentation/providers/session_provider.dart';


class SessionListenerWrapper extends ConsumerWidget {
  final Widget child;
  const SessionListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SessionState>(sessionProvider, (prev, next) {
      if (next.status != SessionStatus.unknown) {
        FlutterNativeSplash.remove();
        if (next.status == SessionStatus.authenticated) {
          // Backend JWT token is confirmed valid by AuthRepository.checkAuthState()
          // Only then proceed to home
          context.go(AppRoutes.home);
        } else if (next.status == SessionStatus.unauthenticated) {
          // Backend JWT validation failed, redirect to onboarding
          context.go(AppRoutes.onboarding);
        }
      }
    });

    return child;
  }
}
