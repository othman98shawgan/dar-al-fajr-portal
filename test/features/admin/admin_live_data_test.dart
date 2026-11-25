import 'package:dar_al_fajr_portal/features/admin/models/admin_models.dart';
import 'package:dar_al_fajr_portal/features/admin/providers/admin_providers.dart';
import 'package:dar_al_fajr_portal/features/admin/screens/admin_mobile_screen.dart';
import 'package:dar_al_fajr_portal/features/admin/screens/admin_shell_screen.dart';
import 'package:dar_al_fajr_portal/features/admin/widgets/admin_shell_models.dart';
import 'package:dar_al_fajr_portal/features/auth/models/app_user.dart';
import 'package:dar_al_fajr_portal/features/auth/providers/auth_providers.dart';
import 'package:dar_al_fajr_portal/features/hifz/models/teacher_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const adminUser = AppUser(
    uid: 'admin-1',
    email: 'admin@daralfajr.org',
    fullName: 'مدير المركز',
    role: UserRole.admin,
    isFirstLogin: false,
  );

  const liveTeachers = [
    AppUser(
      uid: 'teacher-live-1',
      email: 'yusuf.najjar@daralfajr.org',
      fullName: 'الشيخ يوسف النجار',
      role: UserRole.teacher,
      isFirstLogin: false,
    ),
    AppUser(
      uid: 'teacher-live-2',
      email: 'khaled.mansour@daralfajr.org',
      fullName: 'الأستاذ خالد منصور',
      role: UserRole.teacher,
      isFirstLogin: false,
    ),
  ];

  final liveStudents = [
    const StudentProfile(
      id: 'stu-live-1',
      fullName: 'سلمان فهد الحربي',
      parentId: 'par-1',
      parentName: 'فهد الحربي',
      email: 'salman@example.com',
      memorizedPages: [1, 2, 3, 4],
      completedSurahs: [114],
      completedJuz: [30],
    ),
    const StudentProfile(
      id: 'stu-live-2',
      fullName: 'يوسف كريم حسن',
      parentId: 'par-2',
      parentName: 'كريم حسن',
      memorizedPages: [10, 11],
      completedSurahs: [],
      completedJuz: [],
    ),
  ];

  final liveGroups = [
    const StudyGroup(
      id: 'grp-live-1',
      name: 'حلقة النور للحفظ',
      track: CenterTrack.hifz,
      teacherId: 'teacher-live-1',
      teacherName: 'الشيخ يوسف النجار',
      scheduleDays: ['الأحد', 'الثلاثاء'],
      startTime: '16:30',
      endTime: '18:00',
      capacity: 10,
    ),
    const StudyGroup(
      id: 'grp-live-2',
      name: 'حلقة التجويد المتقدم',
      track: CenterTrack.readingTajweed,
      teacherId: 'teacher-live-2',
      teacherName: 'الأستاذ خالد منصور',
      scheduleDays: ['السبت'],
      startTime: '17:00',
      endTime: '18:30',
      capacity: 12,
    ),
  ];

  final liveEnrollments = [
    const Enrollment(
      id: 'enr-1',
      studentId: 'stu-live-1',
      studentName: 'سلمان فهد الحربي',
      groupId: 'grp-live-1',
      groupName: 'حلقة النور للحفظ',
      track: CenterTrack.hifz,
      groupArrivalTime: 'الأحد والثلاثاء 16:30',
      oneOnOneSlotTime: 'الخميس 17:00',
    ),
    const Enrollment(
      id: 'enr-2',
      studentId: 'stu-live-2',
      studentName: 'يوسف كريم حسن',
      groupId: 'grp-live-2',
      groupName: 'حلقة التجويد المتقدم',
      track: CenterTrack.readingTajweed,
      groupArrivalTime: 'السبت 17:00',
    ),
    const Enrollment(
      id: 'enr-3',
      studentId: 'stu-live-1',
      studentName: 'سلمان فهد الحربي',
      groupId: 'grp-live-2',
      groupName: 'حلقة التجويد المتقدم',
      track: CenterTrack.readingTajweed,
    ),
  ];

  final now = DateTime(2026, 5, 10, 16, 30);
  final liveLogs = [
    AttendanceLog(
      id: 'log-1',
      groupId: 'grp-live-1',
      studentId: 'stu-live-1',
      studentName: 'سلمان فهد الحربي',
      teacherId: 'teacher-live-1',
      sessionDate: now,
      status: AttendanceStatus.present,
    ),
    AttendanceLog(
      id: 'log-2',
      groupId: 'grp-live-2',
      studentId: 'stu-live-2',
      studentName: 'يوسف كريم حسن',
      teacherId: 'teacher-live-2',
      sessionDate: now,
      status: AttendanceStatus.absent,
      notes: 'عذر عائلي',
    ),
  ];

  final liveAssignments = [
    HifzAssignment(
      id: 'asg-1',
      studentId: 'stu-live-1',
      studentName: 'سلمان فهد الحربي',
      groupId: 'grp-live-1',
      teacherId: 'teacher-live-1',
      type: AssignmentType.newHifz,
      surahId: 114,
      surahName: 'الناس',
      fromAyah: 1,
      toAyah: 6,
      grade: EvaluationGrade.excellent,
      assignedAt: now,
    ),
    HifzAssignment(
      id: 'asg-2',
      studentId: 'stu-live-2',
      studentName: 'يوسف كريم حسن',
      groupId: 'grp-live-2',
      teacherId: 'teacher-live-2',
      type: AssignmentType.revision,
      surahId: 113,
      surahName: 'الفلق',
      fromAyah: 1,
      toAyah: 5,
      grade: EvaluationGrade.needsRepeat,
      assignedAt: now,
    ),
  ];

  group('StudyGroup capacity serialization', () {
    test('defaults capacity to 15 when omitted and preserves custom capacity', () {
      final defaultGroup = StudyGroup.fromMap({
        'name': 'حلقة الفجر',
        'track': 'hifz',
        'teacherId': 't-1',
      }, id: 'g-default');
      expect(defaultGroup.capacity, 15);
      expect(defaultGroup.toMap()['capacity'], 15);

      final customGroup = StudyGroup.fromMap({
        'name': 'حلقة الإتقان',
        'track': 'readingTajweed',
        'teacherId': 't-2',
        'capacity': 22,
      }, id: 'g-custom');
      expect(customGroup.capacity, 22);
      expect(customGroup.toMap()['capacity'], 22);
    });
  });

  group('AdminShellScreen live data tests', () {
    testWidgets(
        'renders live Available Seats KPI, Attendance Audit filters, and Reports analytics',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentAppUserProvider.overrideWith((ref) => Stream.value(adminUser)),
            adminAllUsersProvider.overrideWith(
              (ref) => Stream.value([adminUser, ...liveTeachers]),
            ),
            adminTeachersProvider.overrideWith((ref) => Stream.value(liveTeachers)),
            adminStudentsProvider.overrideWith((ref) => Stream.value(liveStudents)),
            adminGroupsProvider.overrideWith((ref) => Stream.value(liveGroups)),
            adminEnrollmentsProvider.overrideWith((ref) => Stream.value(liveEnrollments)),
            adminAttendanceLogsProvider.overrideWith((ref) => Stream.value(liveLogs)),
            adminHifzAssignmentsProvider.overrideWith((ref) => Stream.value(liveAssignments)),
          ],
          child: const MaterialApp(
            home: AdminShellScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Capacities: 10 + 12 = 22, minus 3 enrollments => 19 Available Seats
      expect(find.text('19'), findsOneWidget);
      expect(find.text('سلمان فهد الحربي'), findsWidgets);
      expect(find.text('إبراهيم طه عثمان'), findsNothing);

      // Navigate to Tab 4: Attendance Audit
      await tester.tap(find.text('سجل الحضور'));
      await tester.pumpAndSettle();

      expect(find.text('سجل الحضور والغياب (Attendance Audit)'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('سلمان فهد الحربي'), findsOneWidget);
      expect(find.text('يوسف كريم حسن'), findsOneWidget);

      // Filter by Absent status chip (only يوسف كريم حسن remains)
      await tester.tap(find.widgetWithText(ChoiceChip, AttendanceStatus.absent.localizedName('ar')));
      await tester.pumpAndSettle();

      expect(find.text('يوسف كريم حسن'), findsOneWidget);
      expect(find.text('سلمان فهد الحربي'), findsNothing);

      // Navigate to Tab 5: Reports & Analytics
      await tester.tap(find.text('التقارير والإحصائيات'));
      await tester.pumpAndSettle();

      expect(find.text('التقارير والإحصائيات الأكاديمية'), findsOneWidget);
      // 1 of 2 attended = 50% attendance, 1 of 2 graded passed = 50% mastery
      expect(find.text('50%'), findsNWidgets(2));
      expect(find.textContaining('الناس (1-6)'), findsOneWidget);
      expect(find.textContaining('الفلق (1-5)'), findsOneWidget);
    });
  });

  group('AdminMobileScreen live data tests', () {
    testWidgets(
        'uses live teachers in Create Group dialog and live metrics in Mobile Reports',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentAppUserProvider.overrideWith((ref) => Stream.value(adminUser)),
            adminAllUsersProvider.overrideWith(
              (ref) => Stream.value([adminUser, ...liveTeachers]),
            ),
            adminTeachersProvider.overrideWith((ref) => Stream.value(liveTeachers)),
            adminStudentsProvider.overrideWith((ref) => Stream.value(liveStudents)),
            adminGroupsProvider.overrideWith((ref) => Stream.value(liveGroups)),
            adminEnrollmentsProvider.overrideWith((ref) => Stream.value(liveEnrollments)),
            adminAttendanceLogsProvider.overrideWith((ref) => Stream.value(liveLogs)),
            adminHifzAssignmentsProvider.overrideWith((ref) => Stream.value(liveAssignments)),
          ],
          child: const MaterialApp(
            home: AdminMobileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Groups tab and open Create Group dialog
      await tester.tap(find.text('الحلقات'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add_circle_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('إنشاء حلقة جديدة'), findsOneWidget);
      expect(find.text('الشيخ يوسف النجار'), findsWidgets);
      expect(find.text('الشيخ عبد الرحمن'), findsNothing);

      // Close modal sheet
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Switch to Reports tab and verify live metrics replace hardcoded '94%' / '118 جزءاً'
      await tester.tap(find.text('التقارير'));
      await tester.pumpAndSettle();

      expect(find.text('50%'), findsOneWidget);
      expect(find.text('1 جزءاً'), findsOneWidget);
      expect(find.text('94%'), findsNothing);
      expect(find.text('118 جزءاً'), findsNothing);
    });

    test('StudyGroup supports per-day GroupScheduleSlot serialization and formatting', () {
      const group = StudyGroup(
        id: 'grp-multi-time',
        name: 'حلقة المواعيد المتنوعة',
        track: CenterTrack.hifz,
        teacherId: 'teacher-1',
        scheduleSlots: [
          GroupScheduleSlot(day: 'الأحد', startTime: '16:30', endTime: '18:00'),
          GroupScheduleSlot(day: 'الأربعاء', startTime: '17:30', endTime: '19:00'),
        ],
      );

      final map = group.toMap();
      final decoded = StudyGroup.fromMap(map, id: 'grp-multi-time');

      expect(decoded.effectiveScheduleSlots.length, 2);
      expect(decoded.slotsForWeekday(DateTime.sunday).first.startTime, '16:30');
      expect(decoded.slotsForWeekday(DateTime.wednesday).first.startTime, '17:30');
      expect(
        decoded.formatScheduleSummary('en'),
        'Sunday (16:30 - 18:00) • Wednesday (17:30 - 19:00)',
      );
      expect(
        decoded.formatScheduleSummary('en', multiline: true),
        'Sunday • 16:30 - 18:00\nWednesday • 17:30 - 19:00',
      );

      const uniformGroup = StudyGroup(
        id: 'grp-uniform',
        name: 'Uniform Group',
        track: CenterTrack.hifz,
        teacherId: 'teacher-1',
        scheduleDays: ['السبت', 'الاثنين'],
        startTime: '16:30',
        endTime: '18:00',
      );
      expect(
        uniformGroup.formatScheduleSummary('en', multiline: true),
        'Saturday • 16:30 - 18:00\nMonday • 16:30 - 18:00',
      );

      final parsed = ScheduleDayHelper.parseOneOnOneSlot('الخميس 17:15 (فردي)');
      expect(parsed.weekday, DateTime.thursday);
      expect(parsed.timeLabel, '17:15');

      expect(formatAdminStudentCode('st-1000'), '#ST-1000');
      expect(formatAdminStudentCode('st-1042'), '#ST-1042');
      expect(formatAdminStudentCode('abc123xyz'), '#ST-ABC1');
    });

    testWidgets(
      'AdminShellScreen blocks duplicate enrollment for the same student and group',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentAppUserProvider.overrideWith((ref) => Stream.value(adminUser)),
              adminAllUsersProvider.overrideWith(
                (ref) => Stream.value([adminUser, ...liveTeachers]),
              ),
              adminTeachersProvider.overrideWith((ref) => Stream.value(liveTeachers)),
              adminStudentsProvider.overrideWith((ref) => Stream.value(liveStudents)),
              adminGroupsProvider.overrideWith((ref) => Stream.value(liveGroups)),
              adminEnrollmentsProvider.overrideWith((ref) => Stream.value(liveEnrollments)),
              adminAttendanceLogsProvider.overrideWith((ref) => Stream.value(liveLogs)),
              adminHifzAssignmentsProvider.overrideWith((ref) => Stream.value(liveAssignments)),
            ],
            child: const MaterialApp(
              home: AdminShellScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // stu-live-1 is already enrolled in grp-live-1; open Enroll drawer
        await tester.tap(find.text('+ تسجيل في حلقة').first);
        await tester.pumpAndSettle();

        expect(
          find.text('الطالب مسجل بالفعل في هذه الحلقة. لا يمكن تكرار التسجيل في نفس الحلقة.'),
          findsOneWidget,
        );
      },
    );
  });
}
