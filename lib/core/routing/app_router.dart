import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../features/account/screens/account_screen.dart';
import '../../features/admin/screens/admin_shell_screen.dart';
import '../../features/auth/models/app_user.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/screens/first_login_setup_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/hifz/screens/attendance_logging_view.dart';
import '../../features/hifz/screens/group_detail_screen.dart';
import '../../features/hifz/screens/teacher_home_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/parent_student/screens/parent_student_home_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String login = '/login';
  static const String firstLoginSetup = '/first-login-setup';
  static const String admin = '/admin';
  static const String teacher = '/teacher';
  static const String teacherGroupDetail = '/teacher/group';
  static const String teacherAttendance = '/teacher/attendance';
  static const String parentStudent = '/parent-student';
  static const String account = '/account';
}

/// Listens to authentication state and role changes to notify GoRouter
/// without recreating the entire [GoRouter] instance on simple profile updates
/// (e.g. changing language preference, full name, or phone number).
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<User?>>(
      authStateChangesProvider,
      (previous, next) => notifyListeners(),
    );
    _ref.listen<AsyncValue<AppUser?>>(
      currentAppUserProvider,
      (prev, next) {
        final prevUser = prev?.asData?.value;
        final nextUser = next.asData?.value;
        // Only trigger router re-evaluation if user ID, role, or setup status changes
        if (prevUser?.uid != nextUser?.uid ||
            prevUser?.role != nextUser?.role ||
            prevUser?.isFirstLogin != nextUser?.isFirstLogin) {
          notifyListeners();
        }
      },
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      // If Firebase is not initialized (e.g. in unit/smoke tests without Firebase),
      // do not block navigation.
      if (Firebase.apps.isEmpty) {
        return null;
      }

      final authState = ref.read(authStateChangesProvider);
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
        if (kDebugMode && isOnFirstLoginSetup) {
          return null;
        }
        return isOnLogin ? null : AppRoutes.login;
      }

      // If user profile is still loading from Firestore:
      // Stay on login screen while the button spinner is spinning,
      // and prevent navigation until the role is known.
      final appUserState = ref.read(currentAppUserProvider);
      final appUser = appUserState.asData?.value;
      if (appUserState.isLoading || appUser == null) {
        if (kDebugMode && isOnFirstLoginSetup) {
          return null;
        }
        return isOnLogin ? null : null;
      }

      // 2. First-Login Setup Gate: force password change & profile completion
      if (appUser.isFirstLogin) {
        return isOnFirstLoginSetup ? null : AppRoutes.firstLoginSetup;
      }

      // 3. Authenticated & setup complete: redirect away from auth screens or root
      if (isOnLogin || (isOnFirstLoginSetup && !kDebugMode) || currentPath == AppRoutes.home) {
        switch (appUser.role) {
          case UserRole.admin:
            return AppRoutes.admin;
          case UserRole.teacher:
            return AppRoutes.teacher;
          case UserRole.parent:
          case UserRole.student:
            return AppRoutes.parentStudent;
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
      GoRoute(
        path: AppRoutes.teacher,
        builder: (BuildContext context, GoRouterState state) {
          return const TeacherHomeScreen();
        },
      ),
      GoRoute(
        path: '${AppRoutes.teacherGroupDetail}/:groupId',
        builder: (BuildContext context, GoRouterState state) {
          final groupId = state.pathParameters['groupId'] ?? '';
          return GroupDetailScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.teacherAttendance}/:groupId',
        builder: (BuildContext context, GoRouterState state) {
          final groupId = state.pathParameters['groupId'] ?? '';
          return AttendanceLoggingView(groupId: groupId);
        },
      ),
      GoRoute(
        path: AppRoutes.parentStudent,
        builder: (BuildContext context, GoRouterState state) {
          return const ParentStudentHomeScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.account,
        builder: (BuildContext context, GoRouterState state) {
          return const AccountScreen();
        },
      ),
    ],
  );
});
