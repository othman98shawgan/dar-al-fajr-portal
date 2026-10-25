import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dar_al_fajr_portal/features/admin/screens/admin_shell_screen.dart';

void main() {
  testWidgets('AdminShellScreen layout test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AdminShellScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  });
}
