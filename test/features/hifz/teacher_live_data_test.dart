import 'package:dar_al_fajr_portal/features/admin/models/admin_models.dart';
import 'package:dar_al_fajr_portal/features/auth/models/app_user.dart';
import 'package:dar_al_fajr_portal/features/auth/providers/auth_providers.dart';
import 'package:dar_al_fajr_portal/features/hifz/models/teacher_models.dart';
import 'package:dar_al_fajr_portal/features/hifz/providers/teacher_providers.dart';
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
      'TeacherHomeScreen computes live Mastery Rate from group assignments and displays current year date',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        const teacher = AppUser(
          uid: 't-live-1',
          email: 't@daralfajr.org',
          fullName: 'الشيخ سامي الحي',
          role: UserRole.teacher,
        );
        const liveGroup = StudyGroup(
          id: 'grp-live-1',
          name: 'حلقة النور المباشرة',
          track: CenterTrack.hifz,
          teacherId: 't-live-1',
          teacherName: 'الشيخ سامي الحي',
          scheduleDays: ['الأحد', 'الثلاثاء'],
          startTime: '16:30',
          endTime: '18:00',
        );
        final enrollments = [
          const Enrollment(
            id: 'enr-1',
            studentId: 'st-live-1',
            studentName: 'زيد المنصور',
            groupId: 'grp-live-1',
            groupName: 'حلقة النور المباشرة',
            track: CenterTrack.hifz,
          ),
          const Enrollment(
            id: 'enr-2',
            studentId: 'st-live-2',
            studentName: 'سعد التميمي',
            groupId: 'grp-live-1',
            groupName: 'حلقة النور المباشرة',
            track: CenterTrack.hifz,
          ),
        ];
        final now = DateTime.now();
        // 2 passed (excellent, good), 1 needsRepeat, 1 pending (ignored) => 2/3 = 67%
        final assignments = [
          HifzAssignment(
            id: 'a-1',
            studentId: 'st-live-1',
            studentName: 'زيد المنصور',
            groupId: 'grp-live-1',
            teacherId: 't-live-1',
            type: AssignmentType.newHifz,
            surahId: 67,
            surahName: 'الملك',
            fromAyah: 1,
            toAyah: 15,
            grade: EvaluationGrade.excellent,
            score: 98,
            assignedAt: now,
          ),
          HifzAssignment(
            id: 'a-2',
            studentId: 'st-live-2',
            studentName: 'سعد التميمي',
            groupId: 'grp-live-1',
            teacherId: 't-live-1',
            type: AssignmentType.newHifz,
            surahId: 68,
            surahName: 'القلم',
            fromAyah: 1,
            toAyah: 20,
            grade: EvaluationGrade.good,
            score: 95,
            assignedAt: now,
          ),
          HifzAssignment(
            id: 'a-3',
            studentId: 'st-live-2',
            studentName: 'سعد التميمي',
            groupId: 'grp-live-1',
            teacherId: 't-live-1',
            type: AssignmentType.revision,
            surahId: 78,
            surahName: 'النبأ',
            fromAyah: 1,
            toAyah: 40,
            grade: EvaluationGrade.needsRepeat,
            score: 70,
            assignedAt: now,
          ),
          HifzAssignment(
            id: 'a-4',
            studentId: 'st-live-1',
            studentName: 'زيد المنصور',
            groupId: 'grp-live-1',
            teacherId: 't-live-1',
            type: AssignmentType.newHifz,
            surahId: 67,
            surahName: 'الملك',
            fromAyah: 16,
            toAyah: 30,
            grade: EvaluationGrade.pending,
            assignedAt: now,
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
              groupAssignmentsProvider('grp-live-1')
                  .overrideWith((ref) => Stream.value(assignments)),
            ],
            child: const MaterialApp(home: TeacherHomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('حلقة النور المباشرة'), findsOneWidget);
        expect(find.text('٦٧٪'), findsOneWidget);
        expect(find.textContaining('${now.year}'), findsOneWidget);
        expect(find.textContaining('١٤٤٦'), findsNothing);
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
              studentWeeklyPlansProvider('st-live-99')
                  .overrideWith((ref) => Stream.value(const [])),
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
      },
    );
  });
}
