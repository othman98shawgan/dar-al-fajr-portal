import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/models/app_user.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../hifz/models/teacher_models.dart';
import '../models/admin_models.dart';

class DuplicateEnrollmentException implements Exception {
  final String studentId;
  final String groupId;

  const DuplicateEnrollmentException(this.studentId, this.groupId);

  @override
  String toString() =>
      'Student $studentId is already enrolled in group $groupId.';
}

class AdminRepository {
  static const String usersCollection = 'users';
  static const String studentsCollection = 'students';
  static const String groupsCollection = 'groups';
  static const String enrollmentsCollection = 'enrollments';
  static const String attendanceCollection = 'attendance_logs';
  static const String assignmentsCollection = 'hifz_assignments';

  final FirebaseFirestore _firestore;
  final AuthRepository authRepository;

  AdminRepository({
    FirebaseFirestore? firestore,
    required this.authRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Generates the next sequential readable document ID (e.g. `st-1000`, `grp-100`)
  /// by inspecting existing IDs in [collection] matching `<prefix>-<number>`.
  Future<String> _nextSequentialId({
    required String collection,
    required String prefix,
    required int startAt,
  }) async {
    final snapshot = await _firestore.collection(collection).get();
    final pattern = RegExp('^${RegExp.escape(prefix)}-(\\d+)\$');
    var maxNum = startAt - 1;
    for (final doc in snapshot.docs) {
      final match = pattern.firstMatch(doc.id);
      if (match != null) {
        final parsed = int.tryParse(match.group(1)!);
        if (parsed != null && parsed > maxNum) {
          maxNum = parsed;
        }
      }
    }
    return '$prefix-${maxNum + 1}';
  }

  // ---------------------------------------------------------------------------
  // Users & Account Provisioning (Teachers, Parents, Students)
  // ---------------------------------------------------------------------------

  Stream<List<AppUser>> watchAllUsers() {
    return _firestore.collection(usersCollection).snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<AppUser>> watchUsersByRole(UserRole role) {
    return _firestore
        .collection(usersCollection)
        .where('role', isEqualTo: role.toJson())
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList(),
        );
  }

  /// Provisions a Teacher or Parent (or Student with login) account using the
  /// Secondary Firebase App Pattern so the Admin remains signed in.
  Future<AppUser> createProvisionedUser({
    required String email,
    required String temporaryPassword,
    required String fullName,
    required UserRole role,
    String? phoneNumber,
    String preferredLanguage = 'ar',
  }) async {
    return await authRepository.provisionUserAccount(
      email: email,
      temporaryPassword: temporaryPassword,
      fullName: fullName,
      role: role,
      phoneNumber: phoneNumber,
      preferredLanguage: preferredLanguage,
    );
  }

  Future<void> updateUser({
    required String uid,
    required String fullName,
    String? phoneNumber,
    required UserRole role,
  }) async {
    await _firestore.collection(usersCollection).doc(uid).update({
      'fullName': fullName.trim(),
      'phoneNumber': phoneNumber?.trim().isNotEmpty == true ? phoneNumber!.trim() : null,
      'role': role.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection(usersCollection).doc(uid).delete();
  }

  // ---------------------------------------------------------------------------
  // Students Roster Management
  // ---------------------------------------------------------------------------

  Stream<List<StudentProfile>> watchStudents() {
    return _firestore.collection(studentsCollection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => StudentProfile.fromFirestore(doc))
              .toList(),
        );
  }

  Future<StudentProfile> createStudent({
    required String fullName,
    required String parentId,
    String? parentName,
    String? email,
    String? temporaryPassword,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    String? linkedUserId;
    if (email != null &&
        email.trim().isNotEmpty &&
        temporaryPassword != null &&
        temporaryPassword.isNotEmpty) {
      final user = await authRepository.provisionUserAccount(
        email: email.trim(),
        temporaryPassword: temporaryPassword,
        fullName: fullName.trim(),
        role: UserRole.student,
        phoneNumber: phoneNumber,
      );
      linkedUserId = user.uid;
    }

    final nextStudentId = await _nextSequentialId(
      collection: studentsCollection,
      prefix: 'st',
      startAt: 1000,
    );
    final docRef = _firestore.collection(studentsCollection).doc(nextStudentId);
    final student = StudentProfile(
      id: docRef.id,
      fullName: fullName.trim(),
      parentId: parentId,
      parentName: parentName,
      userId: linkedUserId,
      email: email?.trim(),
      phoneNumber: phoneNumber?.trim(),
      dateOfBirth: dateOfBirth,
      createdAt: DateTime.now(),
    );

    await docRef.set(student.toMap());
    return student;
  }

  Future<void> updateStudent({
    required String studentId,
    required String fullName,
    required String parentId,
    String? parentName,
    String? email,
    String? phoneNumber,
  }) async {
    await _firestore.collection(studentsCollection).doc(studentId).update({
      'fullName': fullName.trim(),
      'parentId': parentId,
      'parentName': parentName?.trim(),
      'email': email?.trim().isNotEmpty == true ? email!.trim() : null,
      'phoneNumber': phoneNumber?.trim().isNotEmpty == true ? phoneNumber!.trim() : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteStudent(String studentId) async {
    await _firestore.collection(studentsCollection).doc(studentId).delete();
  }

  // ---------------------------------------------------------------------------
  // Groups Management (4 Center Tracks)
  // ---------------------------------------------------------------------------

  Stream<List<StudyGroup>> watchGroups() {
    return _firestore.collection(groupsCollection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => StudyGroup.fromFirestore(doc))
              .toList(),
        );
  }

  Future<StudyGroup> createGroup({
    required String name,
    required CenterTrack track,
    required String teacherId,
    String teacherName = '',
    List<String> scheduleDays = const [],
    String startTime = '',
    String endTime = '',
    List<GroupScheduleSlot> scheduleSlots = const [],
    int capacity = 15,
  }) async {
    final nextGroupId = await _nextSequentialId(
      collection: groupsCollection,
      prefix: 'grp',
      startAt: 100,
    );
    final docRef = _firestore.collection(groupsCollection).doc(nextGroupId);
    final resolvedSlots = scheduleSlots.isNotEmpty
        ? scheduleSlots
        : scheduleDays
            .map(
              (d) => GroupScheduleSlot(
                day: d,
                startTime: startTime.trim(),
                endTime: endTime.trim(),
              ),
            )
            .toList();
    final resolvedDays = resolvedSlots.isNotEmpty
        ? resolvedSlots.map((s) => s.day).toList()
        : scheduleDays;
    final resolvedStart = startTime.trim().isNotEmpty
        ? startTime.trim()
        : (resolvedSlots.firstOrNull?.startTime ?? '');
    final resolvedEnd = endTime.trim().isNotEmpty
        ? endTime.trim()
        : (resolvedSlots.firstOrNull?.endTime ?? '');

    final group = StudyGroup(
      id: docRef.id,
      name: name.trim(),
      track: track,
      teacherId: teacherId,
      teacherName: teacherName.trim(),
      scheduleDays: resolvedDays,
      startTime: resolvedStart,
      endTime: resolvedEnd,
      scheduleSlots: resolvedSlots,
      capacity: capacity,
      createdAt: DateTime.now(),
    );

    await docRef.set(group.toMap());
    return group;
  }

  Future<void> updateGroup({
    required String groupId,
    required String name,
    required CenterTrack track,
    required String teacherId,
    String teacherName = '',
    List<String> scheduleDays = const [],
    String startTime = '',
    String endTime = '',
    List<GroupScheduleSlot> scheduleSlots = const [],
    int capacity = 15,
  }) async {
    final resolvedSlots = scheduleSlots.isNotEmpty
        ? scheduleSlots
        : scheduleDays
            .map(
              (d) => GroupScheduleSlot(
                day: d,
                startTime: startTime.trim(),
                endTime: endTime.trim(),
              ),
            )
            .toList();
    final resolvedDays = resolvedSlots.isNotEmpty
        ? resolvedSlots.map((s) => s.day).toList()
        : scheduleDays;
    final resolvedStart = startTime.trim().isNotEmpty
        ? startTime.trim()
        : (resolvedSlots.firstOrNull?.startTime ?? '');
    final resolvedEnd = endTime.trim().isNotEmpty
        ? endTime.trim()
        : (resolvedSlots.firstOrNull?.endTime ?? '');

    await _firestore.collection(groupsCollection).doc(groupId).set({
      'name': name.trim(),
      'track': track.toJson(),
      'teacherId': teacherId,
      'teacherName': teacherName.trim(),
      'scheduleDays': resolvedDays,
      'startTime': resolvedStart,
      'endTime': resolvedEnd,
      'scheduleSlots': resolvedSlots.map((s) => s.toMap()).toList(),
      'capacity': capacity,
    }, SetOptions(merge: true));
  }

  Future<void> deleteGroup(String groupId) async {
    await _firestore.collection(groupsCollection).doc(groupId).delete();
  }

  // ---------------------------------------------------------------------------
  // Multi-Track Enrollments & 1-on-1 Arrival Slots
  // ---------------------------------------------------------------------------

  Stream<List<Enrollment>> watchEnrollments() {
    return _firestore.collection(enrollmentsCollection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Enrollment.fromFirestore(doc))
              .toList(),
        );
  }

  Future<Enrollment> assignStudentToGroup({
    required String studentId,
    required String studentName,
    required String groupId,
    required String groupName,
    required CenterTrack track,
    String? oneOnOneSlotTime,
    String? groupArrivalTime,
  }) async {
    final existingQuery = await _firestore
        .collection(enrollmentsCollection)
        .where('studentId', isEqualTo: studentId)
        .where('groupId', isEqualTo: groupId)
        .limit(1)
        .get();
    if (existingQuery.docs.isNotEmpty) {
      throw DuplicateEnrollmentException(studentId, groupId);
    }

    final enrollmentId = 'enr-${studentId}_$groupId';
    final docRef =
        _firestore.collection(enrollmentsCollection).doc(enrollmentId);
    final existingDoc = await docRef.get();
    if (existingDoc.exists) {
      throw DuplicateEnrollmentException(studentId, groupId);
    }

    final enrollment = Enrollment(
      id: docRef.id,
      studentId: studentId,
      studentName: studentName.trim(),
      groupId: groupId,
      groupName: groupName.trim(),
      track: track,
      oneOnOneSlotTime: oneOnOneSlotTime?.trim(),
      groupArrivalTime: groupArrivalTime?.trim(),
      createdAt: DateTime.now(),
    );

    await docRef.set(enrollment.toMap());
    return enrollment;
  }

  Future<void> deleteEnrollment(String enrollmentId) async {
    await _firestore
        .collection(enrollmentsCollection)
        .doc(enrollmentId)
        .delete();
  }

  // ---------------------------------------------------------------------------
  // Center-wide Attendance Audit & Academic Reports
  // ---------------------------------------------------------------------------

  Stream<List<AttendanceLog>> watchAllAttendanceLogs() {
    return _firestore.collection(attendanceCollection).snapshots().map(
      (snapshot) {
        final list =
            snapshot.docs.map((doc) => AttendanceLog.fromFirestore(doc)).toList();
        list.sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
        return list;
      },
    );
  }

  Stream<List<HifzAssignment>> watchAllHifzAssignments() {
    return _firestore.collection(assignmentsCollection).snapshots().map(
      (snapshot) {
        final list = snapshot.docs
            .map((doc) => HifzAssignment.fromFirestore(doc))
            .toList();
        list.sort((a, b) => b.assignedAt.compareTo(a.assignedAt));
        return list;
      },
    );
  }
}
