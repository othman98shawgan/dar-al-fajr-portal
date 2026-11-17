import 'package:dar_al_fajr_portal/features/admin/models/admin_models.dart';
import 'package:dar_al_fajr_portal/features/auth/models/app_user.dart';
import 'package:dar_al_fajr_portal/features/auth/providers/auth_providers.dart';
import 'package:dar_al_fajr_portal/features/hifz/models/teacher_models.dart';
import 'package:dar_al_fajr_portal/features/hifz/providers/teacher_providers.dart';
import 'package:dar_al_fajr_portal/features/parent_student/providers/parent_student_providers.dart';
import 'package:dar_al_fajr_portal/features/parent_student/screens/parent_student_home_screen.dart';
import 'package:dar_al_fajr_portal/features/parent_student/widgets/parent_student_tokens.dart';
import 'package:dar_al_fajr_portal/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Parent/Student Live Data & Dynamic Date Helpers', () {
    test('Academic week date helpers compute dynamic Sun-Thu ranges', () {
      // Tuesday Nov 17, 2026 -> Sunday Nov 15 .. Thursday Nov 19
      final midMonth = DateTime(2026, 11, 17);
      expect(
        formatParentAcademicWeekRange(midMonth, 'ar'),
        'الأسبوع الدراسي الحالي (15 - 19 نوفمبر)',
      );
      expect(
        formatParentAcademicWeekRange(midMonth, 'en'),
        'Current Academic Week (Nov 15 - 19)',
      );
      expect(formatParentWeekDayLabel(midMonth, 0, 'ar'), '15 نوفمبر');
      expect(formatParentWeekDayLabel(midMonth, 4, 'en'), 'Nov 19');

      // Tuesday Mar 31, 2026 -> Sunday Mar 29 .. Thursday Apr 2 (cross-month)
      final crossMonth = DateTime(2026, 3, 31);
      expect(
        formatParentAcademicWeekRange(crossMonth, 'en'),
        'Current Academic Week (Mar 29 - Apr 2)',
      );
      expect(
        formatParentAcademicWeekRange(crossMonth, 'ar'),
        'الأسبوع الدراسي الحالي (29 مارس - 2 أبريل)',
      );
    });

    testWidgets(
      'ParentStudentHomeScreen renders only live Firestore children without demo leakage and switches children cleanly',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        const parentUser = AppUser(
          uid: 'parent-live-1',
          email: 'parent@daralfajr.org',
          fullName: 'عبد الله الحربي',
          role: UserRole.parent,
        );

        final child1 = StudentProfile(
          id: 'st-live-1',
          fullName: 'طارق عبد الله الحربي',
          parentId: 'parent-live-1',
          memorizedPages: List<int>.generate(25, (i) => i + 580),
          completedSurahs: const [1, 112, 113, 114],
          completedJuz: const [30],
        );

        final child2 = StudentProfile(
          id: 'st-live-2',
          fullName: 'سارة عبد الله الحربي',
          parentId: 'parent-live-1',
          memorizedPages: List<int>.generate(12, (i) => i + 590),
          completedSurahs: const [1, 114],
          completedJuz: const [],
        );

        final now = DateTime.now();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentAppUserProvider
                  .overrideWith((ref) => Stream.value(parentUser)),
              parentChildrenStreamProvider
                  .overrideWith((ref) => Stream.value([child1, child2])),
              childEnrollmentsStreamProvider('st-live-1').overrideWith(
                (ref) => Stream.value(const [
                  Enrollment(
                    id: 'enr-live-1',
                    studentId: 'st-live-1',
                    studentName: 'طارق عبد الله الحربي',
                    groupId: 'grp-live-1',
                    groupName: 'حلقة الفجر الحية',
                    track: CenterTrack.hifz,
                    groupArrivalTime: '17:30',
                  ),
                ]),
              ),
              childEnrollmentsStreamProvider('st-live-2').overrideWith(
                (ref) => Stream.value(const [
                  Enrollment(
                    id: 'enr-live-2',
                    studentId: 'st-live-2',
                    studentName: 'سارة عبد الله الحربي',
                    groupId: 'grp-live-2',
                    groupName: 'حلقة النور للفتيات',
                    track: CenterTrack.readingTajweed,
                    oneOnOneSlotTime: '18:15',
                  ),
                ]),
              ),
              childAttendanceStreamProvider('st-live-1').overrideWith(
                (ref) => Stream.value([
                  AttendanceLog(
                    id: 'att-1',
                    groupId: 'grp-live-1',
                    studentId: 'st-live-1',
                    teacherId: 't-1',
                    sessionDate: now,
                    status: AttendanceStatus.present,
                  ),
                  AttendanceLog(
                    id: 'att-2',
                    groupId: 'grp-live-1',
                    studentId: 'st-live-1',
                    teacherId: 't-1',
                    sessionDate: now,
                    status: AttendanceStatus.late,
                  ),
                  AttendanceLog(
                    id: 'att-3',
                    groupId: 'grp-live-1',
                    studentId: 'st-live-1',
                    teacherId: 't-1',
                    sessionDate: now,
                    status: AttendanceStatus.absent,
                  ),
                ]),
              ),
              childAttendanceStreamProvider('st-live-2').overrideWith(
                (ref) => Stream.value([
                  AttendanceLog(
                    id: 'att-4',
                    groupId: 'grp-live-2',
                    studentId: 'st-live-2',
                    teacherId: 't-2',
                    sessionDate: now,
                    status: AttendanceStatus.present,
                  ),
                ]),
              ),
              childAssignmentsStreamProvider('st-live-1').overrideWith(
                (ref) => Stream.value([
                  HifzAssignment(
                    id: 'asg-1',
                    studentId: 'st-live-1',
                    studentName: 'طارق عبد الله الحربي',
                    groupId: 'grp-live-1',
                    teacherId: 't-1',
                    type: AssignmentType.newHifz,
                    surahId: 31,
                    surahName: 'لقمان',
                    fromAyah: 1,
                    toAyah: 19,
                    grade: EvaluationGrade.excellent,
                    score: 96,
                    teacherNotes: 'أداء متقن في الغنة',
                    assignedAt: now,
                  ),
                  HifzAssignment(
                    id: 'asg-2',
                    studentId: 'st-live-1',
                    studentName: 'طارق عبد الله الحربي',
                    groupId: 'grp-live-1',
                    teacherId: 't-1',
                    type: AssignmentType.revision,
                    surahId: 69,
                    surahName: 'الحاقة',
                    fromAyah: 1,
                    toAyah: 30,
                    juzNumber: 29,
                    grade: EvaluationGrade.good,
                    assignedAt: now,
                  ),
                ]),
              ),
              childAssignmentsStreamProvider('st-live-2').overrideWith(
                (ref) => Stream.value([
                  HifzAssignment(
                    id: 'asg-3',
                    studentId: 'st-live-2',
                    studentName: 'سارة عبد الله الحربي',
                    groupId: 'grp-live-2',
                    teacherId: 't-2',
                    type: AssignmentType.newHifz,
                    surahId: 77,
                    surahName: 'المرسلات',
                    fromAyah: 1,
                    toAyah: 20,
                    grade: EvaluationGrade.good,
                    score: 90,
                    teacherNotes: 'مواصلة التلاوة اليومية',
                    assignedAt: now,
                  ),
                ]),
              ),
              studentWeeklyPlansProvider('st-live-1')
                  .overrideWith((ref) => Stream.value(const [])),
              studentWeeklyPlansProvider('st-live-2')
                  .overrideWith((ref) => Stream.value(const [])),
            ],
            child: const MaterialApp(
              locale: Locale('ar'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: ParentStudentHomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Only live children appear in child switcher; demo siblings never leak
        expect(find.text('بوابة ولي الأمر'), findsOneWidget);
        expect(find.text('طارق'), findsOneWidget);
        expect(find.text('سارة'), findsOneWidget);
        expect(find.text('إبراهيم'), findsNothing);
        expect(find.text('يوسف'), findsNothing);
        expect(find.text('مريم'), findsNothing);

        // No hardcoded Oct demo calendar date or Hijri year text
        expect(find.textContaining('١٨ - ٢٢ أكتوبر'), findsNothing);
        expect(find.textContaining('١٨ أكتوبر'), findsNothing);
        expect(find.textContaining('1446هـ'), findsNothing);
        expect(
          find.text(formatParentAcademicWeekRange(now, 'ar')),
          findsOneWidget,
        );

        // Child 1 live schedule, attendance (2/3 = 67%), Hifz & Revision cards
        expect(find.text('حلقة الفجر الحية'), findsWidgets);
        expect(find.text('17:30'), findsWidgets);
        expect(find.text('حضور 67%'), findsOneWidget);
        expect(find.text('سورة لقمان'), findsOneWidget);
        expect(find.text('سورة الحاقة'), findsOneWidget);
        expect(find.text('"أداء متقن في الغنة"'), findsOneWidget);

        // Check Progress Summary Tab for Child 1 live KPIs (no demo narrative)
        await tester.tap(find.text('ملخص التقدم'));
        await tester.pumpAndSettle();
        expect(find.text('25'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        expect(
          find.text(
            'تشمل سورة الفاتحة وجزء عمّ كاملاً بفضل الله، مع ثبوت التلاوة وأحكام التجويد:',
          ),
          findsNothing,
        );

        // Switch to Child 2 ('سارة') and check live updates across both tabs
        await tester.tap(find.text('سارة'));
        await tester.pumpAndSettle();
        expect(find.text('12'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);

        await tester.tap(find.text('الجدول والواجبات'));
        await tester.pumpAndSettle();
        expect(find.text('حلقة النور للفتيات'), findsWidgets);
        expect(find.text('18:15'), findsWidgets);
        expect(find.text('حضور 100%'), findsOneWidget);
        expect(find.text('سورة المرسلات'), findsOneWidget);
      },
    );

    testWidgets(
      'Student role renders Student Portal title with own live profile',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        const studentUser = AppUser(
          uid: 'u-st-1',
          email: 'zaid@daralfajr.org',
          fullName: 'زيد المنصور',
          role: UserRole.student,
        );
        const selfProfile = StudentProfile(
          id: 'st-self-1',
          fullName: 'زيد المنصور',
          parentId: 'p-1',
          userId: 'u-st-1',
          memorizedPages: [600, 601, 602, 603, 604],
          completedSurahs: [1, 112, 113, 114],
          completedJuz: [],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentAppUserProvider
                  .overrideWith((ref) => Stream.value(studentUser)),
              parentChildrenStreamProvider
                  .overrideWith((ref) => Stream.value([selfProfile])),
              childEnrollmentsStreamProvider('st-self-1')
                  .overrideWith((ref) => Stream.value(const [])),
              childAttendanceStreamProvider('st-self-1')
                  .overrideWith((ref) => Stream.value(const [])),
              childAssignmentsStreamProvider('st-self-1')
                  .overrideWith((ref) => Stream.value(const [])),
              studentWeeklyPlansProvider('st-self-1')
                  .overrideWith((ref) => Stream.value(const [])),
            ],
            child: const MaterialApp(
              locale: Locale('ar'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: ParentStudentHomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('بوابة الطالب'), findsOneWidget);
        expect(find.text('زيد'), findsOneWidget);
        expect(find.text('إبراهيم'), findsNothing);
      },
    );
  });
}
