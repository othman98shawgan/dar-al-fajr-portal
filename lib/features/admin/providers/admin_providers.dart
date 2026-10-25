import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/admin_models.dart';
import '../repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(
    firestore: ref.watch(firestoreProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});

final adminAllUsersProvider = StreamProvider<List<AppUser>>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream<List<AppUser>>.value(const []);
  }
  return ref.watch(adminRepositoryProvider).watchAllUsers();
});

final adminTeachersProvider = StreamProvider<List<AppUser>>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream<List<AppUser>>.value(const []);
  }
  return ref
      .watch(adminRepositoryProvider)
      .watchUsersByRole(UserRole.teacher);
});

final adminParentsProvider = StreamProvider<List<AppUser>>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream<List<AppUser>>.value(const []);
  }
  return ref
      .watch(adminRepositoryProvider)
      .watchUsersByRole(UserRole.parent);
});

final adminStudentsProvider = StreamProvider<List<StudentProfile>>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream<List<StudentProfile>>.value(const []);
  }
  return ref.watch(adminRepositoryProvider).watchStudents();
});

final adminGroupsProvider = StreamProvider<List<StudyGroup>>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream<List<StudyGroup>>.value(const []);
  }
  return ref.watch(adminRepositoryProvider).watchGroups();
});

final adminEnrollmentsProvider = StreamProvider<List<Enrollment>>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream<List<Enrollment>>.value(const []);
  }
  return ref.watch(adminRepositoryProvider).watchEnrollments();
});

/// Selected navigation tab index in the Admin Shell.
class AdminTabNotifier extends Notifier<int> {
  @override
  int build() => 1;

  void setTab(int index) {
    state = index;
  }
}

final adminSelectedTabProvider =
    NotifierProvider<AdminTabNotifier, int>(AdminTabNotifier.new);

/// Selected track filter (`null` means all tracks).
class AdminTrackFilterNotifier extends Notifier<CenterTrack?> {
  @override
  CenterTrack? build() => null;

  void setTrack(CenterTrack? track) {
    state = track;
  }
}

final adminTrackFilterProvider =
    NotifierProvider<AdminTrackFilterNotifier, CenterTrack?>(
        AdminTrackFilterNotifier.new);

class AdminController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<AppUser?> createTeacherOrParent({
    required String email,
    required String temporaryPassword,
    required String fullName,
    required UserRole role,
    String? phoneNumber,
    String preferredLanguage = 'ar',
  }) async {
    state = const AsyncLoading();
    AppUser? created;
    state = await AsyncValue.guard(() async {
      created = await ref.read(adminRepositoryProvider).createProvisionedUser(
            email: email,
            temporaryPassword: temporaryPassword,
            fullName: fullName,
            role: role,
            phoneNumber: phoneNumber,
            preferredLanguage: preferredLanguage,
          );
    });
    return created;
  }

  Future<StudentProfile?> createStudent({
    required String fullName,
    required String parentId,
    String? parentName,
    String? email,
    String? temporaryPassword,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    state = const AsyncLoading();
    StudentProfile? created;
    state = await AsyncValue.guard(() async {
      created = await ref.read(adminRepositoryProvider).createStudent(
            fullName: fullName,
            parentId: parentId,
            parentName: parentName,
            email: email,
            temporaryPassword: temporaryPassword,
            phoneNumber: phoneNumber,
            dateOfBirth: dateOfBirth,
          );
    });
    return created;
  }

  Future<StudyGroup?> createGroup({
    required String name,
    required CenterTrack track,
    required String teacherId,
    String teacherName = '',
    List<String> scheduleDays = const [],
    String startTime = '',
    String endTime = '',
  }) async {
    state = const AsyncLoading();
    StudyGroup? created;
    state = await AsyncValue.guard(() async {
      created = await ref.read(adminRepositoryProvider).createGroup(
            name: name,
            track: track,
            teacherId: teacherId,
            teacherName: teacherName,
            scheduleDays: scheduleDays,
            startTime: startTime,
            endTime: endTime,
          );
    });
    return created;
  }

  Future<Enrollment?> assignStudentToGroup({
    required String studentId,
    required String studentName,
    required String groupId,
    required String groupName,
    required CenterTrack track,
    String? oneOnOneSlotTime,
    String? groupArrivalTime,
  }) async {
    state = const AsyncLoading();
    Enrollment? created;
    state = await AsyncValue.guard(() async {
      created = await ref.read(adminRepositoryProvider).assignStudentToGroup(
            studentId: studentId,
            studentName: studentName,
            groupId: groupId,
            groupName: groupName,
            track: track,
            oneOnOneSlotTime: oneOnOneSlotTime,
            groupArrivalTime: groupArrivalTime,
          );
    });
    return created;
  }
}

final adminControllerProvider =
    AsyncNotifierProvider<AdminController, void>(AdminController.new);
