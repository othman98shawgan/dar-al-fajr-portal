import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dar_al_fajr_portal/main.dart';

void main() {
  testWidgets('App smoke test and RTL directionality verification', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DarAlFajrApp()));
    await tester.pumpAndSettle();

    // Verify Arabic app title is rendered
    expect(find.text('بوابة دار الفجر'), findsWidgets);

    // Verify root Directionality is RTL for Arabic
    final directionality = tester.widget<Directionality>(
      find.byWidgetPredicate((widget) => widget is Directionality).first,
    );
    expect(directionality.textDirection, TextDirection.rtl);
  });
}
