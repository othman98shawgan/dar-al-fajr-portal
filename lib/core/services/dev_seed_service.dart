import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../features/admin/models/admin_models.dart';
import '../../features/auth/models/app_user.dart';
import '../../firebase_options.dart';

class DevSeedService {
  static const String secondaryAppName = 'DevSeedSecondaryApp';

  static Future<void> seedAllDemoData({
    required FirebaseFirestore firestore,
  }) async {
    FirebaseApp secondaryApp;
    try {
      secondaryApp = Firebase.app(secondaryAppName);
    } on FirebaseException {
      final options = Firebase.apps.isNotEmpty
          ? Firebase.app().options
          : DefaultFirebaseOptions.currentPlatform;
      secondaryApp = await Firebase.initializeApp(
        name: secondaryAppName,
        options: options,
      );
    }

    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

    // Helper to create or fetch Auth user UID safely
    Future<String> createOrGetUser(String email, String password) async {
      try {
        final cred = await secondaryAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        return cred.user!.uid;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          final cred = await secondaryAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          return cred.user!.uid;
        }
        rethrow;
      } finally {
        await secondaryAuth.signOut();
      }
    }

    debugPrint('Starting Dev Seed...');

    // 1. Seed Admin
    final adminUid = await createOrGetUser('admin@daralfajr.org', 'Admin@2026!');
    await firestore.collection('users').doc(adminUid).set(
      AppUser(
        uid: adminUid,
        email: 'admin@daralfajr.org',
        fullName: 'مدير النظام (أبو أحمد)',
        role: UserRole.admin,
        isFirstLogin: false,
        preferredLanguage: 'ar',
        phoneNumber: '+970 59 123 4567',
        createdAt: DateTime.now(),
      ).toMap(),
      SetOptions(merge: true),
    );

    // 2. Seed Teacher
    final teacherUid = await createOrGetUser('teacher@daralfajr.org', 'Teacher@2026!');
    await firestore.collection('users').doc(teacherUid).set(
      AppUser(
        uid: teacherUid,
        email: 'teacher@daralfajr.org',
        fullName: 'الشيخ عبد الرحمن',
        role: UserRole.teacher,
        isFirstLogin: false,
        preferredLanguage: 'ar',
        phoneNumber: '+970 59 765 4321',
        createdAt: DateTime.now(),
      ).toMap(),
      SetOptions(merge: true),
    );

    // 3. Seed Parent
    final parentUid = await createOrGetUser('parent@daralfajr.org', 'Parent@2026!');
    await firestore.collection('users').doc(parentUid).set(
      AppUser(
        uid: parentUid,
        email: 'parent@daralfajr.org',
        fullName: 'طه عثمان',
        role: UserRole.parent,
        isFirstLogin: false,
        preferredLanguage: 'ar',
        phoneNumber: '+970 59 888 9999',
        createdAt: DateTime.now(),
      ).toMap(),
      SetOptions(merge: true),
    );

    // 4. Seed Study Groups
    final groups = [
      StudyGroup(
        id: 'grp-hifz-1',
        name: 'حلقة الفجر للحفظ المكثف',
        track: CenterTrack.hifz,
        teacherId: teacherUid,
        teacherName: 'الشيخ عبد الرحمن',
        scheduleDays: ['السبت', 'الاثنين'],
        startTime: '17:00',
        endTime: '18:30',
        createdAt: DateTime.now(),
      ),
      StudyGroup(
        id: 'grp-qaidah-1',
        name: 'حلقة القاعدة النورانية التأسيسية',
        track: CenterTrack.qaidahNouraniah,
        teacherId: teacherUid,
        teacherName: 'الشيخ عبد الرحمن',
        scheduleDays: ['الأحد', 'الثلاثاء', 'الخميس'],
        startTime: '16:30',
        endTime: '17:45',
        createdAt: DateTime.now(),
      ),
      StudyGroup(
        id: 'grp-tajweed-1',
        name: 'حلقة الإتقان والتجويد المتقدم',
        track: CenterTrack.readingTajweed,
        teacherId: teacherUid,
        teacherName: 'الشيخ عبد الرحمن',
        scheduleDays: ['الأحد', 'الأربعاء'],
        startTime: '16:00',
        endTime: '17:30',
        createdAt: DateTime.now(),
      ),
    ];

    for (final group in groups) {
      await firestore.collection('groups').doc(group.id).set(
            group.toMap(),
            SetOptions(merge: true),
          );
    }

    // 5. Seed Students
    final students = [
      StudentProfile(
        id: 'st-1042',
        fullName: 'إبراهيم طه عثمان',
        parentId: parentUid,
        parentName: 'طه عثمان',
        email: 'ibrahim.taha@daralfajr.org',
        phoneNumber: '+970 59 111 2222',
        dateOfBirth: DateTime(2013, 5, 12),
        memorizedPages: [1, 2, 3, 4, 5],
        completedSurahs: [1],
        completedJuz: [1],
        createdAt: DateTime.now(),
      ),
      StudentProfile(
        id: 'st-1088',
        fullName: 'عبد الرحمن يوسف الشريف',
        parentId: parentUid,
        parentName: 'يوسف الشريف',
        email: 'y.shareef@daralfajr.org',
        phoneNumber: '+970 59 333 4444',
        dateOfBirth: DateTime(2011, 8, 20),
        memorizedPages: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        completedSurahs: [1, 114, 113, 112],
        completedJuz: [30],
        createdAt: DateTime.now(),
      ),
      StudentProfile(
        id: 'st-1102',
        fullName: 'زياد سليمان المنصور',
        parentId: parentUid,
        parentName: 'سليمان المنصور',
        phoneNumber: '+970 59 555 6666',
        dateOfBirth: DateTime(2014, 2, 10),
        createdAt: DateTime.now(),
      ),
      StudentProfile(
        id: 'st-1130',
        fullName: 'عمر فاروق البغدادي',
        parentId: parentUid,
        parentName: 'فاروق البغدادي',
        phoneNumber: '+970 59 777 8888',
        dateOfBirth: DateTime(2012, 11, 5),
        createdAt: DateTime.now(),
      ),
    ];

    for (final student in students) {
      await firestore.collection('students').doc(student.id).set(
            student.toMap(),
            SetOptions(merge: true),
          );
    }

    // 6. Seed Enrollments
    final enrollments = [
      Enrollment(
        id: 'enr-1042',
        studentId: 'st-1042',
        studentName: 'إبراهيم طه عثمان',
        groupId: 'grp-qaidah-1',
        groupName: 'حلقة القاعدة النورانية التأسيسية',
        track: CenterTrack.qaidahNouraniah,
        groupArrivalTime: 'الأحد والثلاثاء والخميس 16:30',
        oneOnOneSlotTime: 'الخميس 17:15 (فردي)',
        createdAt: DateTime.now(),
      ),
      Enrollment(
        id: 'enr-1088',
        studentId: 'st-1088',
        studentName: 'عبد الرحمن يوسف الشريف',
        groupId: 'grp-hifz-1',
        groupName: 'حلقة الفجر للحفظ المكثف',
        track: CenterTrack.hifz,
        groupArrivalTime: 'السبت والاثنين 17:00',
        oneOnOneSlotTime: 'الاثنين 18:00 (فردي)',
        createdAt: DateTime.now(),
      ),
      Enrollment(
        id: 'enr-1102',
        studentId: 'st-1102',
        studentName: 'زياد سليمان المنصور',
        groupId: 'grp-tajweed-1',
        groupName: 'حلقة الإتقان والتجويد المتقدم',
        track: CenterTrack.readingTajweed,
        groupArrivalTime: 'الأحد والأربعاء 16:00',
        createdAt: DateTime.now(),
      ),
    ];

    for (final enr in enrollments) {
      await firestore.collection('enrollments').doc(enr.id).set(
            enr.toMap(),
            SetOptions(merge: true),
          );
    }

    debugPrint('Dev Seed Complete!');
  }
}
