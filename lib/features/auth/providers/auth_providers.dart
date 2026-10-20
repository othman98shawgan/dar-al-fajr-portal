import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

/// Stream of Firebase Auth [User] state changes.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream<User?>.value(null);
  }
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Stream of the authenticated user's Firestore [AppUser] profile document.
final currentAppUserProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final user = authState.asData?.value;
  if (user == null || Firebase.apps.isEmpty) {
    return Stream<AppUser?>.value(null);
  }
  final repository = ref.watch(authRepositoryProvider);
  return repository.watchUserProfile(user.uid);
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final cred = await repo.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user != null) {
        // Ensure user profile document exists in Firestore
        final profile = await repo.getUserProfile(user.uid);
        if (profile == null) {
          final cleanEmail = email.trim().toLowerCase();
          final role = cleanEmail.contains('admin')
              ? UserRole.admin
              : (cleanEmail.contains('teacher')
                  ? UserRole.teacher
                  : UserRole.parent);

          final newProfile = AppUser(
            uid: user.uid,
            email: user.email ?? email.trim(),
            fullName: user.displayName ??
                (cleanEmail.contains('admin')
                    ? 'مدير النظام'
                    : (cleanEmail.contains('teacher')
                        ? 'المعلم'
                        : 'ولي الأمر')),
            role: role,
            isFirstLogin: false,
            preferredLanguage: 'ar',
            createdAt: DateTime.now(),
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(newProfile.toMap(), SetOptions(merge: true));
        }

        // Await currentAppUserProvider so the router transitions directly
        // to the correct role portal with zero intermediate flicker.
        try {
          await ref.read(currentAppUserProvider.future);
        } catch (_) {}
      }
    });
    return !state.hasError;
  }

  Future<bool> completeFirstLoginSetup({
    required String newPassword,
    String? fullName,
    String? phoneNumber,
    String? preferredLanguage,
    DateTime? dateOfBirth,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.completeFirstLoginSetup(
        newPassword: newPassword,
        fullName: fullName,
        phoneNumber: phoneNumber,
        preferredLanguage: preferredLanguage,
        dateOfBirth: dateOfBirth,
      );
    });
    return !state.hasError;
  }

  Future<AppUser?> provisionUserAccount({
    required String email,
    required String temporaryPassword,
    required String fullName,
    required UserRole role,
    String? phoneNumber,
    String preferredLanguage = 'ar',
  }) async {
    state = const AsyncLoading();
    AppUser? createdUser;
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      createdUser = await repo.provisionUserAccount(
        email: email,
        temporaryPassword: temporaryPassword,
        fullName: fullName,
        role: role,
        phoneNumber: phoneNumber,
        preferredLanguage: preferredLanguage,
      );
    });
    return createdUser;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
    });
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
