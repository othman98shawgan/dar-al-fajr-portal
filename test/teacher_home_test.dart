import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dar_al_fajr_portal/features/hifz/screens/teacher_home_screen.dart';

void main() {
  testWidgets('TeacherHomeScreen layout test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
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
}
