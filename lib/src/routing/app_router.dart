import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nai/src/routing/global_navigator.dart';
import 'package:nai/src/routing/app_routes.dart';
import 'package:nai/src/features/splash/presentation/screens/animated_splash_screen.dart';
import 'package:nai/src/features/auth/presentation/screens/login_screen.dart';
import 'package:nai/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:nai/src/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:nai/src/features/auth/presentation/screens/verify_code_screen.dart';
import 'package:nai/src/features/home/presentation/screens/home_page.dart';
import 'package:nai/src/features/onboarding/presentation/screens/onboarding_page.dart';
import 'package:nai/src/features/nigeria/presentation/screens/nigeria_news_screen.dart';
import 'package:nai/src/features/nigeria/presentation/screens/government_services_screen.dart';
import 'package:nai/src/features/nigeria/presentation/screens/wiki_search_screen.dart';
import 'package:nai/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:nai/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:nai/src/features/search/presentation/screens/search_screen.dart';
import 'package:nai/src/features/auth/presentation/providers/session_provider.dart';

/// Bridges the session auth stream into a Listenable that GoRouter can refresh on.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final sessionNotifier = ref.read(sessionProvider.notifier);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(
      sessionNotifier.authStateChanges, // 👈 listen to session changes
    ),
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final isLoggedIn = session.isAuthenticated;
      final isUnverified = session.isUnverified;

      final loggingIn = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.forgotPassword;
      final onVerifyScreen = state.matchedLocation == AppRoutes.verifyCode;

      // Splash always plays uninterrupted
      if (state.matchedLocation == AppRoutes.splash) {
        return null;
      }

      // An account exists but hasn't entered its ZetraMail code yet.
      // Pin them to the verify screen no matter what — fresh signup,
      // app relaunch, or coming back from background.
      if (isUnverified) {
        return onVerifyScreen ? null : AppRoutes.verifyCode;
      }

      if (!isLoggedIn && !loggingIn) {
        return AppRoutes.login;
      }
      if (isLoggedIn && (loggingIn || onVerifyScreen)) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => AnimatedSplashScreen(
          onComplete: () => context.go(AppRoutes.onboarding),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyCode,
        name: 'verifyCode',
        builder: (context, state) => const VerifyCodeScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.nigeriaNews,
        name: 'nigeriaNews',
        builder: (context, state) => const NigeriaNewsScreen(),
      ),
      GoRoute(
        path: AppRoutes.governmentServices,
        name: 'governmentServices',
        builder: (context, state) => const GovernmentServicesScreen(),
      ),
      GoRoute(
        path: AppRoutes.wikiSearch,
        name: 'wikiSearch',
        builder: (context, state) => const WikiSearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
    ],
  );
});
