import 'package:go_router/go_router.dart';
import 'package:nai/src/routing/global_navigator.dart';
import 'package:nai/src/routing/app_routes.dart';

import 'package:nai/src/features/auth/presentation/screens/login_screen.dart';
import 'package:nai/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:nai/src/features/auth/presentation/screens/forgot_password_screen.dart';

import 'package:nai/src/features/home/presentation/screens/home_page.dart';
import 'package:nai/src/features/onboarding/presentation/screens/onboarding_page.dart';
import 'package:nai/src/features/nigeria/presentation/screens/nigeria_news_screen.dart';
import 'package:nai/src/features/nigeria/presentation/screens/government_services_screen.dart';
import 'package:nai/src/features/nigeria/presentation/screens/wiki_search_screen.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.onboarding,
  routes: <RouteBase>[
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
  ],
);
