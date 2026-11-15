import 'package:cloud_firestore/cloud_firestore.dart';

import '../../admin/models/admin_models.dart';
import '../../hifz/models/teacher_models.dart';

class ParentStudentRepository {
  static const String studentsCollection = 'students';
  static const String enrollmentsCollection = 'enrollments';
  static const String attendanceCollection = 'attendance_logs';
  static const String assignmentsCollection = 'hifz_assignments';

  final FirebaseFirestore _firestore;

  ParentStudentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Streams students linked to [parentId].
  Stream<List<StudentProfile>> watchChildrenForParent(String parentId) {
    if (parentId.isEmpty) {
      return Stream<List<StudentProfile>>.value(const []);
    }
    return _firestore
        .collection(studentsCollection)
        .snapshots()
        .map((snapshot) {
      final allStudents = snapshot.docs
          .map((doc) => StudentProfile.fromFirestore(doc))
          .toList();
      return allStudents.where((s) => s.parentId == parentId).toList();
    });
  }

  /// Streams the student profile for a logged-in Student user (matching `userId` or `email`).
  Stream<List<StudentProfile>> watchStudentSelf({
    required String userId,
    String? email,
  }) {
    final normalizedEmail = email?.toLowerCase().trim() ?? '';
    if (userId.isEmpty && normalizedEmail.isEmpty) {
      return Stream<List<StudentProfile>>.value(const []);
    }
    return _firestore
        .collection(studentsCollection)
        .snapshots()
        .map((snapshot) {
      final allStudents = snapshot.docs
          .map((doc) => StudentProfile.fromFirestore(doc))
          .toList();

      return allStudents.where((s) {
        if (userId.isNotEmpty && s.userId == userId) return true;
        if (normalizedEmail.isNotEmpty &&
            s.email?.toLowerCase().trim() == normalizedEmail) {
          return true;
        }
        return false;
      }).toList();
    });
  }

  /// Streams all enrollments for a specific [studentId].
  Stream<List<Enrollment>> watchChildEnrollments(String studentId) {
    if (studentId.isEmpty) {
      return Stream<List<Enrollment>>.value(const []);
    }
    return _firestore
        .collection(enrollmentsCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => Enrollment.fromFirestore(doc)).toList(),
        );
  }

  /// Streams attendance logs for a specific [studentId].
  Stream<List<AttendanceLog>> watchChildAttendance(String studentId) {
    if (studentId.isEmpty) {
      return Stream<List<AttendanceLog>>.value(const []);
    }
    return _firestore
        .collection(attendanceCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((doc) => AttendanceLog.fromFirestore(doc)).toList();
      list.sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
      return list;
    });
  }

  /// Streams Hifz/Revision assignments for a specific [studentId].
  Stream<List<HifzAssignment>> watchChildAssignments(String studentId) {
    if (studentId.isEmpty) {
      return Stream<List<HifzAssignment>>.value(const []);
    }
    return _firestore
        .collection(assignmentsCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((doc) => HifzAssignment.fromFirestore(doc)).toList();
      list.sort((a, b) => b.assignedAt.compareTo(a.assignedAt));
      return list;
    });
  }

  /// Records parent/student acknowledgment (توقيع ولي الأمر) on a student's weekly homework.
  Future<void> acknowledgeHomework({
    required String studentId,
    String? assignmentId,
  }) async {
    if (assignmentId != null && assignmentId.isNotEmpty) {
      await _firestore
          .collection(assignmentsCollection)
          .doc(assignmentId)
          .set(
        {
          'parentAcknowledged': true,
          'acknowledgedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
  }
}
