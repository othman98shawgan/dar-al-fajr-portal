import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dar_al_fajr_portal/features/admin/models/admin_models.dart';
import 'package:dar_al_fajr_portal/features/parent_student/providers/parent_student_providers.dart';
import 'package:dar_al_fajr_portal/features/parent_student/screens/parent_student_home_screen.dart';
import 'package:dar_al_fajr_portal/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'ParentStudentHomeScreen renders Schedule & Homework and Progress Summary tabs',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
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

      // Header & child switcher
      expect(find.text('بوابة ولي الأمر'), findsOneWidget);
      expect(find.text('إبراهيم'), findsOneWidget);
      expect(find.text('يوسف'), findsOneWidget);
      expect(find.text('مريم'), findsOneWidget);

      // Default tab is Tab 0: الجدول والواجبات (Schedule & Homework)
      expect(find.text('مواعيد الحضور هذا الأسبوع'), findsOneWidget);
      expect(find.text('واجب هذا الأسبوع'), findsOneWidget);

      // Switch to Tab 1: ملخص التقدم (Progress Summary)
      await tester.tap(find.text('ملخص التقدم'));
      await tester.pumpAndSettle();

      expect(find.text('إنجاز مبارك'), findsOneWidget);
      expect(find.text('الصفحات المحفوظة'), findsOneWidget);
      expect(find.text('نسبة الإنجاز'), findsOneWidget);
      expect(find.text('السور قيد الحفظ'), findsOneWidget);
      expect(find.text('الأجزاء قيد الحفظ'), findsOneWidget);
    },
  );

  testWidgets(
    'ParentStudentHomeScreen renders without RenderFlex overflow on narrow 360px mobile screens across children & tabs',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
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

      for (final childName in ['إبراهيم', 'يوسف', 'مريم']) {
        await tester.tap(find.text(childName));
        await tester.pumpAndSettle();
        // Scroll Tab 0 to ensure schedule slots & weekly revision card paint at 360px
        await tester.drag(find.byType(ListView).first, const Offset(0, -600));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView).first, const Offset(0, 600));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('ملخص التقدم'));
      await tester.pumpAndSettle();
      expect(find.text('الصفحات المحفوظة'), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -700));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).last, const Offset(0, -700));
      await tester.pumpAndSettle();
      expect(find.text('السور المكتملة'), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -700));
      await tester.pumpAndSettle();
      expect(find.text('جلسة مراجعة الحزب الأخير'), findsOneWidget);
    },
  );

  testWidgets(
    'Schedule slot card shows group name and days cleanly without duplicating track category at the end',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            childEnrollmentsStreamProvider('st-1042').overrideWith(
              (ref) => Stream.value(const [
                Enrollment(
                  id: 'enr-slot-1',
                  studentId: 'st-1042',
                  studentName: 'إبراهيم طه عثمان',
                  groupId: 'grp-hifz-1',
                  groupName: 'حلقة أبي بكر الصديق للحفظ',
                  track: CenterTrack.hifz,
                  groupArrivalTime: 'الأحد والثلاثاء والخميس 16:30',
                ),
              ]),
            ),
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

      expect(find.text('حلقة أبي بكر الصديق للحفظ'), findsWidgets);
      expect(find.text('الأحد والثلاثاء والخميس 16:30'), findsWidgets);
      // 1 in child summary banner + 1 in schedule card bottom badge (top-end duplicate removed)
      expect(find.text('مسار الحفظ والتسميع'), findsNWidgets(2));
      expect(find.text('حلقة جماعية'), findsOneWidget);
    },
  );
}
