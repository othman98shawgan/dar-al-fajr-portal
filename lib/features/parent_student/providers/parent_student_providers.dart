import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../admin/models/admin_models.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../hifz/models/teacher_models.dart';
import '../repositories/parent_student_repository.dart';

final parentStudentRepositoryProvider = Provider<ParentStudentRepository>((ref) {
  return ParentStudentRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Currently selected child ID in the Parent Child-Switcher bar.
class SelectedChildIdNotifier extends Notifier<String> {
  @override
  String build() => 'st-1042';

  void selectChild(String childId) {
    state = childId;
  }
}

final selectedChildIdProvider =
    NotifierProvider<SelectedChildIdNotifier, String>(
        SelectedChildIdNotifier.new);

/// Selected bottom navigation tab in ParentStudentHomeScreen:
/// `0` = الجدول والواجبات (Schedule & Homework)
/// `1` = ملخص التقدم (Progress Summary)
class ParentStudentTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }
}

final parentStudentTabProvider =
    NotifierProvider<ParentStudentTabNotifier, int>(
        ParentStudentTabNotifier.new);

/// Tracks which children's weekly homework has been signed/acknowledged by the parent.
class AcknowledgedHomeworkNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const <String>{};

  void markAcknowledged(String childId) {
    state = {...state, childId};
  }
}

final acknowledgedHomeworkProvider =
    NotifierProvider<AcknowledgedHomeworkNotifier, Set<String>>(
        AcknowledgedHomeworkNotifier.new);

/// Streams enrolled children for the currently logged-in Parent (or single profile for a Student).
final parentChildrenStreamProvider = StreamProvider<List<StudentProfile>>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream<List<StudentProfile>>.value(const []);
  }
  final appUser = ref.watch(currentAppUserProvider).asData?.value;
  final repo = ref.watch(parentStudentRepositoryProvider);

  if (appUser?.role == UserRole.student) {
    return repo.watchStudentSelf(
      userId: appUser?.uid ?? '',
      email: appUser?.email,
    );
  }

  return repo.watchChildrenForParent(appUser?.uid ?? '');
});

/// Streams enrollments for a specific child.
final childEnrollmentsStreamProvider =
    StreamProvider.family<List<Enrollment>, String>((ref, studentId) {
  if (Firebase.apps.isEmpty || studentId.isEmpty) {
    return Stream<List<Enrollment>>.value(const []);
  }
  return ref
      .watch(parentStudentRepositoryProvider)
      .watchChildEnrollments(studentId);
});

/// Streams attendance logs for a specific child.
final childAttendanceStreamProvider =
    StreamProvider.family<List<AttendanceLog>, String>((ref, studentId) {
  if (Firebase.apps.isEmpty || studentId.isEmpty) {
    return Stream<List<AttendanceLog>>.value(const []);
  }
  return ref
      .watch(parentStudentRepositoryProvider)
      .watchChildAttendance(studentId);
});

/// Streams Hifz & Revision assignments for a specific child.
final childAssignmentsStreamProvider =
    StreamProvider.family<List<HifzAssignment>, String>((ref, studentId) {
  if (Firebase.apps.isEmpty || studentId.isEmpty) {
    return Stream<List<HifzAssignment>>.value(const []);
  }
  return ref
      .watch(parentStudentRepositoryProvider)
      .watchChildAssignments(studentId);
});
