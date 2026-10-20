import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/screens/admin_shell_screen.dart';
import '../../features/auth/models/app_user.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/screens/first_login_setup_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/home_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String login = '/login';
  static const String firstLoginSetup = '/first-login-setup';
  static const String admin = '/admin';
  static const String teacher = '/teacher';
  static const String parentStudent = '/parent-student';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final appUserState = ref.watch(currentAppUserProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (BuildContext context, GoRouterState state) {
      // If Firebase is not initialized (e.g. in unit/smoke tests without Firebase),
      // do not block navigation.
      if (Firebase.apps.isEmpty) {
        return null;
      }

      final isAuthLoading = authState.isLoading;
      if (isAuthLoading) {
        return null;
      }

      final firebaseUser = authState.asData?.value;
      final currentPath = state.matchedLocation;
      final isOnLogin = currentPath == AppRoutes.login;
      final isOnFirstLoginSetup = currentPath == AppRoutes.firstLoginSetup;

      // 1. Unauthenticated users must go to LoginScreen
      if (firebaseUser == null) {
        return isOnLogin ? null : AppRoutes.login;
      }

      // Wait for Firestore user profile if still loading
      if (appUserState.isLoading) {
        return null;
      }

      final appUser = appUserState.asData?.value;

      // 2. First-Login Setup Gate: force password change & profile completion
      if (appUser != null && appUser.isFirstLogin) {
        return isOnFirstLoginSetup ? null : AppRoutes.firstLoginSetup;
      }

      // 3. Authenticated & setup complete: redirect away from auth screens or root
      if (isOnLogin || isOnFirstLoginSetup || currentPath == AppRoutes.home) {
        if (appUser != null) {
          switch (appUser.role) {
            case UserRole.admin:
              return AppRoutes.admin;
            case UserRole.teacher:
              return AppRoutes.home;
            case UserRole.parent:
            case UserRole.student:
              return AppRoutes.home;
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.firstLoginSetup,
        builder: (BuildContext context, GoRouterState state) {
          return const FirstLoginSetupScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (BuildContext context, GoRouterState state) {
          return const AdminShellScreen();
        },
      ),
    ],
  );
});
