import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/quran_metadata_service.dart';
import '../../admin/models/admin_models.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/teacher_models.dart';
import '../repositories/teacher_repository.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepository(
    firestore: ref.watch(firestoreProvider),
    quranService: ref.watch(quranMetadataServiceProvider),
  );
});

/// Streams the Admin-configurable grading penalties & passing thresholds.
final gradingPenaltyConfigProvider =
    StreamProvider<GradingPenaltyConfig>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream<GradingPenaltyConfig>.value(const GradingPenaltyConfig());
  }
  return ref.watch(teacherRepositoryProvider).watchGradingPenaltyConfig();
});

/// Streams groups assigned to the currently authenticated teacher.
final teacherGroupsProvider = StreamProvider<List<StudyGroup>>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream<List<StudyGroup>>.value(const []);
  }
  final appUser = ref.watch(currentAppUserProvider).asData?.value;
  if (appUser?.role == UserRole.admin) {
    return ref.watch(teacherRepositoryProvider).watchAllGroups();
  }
  final teacherId = appUser?.uid ?? '';
  return ref.watch(teacherRepositoryProvider).watchTeacherGroups(teacherId);
});

/// Streams all study groups in the center.
final allGroupsStreamProvider = StreamProvider<List<StudyGroup>>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream<List<StudyGroup>>.value(const []);
  }
  return ref.watch(teacherRepositoryProvider).watchAllGroups();
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

/// Streams a single student's profile.
final studentProfileByIdProvider =
    StreamProvider.family<StudentProfile?, String>((ref, studentId) {
  if (Firebase.apps.isEmpty || studentId.isEmpty) {
    return Stream<StudentProfile?>.value(null);
  }
  return ref.watch(teacherRepositoryProvider).watchStudentProfile(studentId);
});

/// Streams all student profiles indexed by studentId for quick group stats lookup.
final allStudentsMapProvider =
    StreamProvider<Map<String, StudentProfile>>((ref) {
  if (Firebase.apps.isEmpty) {
    return Stream<Map<String, StudentProfile>>.value(const {});
  }
  return ref.watch(teacherRepositoryProvider).watchAllStudents().map(
        (list) => {for (final s in list) s.id: s},
      );
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

/// Streams Weekly Revision Plans for a given `studentId`.
final studentWeeklyPlansProvider =
    StreamProvider.family<List<WeeklyRevisionPlan>, String>((ref, studentId) {
  if (Firebase.apps.isEmpty || studentId.isEmpty) {
    return Stream<List<WeeklyRevisionPlan>>.value(const []);
  }
  return ref
      .watch(teacherRepositoryProvider)
      .watchStudentWeeklyPlans(studentId);
});

/// Streams Weekly Revision Plans for a given `groupId`.
final groupWeeklyPlansProvider =
    StreamProvider.family<List<WeeklyRevisionPlan>, String>((ref, groupId) {
  if (Firebase.apps.isEmpty || groupId.isEmpty) {
    return Stream<List<WeeklyRevisionPlan>>.value(const []);
  }
  return ref.watch(teacherRepositoryProvider).watchGroupWeeklyPlans(groupId);
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
    String? existingAssignmentId,
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
    int? targetPage,
    int? juzNumber,
    int? score,
    int lafziCount = 0,
    int fathCount = 0,
    int tataaCount = 0,
    bool isPartialRead = false,
    bool isJuzExam = false,
    bool forceRepeat = false,
    List<TasmeeRecitationUnit> recitationUnits = const [],
    bool autoCreateNextAssignment = false,
    int? nextSurahId,
    String? nextSurahName,
    int? nextPage,
    int? nextFromAyah,
    int? nextToAyah,
  }) async {
    state = const AsyncLoading();
    HifzAssignment? created;
    state = await AsyncValue.guard(() async {
      final teacherId =
          ref.read(currentAppUserProvider).asData?.value?.uid ?? 'teacher-1';
      created = await ref.read(teacherRepositoryProvider).saveHifzAssignment(
            existingAssignmentId: existingAssignmentId,
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
            targetPage: targetPage,
            juzNumber: juzNumber,
            score: score,
            lafziCount: lafziCount,
            fathCount: fathCount,
            tataaCount: tataaCount,
            isPartialRead: isPartialRead,
            isJuzExam: isJuzExam,
            forceRepeat: forceRepeat,
            recitationUnits: recitationUnits,
            autoCreateNextAssignment: autoCreateNextAssignment,
            nextSurahId: nextSurahId,
            nextSurahName: nextSurahName,
            nextPage: nextPage,
            nextFromAyah: nextFromAyah,
            nextToAyah: nextToAyah,
          );
    });
    return created;
  }

  Future<WeeklyRevisionPlan?> saveWeeklyRevisionPlan({
    String? existingPlanId,
    required String studentId,
    required String studentName,
    required String groupId,
    required DateTime weekStartDate,
    required List<DailyRevisionTask> dailyTasks,
  }) async {
    state = const AsyncLoading();
    WeeklyRevisionPlan? saved;
    state = await AsyncValue.guard(() async {
      final teacherId =
          ref.read(currentAppUserProvider).asData?.value?.uid ?? 'teacher-1';
      saved = await ref.read(teacherRepositoryProvider).saveWeeklyRevisionPlan(
            existingPlanId: existingPlanId,
            studentId: studentId,
            studentName: studentName,
            groupId: groupId,
            teacherId: teacherId,
            weekStartDate: weekStartDate,
            dailyTasks: dailyTasks,
          );
    });
    return saved;
  }

  Future<bool> updateDailyRevisionTaskStatus({
    required WeeklyRevisionPlan plan,
    required int dayIndex,
    required RevisionTaskStatus status,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(teacherRepositoryProvider).updateDailyRevisionTaskStatus(
            plan: plan,
            dayIndex: dayIndex,
            status: status,
          );
    });
    return !state.hasError;
  }

  Future<bool> saveGradingPenaltyConfig(GradingPenaltyConfig config) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(teacherRepositoryProvider)
          .saveGradingPenaltyConfig(config);
    });
    return !state.hasError;
  }

  Future<bool> updateStudentPriorBalance({
    required String studentId,
    required List<int> completedJuz,
    required List<int> completedSurahs,
    required List<int> memorizedPages,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(teacherRepositoryProvider).updateStudentPriorBalance(
            studentId: studentId,
            completedJuz: completedJuz,
            completedSurahs: completedSurahs,
            memorizedPages: memorizedPages,
          );
    });
    return !state.hasError;
  }
}

final teacherControllerProvider =
    AsyncNotifierProvider<TeacherController, void>(TeacherController.new);
