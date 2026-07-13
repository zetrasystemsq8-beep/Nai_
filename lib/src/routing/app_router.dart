import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:nai/src/routing/global_navigator.dart';
import 'package:nai/src/routing/app_routes.dart';

import 'package:nai/src/features/splash/presentation/screens/animated_splash_screen.dart';
import 'package:nai/src/features/auth/presentation/screens/login_screen.dart';
import 'package:nai/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:nai/src/features/auth/presentation/screens/forgot_password_screen.dart';

import 'package:nai/src/features/home/presentation/screens/home_page.dart';
import 'package:nai/src/features/onboarding/presentation/screens/onboarding_page.dart';
import 'package:nai/src/features/nigeria/presentation/screens/nigeria_news_screen.dart';
import 'package:nai/src/features/nigeria/presentation/screens/government_services_screen.dart';
import 'package:nai/src/features/nigeria/presentation/screens/wiki_search_screen.dart';
import 'package:nai/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:nai/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:nai/src/features/search/presentation/screens/search_screen.dart';

/// Bridges a Stream (Firebase's authStateChanges) into a Listenable that
/// GoRouter's `refreshListenable` can use to re-evaluate `redirect` whenever
/// auth state changes (login, logout, app restart with existing session).
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

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  refreshListenable: null,
  redirect: (context, state) {
    final isLoggedIn = true;
    final currentPath = state.matchedLocation;

    // Splash always plays uninterrupted, regardless of login state.
    if (currentPath == AppRoutes.splash) {
      return null;
    }

    final isAuthRoute = currentPath == AppRoutes.login ||
        currentPath == AppRoutes.signup ||
        currentPath == AppRoutes.forgotPassword;
    final isOnboarding = currentPath == AppRoutes.onboarding;

    // Logged in, but sitting on an auth screen or onboarding -> go home.
    if (isLoggedIn && (isAuthRoute || isOnboarding)) {
      return AppRoutes.home;
    }

    // Not logged in, trying to reach a protected screen -> send to login.
    // Onboarding itself stays reachable so first-time users still see it.
    if (!isLoggedIn && !isAuthRoute && !isOnboarding) {
      return AppRoutes.login;
    }

    return null; // no redirect needed
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
