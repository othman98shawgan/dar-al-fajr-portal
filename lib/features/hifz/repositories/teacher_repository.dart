import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/quran_metadata_service.dart';
import '../../admin/models/admin_models.dart';
import '../models/teacher_models.dart';

class TeacherRepository {
  static const String groupsCollection = 'groups';
  static const String enrollmentsCollection = 'enrollments';
  static const String studentsCollection = 'students';
  static const String attendanceCollection = 'attendance_logs';
  static const String assignmentsCollection = 'hifz_assignments';

  final FirebaseFirestore _firestore;
  final QuranMetadataService quranService;

  TeacherRepository({
    FirebaseFirestore? firestore,
    required this.quranService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Teacher Groups & Roster
  // ---------------------------------------------------------------------------

  Stream<List<StudyGroup>> watchTeacherGroups(String teacherId) {
    if (teacherId.trim().isEmpty) {
      return watchAllGroups();
    }
    return _firestore
        .collection(groupsCollection)
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StudyGroup.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<StudyGroup>> watchAllGroups() {
    return _firestore.collection(groupsCollection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => StudyGroup.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<Enrollment>> watchGroupEnrollments(String groupId) {
    return _firestore
        .collection(enrollmentsCollection)
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Enrollment.fromFirestore(doc))
              .toList(),
        );
  }

  // ---------------------------------------------------------------------------
  // Multi-Mode Attendance Logging (Group & 1-on-1)
  // ---------------------------------------------------------------------------

  Stream<List<AttendanceLog>> watchGroupAttendance(String groupId) {
    return _firestore
        .collection(attendanceCollection)
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceLog.fromFirestore(doc))
              .toList(),
        );
  }

  Future<AttendanceLog> logAttendance({
    required String groupId,
    required String studentId,
    required String studentName,
    required String teacherId,
    required AttendanceStatus status,
    SessionMode sessionMode = SessionMode.group,
    DateTime? sessionDate,
    String? notes,
  }) async {
    final docRef = _firestore.collection(attendanceCollection).doc();
    final log = AttendanceLog(
      id: docRef.id,
      groupId: groupId,
      studentId: studentId,
      studentName: studentName,
      teacherId: teacherId,
      sessionDate: sessionDate ?? DateTime.now(),
      sessionMode: sessionMode,
      status: status,
      notes: notes,
      createdAt: DateTime.now(),
    );

    await docRef.set(log.toMap());
    return log;
  }

  Future<void> saveBatchAttendance({
    required String groupId,
    required String teacherId,
    required Map<String, AttendanceStatus> studentStatuses,
    Map<String, String>? studentNames,
    SessionMode sessionMode = SessionMode.group,
    DateTime? sessionDate,
  }) async {
    final batch = _firestore.batch();
    final now = sessionDate ?? DateTime.now();

    for (final entry in studentStatuses.entries) {
      final docRef = _firestore.collection(attendanceCollection).doc();
      final log = AttendanceLog(
        id: docRef.id,
        groupId: groupId,
        studentId: entry.key,
        studentName: studentNames?[entry.key] ?? '',
        teacherId: teacherId,
        sessionDate: now,
        sessionMode: sessionMode,
        status: entry.value,
        createdAt: now,
      );
      batch.set(docRef, log.toMap());
    }

    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // Hifz & Revision Assignment Engine + Automated Progress Calculation
  // ---------------------------------------------------------------------------

  Stream<List<HifzAssignment>> watchStudentAssignments(String studentId) {
    return _firestore
        .collection(assignmentsCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HifzAssignment.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<HifzAssignment>> watchGroupAssignments(String groupId) {
    return _firestore
        .collection(assignmentsCollection)
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HifzAssignment.fromFirestore(doc))
              .toList(),
        );
  }

  Future<HifzAssignment> saveHifzAssignment({
    required String studentId,
    required String studentName,
    required String groupId,
    required String teacherId,
    required AssignmentType type,
    required int surahId,
    required String surahName,
    required int fromAyah,
    required int toAyah,
    required EvaluationGrade grade,
    String teacherNotes = '',
  }) async {
    if (quranService.surahs.isEmpty) {
      try {
        await quranService.loadMetadata();
      } catch (_) {}
    }

    final pages = quranService.calculatePages(surahId, fromAyah, toAyah);
    final juzList = quranService.calculateJuz(surahId, fromAyah, toAyah);

    final docRef = _firestore.collection(assignmentsCollection).doc();
    final now = DateTime.now();
    final assignment = HifzAssignment(
      id: docRef.id,
      studentId: studentId,
      studentName: studentName.trim(),
      groupId: groupId,
      teacherId: teacherId,
      type: type,
      surahId: surahId,
      surahName: surahName.trim(),
      fromAyah: fromAyah,
      toAyah: toAyah,
      touchedPages: pages,
      touchedJuz: juzList,
      grade: grade,
      teacherNotes: teacherNotes.trim(),
      assignedAt: now,
      evaluatedAt: grade != EvaluationGrade.pending ? now : null,
    );

    await docRef.set(assignment.toMap());

    // Automatically update student's memorized pages & Juz when a New Hifz
    // assignment is passed (Excellent / Good).
    if (type == AssignmentType.newHifz && grade.isPassed) {
      final surah = quranService.getSurahById(surahId);
      final isFullSurahCompleted =
          surah != null && fromAyah <= 1 && toAyah >= surah.totalVerses;

      final studentUpdates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (pages.isNotEmpty) {
        studentUpdates['memorizedPages'] = FieldValue.arrayUnion(pages);
      }
      if (juzList.isNotEmpty) {
        studentUpdates['completedJuz'] = FieldValue.arrayUnion(juzList);
      }
      if (isFullSurahCompleted) {
        studentUpdates['completedSurahs'] = FieldValue.arrayUnion([surahId]);
      }

      await _firestore.collection(studentsCollection).doc(studentId).set(
            studentUpdates,
            SetOptions(merge: true),
          );
    }

    return assignment;
  }
}
