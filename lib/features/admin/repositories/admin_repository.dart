import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/models/app_user.dart';
import '../../auth/repositories/auth_repository.dart';
import '../models/admin_models.dart';

class AdminRepository {
  static const String usersCollection = 'users';
  static const String studentsCollection = 'students';
  static const String groupsCollection = 'groups';
  static const String enrollmentsCollection = 'enrollments';

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  AdminRepository({
    FirebaseFirestore? firestore,
    required AuthRepository authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository;

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
    return await _authRepository.provisionUserAccount(
      email: email,
      temporaryPassword: temporaryPassword,
      fullName: fullName,
      role: role,
      phoneNumber: phoneNumber,
      preferredLanguage: preferredLanguage,
    );
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
      final user = await _authRepository.provisionUserAccount(
        email: email.trim(),
        temporaryPassword: temporaryPassword,
        fullName: fullName.trim(),
        role: UserRole.student,
        phoneNumber: phoneNumber,
      );
      linkedUserId = user.uid;
    }

    final docRef = _firestore.collection(studentsCollection).doc();
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
  }) async {
    final docRef = _firestore.collection(groupsCollection).doc();
    final group = StudyGroup(
      id: docRef.id,
      name: name.trim(),
      track: track,
      teacherId: teacherId,
      teacherName: teacherName.trim(),
      scheduleDays: scheduleDays,
      startTime: startTime.trim(),
      endTime: endTime.trim(),
      createdAt: DateTime.now(),
    );

    await docRef.set(group.toMap());
    return group;
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
    final docRef = _firestore.collection(enrollmentsCollection).doc();
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
}
