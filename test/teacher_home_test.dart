import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dar_al_fajr_portal/core/models/surah_page_map.dart';
import 'package:dar_al_fajr_portal/features/hifz/models/teacher_models.dart';
import 'package:dar_al_fajr_portal/features/hifz/screens/teacher_home_screen.dart';
import 'package:dar_al_fajr_portal/features/hifz/screens/group_detail_screen.dart';
import 'package:dar_al_fajr_portal/features/hifz/screens/student_hifz_modal.dart';
import 'package:dar_al_fajr_portal/features/hifz/screens/attendance_logging_view.dart';

void main() {
  group('CenterQuranMap & 0-100 Scoring Engine Unit Tests', () {
    test('CenterQuranMap has all 114 Surahs and 653 total center pages', () {
      expect(CenterQuranMap.surahs.length, 114);
      expect(CenterQuranMap.totalCenterPages, 653);

      // Juz 30 Surahs (78 to 114) each count as 1 center page unit
      final juz30Surahs =
          CenterQuranMap.surahs.where((s) => s.id >= 78).toList();
      expect(juz30Surahs.length, 37);
      for (final s in juz30Surahs) {
        expect(s.isJuz30, isTrue);
        expect(s.centerPageCount, 1);
      }

      // Shared boundary page example: Surah 4 (An-Nisa: 77..106) and Surah 5 (Al-Ma'idah: 106..127)
      final anNisa = CenterQuranMap.getSurahById(4);
      final alMaidah = CenterQuranMap.getSurahById(5);
      expect(anNisa.pages.contains(106), isTrue);
      expect(alMaidah.pages.contains(106), isTrue);
    });

    test('GradingPenaltyConfig calculates 0-100 score and enforces 94 / 79 thresholds', () {
      const config = GradingPenaltyConfig(); // lafzi: 3, fath: 3, tataa: 0, page: 94, juz: 79

      // 2 lafzi (-6), 0 fath, 3 tataa (0) => 94
      final score94 = config.calculateScore(
        lafziCount: 2,
        fathCount: 0,
        tataaCount: 3,
      );
      expect(score94, 94);
      expect(config.isPassingScore(score: score94, isJuzExam: false), isTrue);
      expect(
        config.isPassingScore(
          score: score94,
          isJuzExam: false,
          forceRepeat: true,
        ),
        isFalse,
      );

      // 2 lafzi (-6), 1 fath (-3) => 91 (Fails page threshold 94, passes Juz threshold 79)
      final score91 = config.calculateScore(
        lafziCount: 2,
        fathCount: 1,
        tataaCount: 0,
      );
      expect(score91, 91);
      expect(config.isPassingScore(score: score91, isJuzExam: false), isFalse);
      expect(config.isPassingScore(score: score91, isJuzExam: true), isTrue);

      // Partial read unit has no numeric score
      const partialUnit = TasmeeRecitationUnit(
        unitType: RecitationUnitType.partialRead,
        surahId: 2,
        notes: 'قرأ نصف صفحة فقط',
      );
      expect(partialUnit.isGraded, isFalse);
      expect(partialUnit.computedScore(config), isNull);
    });
  });

  testWidgets('TeacherHomeScreen layout test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TeacherHomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('GroupDetailScreen tabs (Assignments, Revision Plan, Monthly Attendance)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: GroupDetailScreen(groupId: 'grp-hifz-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الواجبات والتسميع'), findsOneWidget);
    expect(find.text('خطة المراجعة'), findsOneWidget);
    expect(find.text('الحضور الشهري'), findsOneWidget);

    // Switch to Weekly Revision Plan tab
    await tester.tap(find.text('خطة المراجعة'));
    await tester.pumpAndSettle();
    expect(find.textContaining('أولوية المراجعة'), findsOneWidget);

    // Switch to Monthly Attendance tab
    await tester.tap(find.text('الحضور الشهري'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.calendar_month_rounded), findsWidgets);
  });

  testWidgets('StudentHifzModal 0-100 mistake counters & AttendanceLoggingView 4 statuses', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: StudentHifzModal(isFullScreenPage: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('خطأ لفظي'), findsOneWidget);
    expect(find.text('فتح (توقف)'), findsOneWidget);
    expect(find.text('تعتعة / استدراك'), findsOneWidget);

    // Test AttendanceLoggingView with Present, Late, Absent, Excused
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AttendanceLoggingView(groupId: 'grp-hifz-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تحضير الكل حاضر'), findsOneWidget);
    expect(find.text('معذور'), findsWidgets);
  });
}
