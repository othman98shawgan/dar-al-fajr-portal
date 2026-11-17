import 'package:dar_al_fajr_portal/features/auth/screens/login_screen.dart';
import 'package:dar_al_fajr_portal/features/hifz/screens/attendance_logging_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'LoginScreen switches languages cleanly via trByLang and gates Dev Options to debug mode',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Default Arabic via shared trByLang
      expect(find.text('تسجيل الدخول للمتابعة'), findsOneWidget);

      // Switch to English
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in to continue'), findsOneWidget);

      // Switch to Hebrew
      await tester.tap(find.text('עברית'));
      await tester.pumpAndSettle();
      expect(find.text('התחבר כדי להמשיך'), findsOneWidget);

      // Developer options button is available in debug test mode and shows 1-Click Seed
      final devBtn = find.byIcon(Icons.terminal_rounded);
      expect(devBtn, findsOneWidget);
      await tester.tap(devBtn);
      await tester.pumpAndSettle();
      expect(find.text('אתחול נתוני דמו (1-Click Seed)'), findsOneWidget);
    },
  );

  testWidgets('AttendanceLoggingView initializes with today date (DateTime.now)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AttendanceLoggingView(groupId: 'grp-hifz-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final now = DateTime.now();
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String toAr(String s) {
      var out = s;
      for (var i = 0; i < western.length; i++) {
        out = out.replaceAll(western[i], eastern[i]);
      }
      return out;
    }

    final expectedDate = toAr(
      '${now.day.toString().padLeft(2, '0')} / ${now.month.toString().padLeft(2, '0')} / ${now.year}',
    );
    expect(find.text(expectedDate), findsOneWidget);
  });
}
