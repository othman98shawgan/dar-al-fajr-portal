import 'package:dar_al_fajr_portal/features/admin/models/admin_models.dart';
import 'package:dar_al_fajr_portal/features/auth/models/app_user.dart';
import 'package:dar_al_fajr_portal/features/auth/providers/auth_providers.dart';
import 'package:dar_al_fajr_portal/features/hifz/models/teacher_models.dart';
import 'package:dar_al_fajr_portal/features/hifz/providers/teacher_providers.dart';
import 'package:dar_al_fajr_portal/features/hifz/repositories/teacher_repository.dart';
import 'package:dar_al_fajr_portal/features/hifz/screens/attendance_logging_view.dart';
import 'package:dar_al_fajr_portal/features/hifz/screens/group_detail_screen.dart';
import 'package:dar_al_fajr_portal/features/hifz/screens/teacher_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Teacher Safety & Live Data Tests', () {
    test('TeacherController aborts with StateError when unauthenticated',
        () async {
      final container = ProviderContainer(
        overrides: [
          currentAppUserProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(currentAppUserProvider, (_, _) {});
      addTearDown(sub.close);
      await container.read(currentAppUserProvider.future);

      final notifier = container.read(teacherControllerProvider.notifier);

      final logged = await notifier.logAttendance(
        groupId: 'grp-live-1',
        studentId: 'st-1',
        studentName: 'طالب حي',
        status: AttendanceStatus.present,
      );
      expect(logged, isFalse);
      expect(container.read(teacherControllerProvider).hasError, isTrue);
      expect(container.read(teacherControllerProvider).error, isA<StateError>());

      final batchSaved = await notifier.saveBatchAttendance(
        groupId: 'grp-live-1',
        studentStatuses: const {'st-1': AttendanceStatus.present},
      );
      expect(batchSaved, isFalse);
      expect(container.read(teacherControllerProvider).error, isA<StateError>());

      final assignmentSaved = await notifier.saveHifzAssignment(
        studentId: 'st-1',
        studentName: 'طالب حي',
        groupId: 'grp-live-1',
        type: AssignmentType.newHifz,
        surahId: 78,
        surahName: 'النبأ',
        fromAyah: 1,
        toAyah: 20,
        grade: EvaluationGrade.excellent,
      );
      expect(assignmentSaved, isNull);
      expect(container.read(teacherControllerProvider).error, isA<StateError>());

      final planSaved = await notifier.saveWeeklyRevisionPlan(
        studentId: 'st-1',
        studentName: 'طالب حي',
        groupId: 'grp-live-1',
        weekStartDate: DateTime.now(),
        dailyTasks: const [],
      );
      expect(planSaved, isNull);
      expect(container.read(teacherControllerProvider).error, isA<StateError>());
    });

    testWidgets(
      'TeacherHomeScreen shows live Today Sessions, omits teacher name on group cards, uses Open Group, and renders Daily/Weekly schedule',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final now = DateTime.now();
        final todayAr = ScheduleDayHelper.canonicalArabicDay(now.weekday);
        final nextWeekday = (now.weekday % 7) + 1;
        final otherAr = ScheduleDayHelper.canonicalArabicDay(nextWeekday);

        const teacher = AppUser(
          uid: 't-live-1',
          email: 't@daralfajr.org',
          fullName: 'الشيخ سامي الحي',
          role: UserRole.teacher,
        );
        final liveGroup = StudyGroup(
          id: 'grp-live-1',
          name: 'حلقة النور المباشرة',
          track: CenterTrack.hifz,
          teacherId: 't-live-1',
          teacherName: 'الشيخ سامي الحي',
          scheduleSlots: [
            GroupScheduleSlot(day: todayAr, startTime: '16:30', endTime: '18:00'),
            GroupScheduleSlot(day: otherAr, startTime: '17:45', endTime: '19:00'),
          ],
        );
        final enrollments = [
          Enrollment(
            id: 'enr-1',
            studentId: 'st-live-1',
            studentName: 'زيد المنصور',
            groupId: 'grp-live-1',
            groupName: 'حلقة النور المباشرة',
            track: CenterTrack.hifz,
            oneOnOneSlotTime: '$todayAr 17:15 (فردي)',
          ),
          Enrollment(
            id: 'enr-2',
            studentId: 'st-live-2',
            studentName: 'سعد التميمي',
            groupId: 'grp-live-1',
            groupName: 'حلقة النور المباشرة',
            track: CenterTrack.hifz,
            oneOnOneSlotTime: '$todayAr 17:45 (فردي)',
          ),
          Enrollment(
            id: 'enr-3',
            studentId: 'st-live-3',
            studentName: 'طارق العلي',
            groupId: 'grp-live-1',
            groupName: 'حلقة النور المباشرة',
            track: CenterTrack.hifz,
            oneOnOneSlotTime: '$otherAr 18:15 (فردي)',
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentAppUserProvider.overrideWith((ref) => Stream.value(teacher)),
              teacherGroupsProvider
                  .overrideWith((ref) => Stream.value([liveGroup])),
              allEnrollmentsStreamProvider
                  .overrideWith((ref) => Stream.value(enrollments)),
            ],
            child: const MaterialApp(home: TeacherHomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Group card shows name and student count, NOT teacher name
        expect(find.text('حلقة النور المباشرة'), findsOneWidget);
        expect(find.text('الشيخ سامي الحي'), findsNothing);
        expect(find.text('٣ طلاب مسجلين'), findsOneWidget);

        // Button label standardized to Open Group
        expect(find.text('فتح الحلقة'), findsOneWidget);
        expect(find.text('فتح تفاصيل ومقررات الحلقة'), findsNothing);

        // Welcome card shows Today's Sessions (1 group + 2 today 1x1s = 3)
        expect(find.text('جلسات اليوم'), findsOneWidget);
        expect(find.text('نسبة الإتقان'), findsNothing);
        expect(find.textContaining('${now.year}'), findsOneWidget);
        expect(find.textContaining('١٤٤٦'), findsNothing);

        // Today's 1-on-1 section excludes other day's slot
        expect(find.text('زيد المنصور'), findsOneWidget);
        expect(find.text('سعد التميمي'), findsOneWidget);
        expect(find.text('طارق العلي'), findsNothing);

        // Switch to Schedule tab (Daily view)
        await tester.tap(find.text('الجدول'));
        await tester.pumpAndSettle();
        expect(find.text('16:30 - 18:00'), findsOneWidget);
        expect(find.text('17:15'), findsOneWidget);
        expect(find.text('طارق العلي'), findsNothing);

        // Switch to Weekly view to verify full week including different day times
        await tester.tap(find.text('أسبوعي'));
        await tester.pumpAndSettle();
        expect(find.text('17:45 - 19:00'), findsOneWidget);
        expect(find.text('طارق العلي'), findsOneWidget);
      },
    );

    testWidgets(
      'GroupDetailScreen resolves live revision student without st-1042 demo leak',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        const liveGroup = StudyGroup(
          id: 'grp-live-2',
          name: 'حلقة الفرقان الحية',
          track: CenterTrack.hifz,
          teacherId: 't-live-1',
        );
        const enrollments = [
          Enrollment(
            id: 'enr-live-99',
            studentId: 'st-live-99',
            studentName: 'خالد بن الوليد الحي',
            groupId: 'grp-live-2',
            groupName: 'حلقة الفرقان الحية',
            track: CenterTrack.hifz,
          ),
        ];
        const studentsMap = {
          'st-live-99': StudentProfile(
            id: 'st-live-99',
            fullName: 'خالد بن الوليد الحي',
            parentId: 'p-live-99',
            completedJuz: [30, 29],
            juzStatuses: {30: 'passed_exam', 29: 'in_progress'},
          ),
        };
        final assignments = [
          HifzAssignment(
            id: 'a-live-99',
            studentId: 'st-live-99',
            studentName: 'خالد بن الوليد الحي',
            groupId: 'grp-live-2',
            teacherId: 't-live-1',
            type: AssignmentType.newHifz,
            surahId: 78,
            surahName: 'النبأ',
            fromAyah: 1,
            toAyah: 20,
            grade: EvaluationGrade.excellent,
            score: 97,
            assignedAt: DateTime.now(),
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              allGroupsStreamProvider
                  .overrideWith((ref) => Stream.value([liveGroup])),
              groupEnrollmentsProvider('grp-live-2')
                  .overrideWith((ref) => Stream.value(enrollments)),
              allStudentsMapProvider
                  .overrideWith((ref) => Stream.value(studentsMap)),
              groupAssignmentsProvider('grp-live-2')
                  .overrideWith((ref) => Stream.value(assignments)),
              groupAttendanceProvider('grp-live-2')
                  .overrideWith((ref) => Stream.value(const [])),
              studentWeeklyPlansProvider('st-live-99').overrideWith(
                (ref) => Stream.value([
                  WeeklyRevisionPlan(
                    id: 'plan-99',
                    studentId: 'st-live-99',
                    studentName: 'خالد بن الوليد الحي',
                    groupId: 'grp-live-2',
                    teacherId: 't-live-1',
                    weekStartDate: DateTime.now(),
                    updatedAt: DateTime.now(),
                    dailyTasks: const [
                      DailyRevisionTask(
                        dayIndex: 0,
                        targetType: RevisionTargetType.juz,
                        juzNumber: 30,
                      ),
                    ],
                  ),
                ]),
              ),
              studentProfileByIdProvider('st-live-99')
                  .overrideWith((ref) => Stream.value(studentsMap['st-live-99'])),
              studentAssignmentsProvider('st-live-99')
                  .overrideWith((ref) => Stream.value(assignments)),
            ],
            child: const MaterialApp(
              home: GroupDetailScreen(groupId: 'grp-live-2'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Live card renders and demo st-1042 student is absent
        expect(find.text('خالد بن الوليد الحي'), findsOneWidget);
        expect(find.text('إبراهيم طه عثمان'), findsNothing);

        // Switch to Weekly Revision tab and verify live student resolves dynamically
        await tester.tap(find.text('خطة المراجعة'));
        await tester.pumpAndSettle();

        expect(find.textContaining('خالد بن الوليد الحي'), findsWidgets);
        expect(find.text('إبراهيم طه عثمان'), findsNothing);

        // Switch to Students Roster tab in Hifz group and open Student Profile
        await tester.tap(find.text('قائمة الطلاب'));
        await tester.pumpAndSettle();

        expect(find.text('خالد بن الوليد الحي'), findsOneWidget);
        await tester.tap(find.text('خالد بن الوليد الحي'));
        await tester.pumpAndSettle();

        expect(find.text('ملف الطالب'), findsOneWidget);
        expect(find.text('خطة المراجعة الأسبوعية الحالية'), findsOneWidget);
        expect(find.textContaining('النبأ'), findsWidgets);
      },
    );

    testWidgets(
      'AttendanceLoggingView deduplicates duplicate enrollments for the same studentId',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        const enrollments = [
          Enrollment(
            id: 'enr-1',
            studentId: 'stu-1',
            studentName: 'طالب أول',
            groupId: 'grp-maali',
            groupName: 'طلاب المعالي',
            track: CenterTrack.hifz,
          ),
          Enrollment(
            id: 'enr-1-dup',
            studentId: 'stu-1',
            studentName: 'طالب أول',
            groupId: 'grp-maali',
            groupName: 'طلاب المعالي',
            track: CenterTrack.hifz,
          ),
          Enrollment(
            id: 'enr-2',
            studentId: 'stu-2',
            studentName: 'طالب ثاني',
            groupId: 'grp-maali',
            groupName: 'طلاب المعالي',
            track: CenterTrack.hifz,
          ),
          Enrollment(
            id: 'enr-3',
            studentId: 'stu-3',
            studentName: 'طالب ثالث',
            groupId: 'grp-maali',
            groupName: 'طلاب المعالي',
            track: CenterTrack.hifz,
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              teacherGroupsProvider.overrideWith(
                (ref) => Stream.value(const [
                  StudyGroup(
                    id: 'grp-maali',
                    name: 'طلاب المعالي',
                    track: CenterTrack.hifz,
                    teacherId: 't-1',
                  ),
                ]),
              ),
              groupEnrollmentsProvider('grp-maali')
                  .overrideWith((ref) => Stream.value(enrollments)),
              allStudentsMapProvider
                  .overrideWith((ref) => Stream.value(const {})),
            ],
            child: const MaterialApp(
              home: AttendanceLoggingView(groupId: 'grp-maali'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('طالب أول'), findsOneWidget);
        expect(find.text('طالب ثاني'), findsOneWidget);
        expect(find.text('طالب ثالث'), findsOneWidget);
        expect(find.textContaining('٣ متاحون'), findsOneWidget);

        // Deterministic attendance doc ID enforces one log per student/day/mode
        expect(
          TeacherRepository.attendanceDocId(
            groupId: 'grp-maali',
            studentId: 'stu-1',
            date: DateTime(2026, 11, 17, 9, 0),
          ),
          TeacherRepository.attendanceDocId(
            groupId: 'grp-maali',
            studentId: 'stu-1',
            date: DateTime(2026, 11, 17, 21, 30),
          ),
        );
        expect(
          TeacherRepository.attendanceDocId(
            groupId: 'grp-maali',
            studentId: 'stu-1',
            date: DateTime(2026, 11, 17),
          ),
          'att_grp-maali_stu-1_20261117_group',
        );
      },
    );

    testWidgets(
      'AttendanceLoggingView loads existing logs for selected date and switches days with arrows',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final today = DateTime.now();
        final todayLogs = [
          AttendanceLog(
            id: 'att_grp-maali_stu-1_today_group',
            groupId: 'grp-maali',
            studentId: 'stu-1',
            studentName: 'طالب أول',
            teacherId: 't-1',
            sessionDate: today,
            sessionMode: SessionMode.group,
            status: AttendanceStatus.absent,
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              teacherGroupsProvider.overrideWith(
                (ref) => Stream.value(const [
                  StudyGroup(
                    id: 'grp-maali',
                    name: 'طلاب المعالي',
                    track: CenterTrack.hifz,
                    teacherId: 't-1',
                  ),
                ]),
              ),
              groupEnrollmentsProvider('grp-maali').overrideWith(
                (ref) => Stream.value(const [
                  Enrollment(
                    id: 'enr-1',
                    studentId: 'stu-1',
                    studentName: 'طالب أول',
                    groupId: 'grp-maali',
                    groupName: 'طلاب المعالي',
                    track: CenterTrack.hifz,
                  ),
                ]),
              ),
              allStudentsMapProvider
                  .overrideWith((ref) => Stream.value(const {})),
              groupAttendanceProvider('grp-maali')
                  .overrideWith((ref) => Stream.value(todayLogs)),
            ],
            child: const MaterialApp(
              home: AttendanceLoggingView(groupId: 'grp-maali'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Today badge and existing-log update state are shown
        expect(find.text('اليوم'), findsOneWidget);
        expect(find.text('تحديث سجل الحضور'), findsOneWidget);
        expect(
          find.text('تم رصد حضور هذا اليوم مسبقاً — عند الحفظ سيتم تحديث السجل الحالي'),
          findsOneWidget,
        );

        // Step to previous day using arrow button
        await tester.tap(find.byTooltip('اليوم السابق'));
        await tester.pumpAndSettle();

        expect(find.text('اليوم'), findsNothing);
        expect(find.text('حفظ الحضور واعتماد السجل'), findsOneWidget);
      },
    );
  });
}
