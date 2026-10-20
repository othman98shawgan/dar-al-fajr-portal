import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/quran_metadata_service.dart';
import '../../admin/models/admin_models.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/teacher_models.dart';
import '../repositories/teacher_repository.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepository(
    firestore: ref.watch(firestoreProvider),
    quranService: ref.watch(quranMetadataServiceProvider),
  );
});

/// Streams groups assigned to the currently authenticated teacher.
final teacherGroupsProvider = StreamProvider<List<StudyGroup>>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream<List<StudyGroup>>.value(const []);
  }
  final appUser = ref.watch(currentAppUserProvider).asData?.value;
  final teacherId = appUser?.uid ?? '';
  return ref.watch(teacherRepositoryProvider).watchTeacherGroups(teacherId);
});

/// Currently selected group ID in the Teacher workflow.
class SelectedGroupIdNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setGroupId(String groupId) {
    state = groupId;
  }
}

final selectedGroupIdProvider =
    NotifierProvider<SelectedGroupIdNotifier, String>(
        SelectedGroupIdNotifier.new);

/// Streams enrollments for a given `groupId`.
final groupEnrollmentsProvider =
    StreamProvider.family<List<Enrollment>, String>((ref, groupId) {
  if (Firebase.apps.isEmpty || groupId.isEmpty) {
    return Stream<List<Enrollment>>.value(const []);
  }
  return ref.watch(teacherRepositoryProvider).watchGroupEnrollments(groupId);
});

/// Streams attendance logs for a given `groupId`.
final groupAttendanceProvider =
    StreamProvider.family<List<AttendanceLog>, String>((ref, groupId) {
  if (Firebase.apps.isEmpty || groupId.isEmpty) {
    return Stream<List<AttendanceLog>>.value(const []);
  }
  return ref.watch(teacherRepositoryProvider).watchGroupAttendance(groupId);
});

/// Streams Hifz/Revision assignments for a given `studentId`.
final studentAssignmentsProvider =
    StreamProvider.family<List<HifzAssignment>, String>((ref, studentId) {
  if (Firebase.apps.isEmpty || studentId.isEmpty) {
    return Stream<List<HifzAssignment>>.value(const []);
  }
  return ref.watch(teacherRepositoryProvider).watchStudentAssignments(studentId);
});

/// Streams Hifz/Revision assignments for a given `groupId`.
final groupAssignmentsProvider =
    StreamProvider.family<List<HifzAssignment>, String>((ref, groupId) {
  if (Firebase.apps.isEmpty || groupId.isEmpty) {
    return Stream<List<HifzAssignment>>.value(const []);
  }
  return ref.watch(teacherRepositoryProvider).watchGroupAssignments(groupId);
});

class TeacherController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> logAttendance({
    required String groupId,
    required String studentId,
    required String studentName,
    required AttendanceStatus status,
    SessionMode sessionMode = SessionMode.group,
    DateTime? sessionDate,
    String? notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final teacherId =
          ref.read(currentAppUserProvider).asData?.value?.uid ?? 'teacher-1';
      await ref.read(teacherRepositoryProvider).logAttendance(
            groupId: groupId,
            studentId: studentId,
            studentName: studentName,
            teacherId: teacherId,
            status: status,
            sessionMode: sessionMode,
            sessionDate: sessionDate,
            notes: notes,
          );
    });
    return !state.hasError;
  }

  Future<bool> saveBatchAttendance({
    required String groupId,
    required Map<String, AttendanceStatus> studentStatuses,
    Map<String, String>? studentNames,
    SessionMode sessionMode = SessionMode.group,
    DateTime? sessionDate,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final teacherId =
          ref.read(currentAppUserProvider).asData?.value?.uid ?? 'teacher-1';
      await ref.read(teacherRepositoryProvider).saveBatchAttendance(
            groupId: groupId,
            teacherId: teacherId,
            studentStatuses: studentStatuses,
            studentNames: studentNames,
            sessionMode: sessionMode,
            sessionDate: sessionDate,
          );
    });
    return !state.hasError;
  }

  Future<HifzAssignment?> saveHifzAssignment({
    required String studentId,
    required String studentName,
    required String groupId,
    required AssignmentType type,
    required int surahId,
    required String surahName,
    required int fromAyah,
    required int toAyah,
    required EvaluationGrade grade,
    String teacherNotes = '',
  }) async {
    state = const AsyncLoading();
    HifzAssignment? created;
    state = await AsyncValue.guard(() async {
      final teacherId =
          ref.read(currentAppUserProvider).asData?.value?.uid ?? 'teacher-1';
      created = await ref.read(teacherRepositoryProvider).saveHifzAssignment(
            studentId: studentId,
            studentName: studentName,
            groupId: groupId,
            teacherId: teacherId,
            type: type,
            surahId: surahId,
            surahName: surahName,
            fromAyah: fromAyah,
            toAyah: toAyah,
            grade: grade,
            teacherNotes: teacherNotes,
          );
    });
    return created;
  }
}

final teacherControllerProvider =
    AsyncNotifierProvider<TeacherController, void>(TeacherController.new);
