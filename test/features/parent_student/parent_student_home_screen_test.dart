import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
