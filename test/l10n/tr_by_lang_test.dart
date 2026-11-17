import 'package:dar_al_fajr_portal/l10n/app_localizations_tr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('trByLang shared localization helper', () {
    test('returns exact translation for ar, he, and en', () {
      expect(
        trByLang('ar', ar: 'مرحبا', he: 'שלום', en: 'Hello'),
        'مرحبا',
      );
      expect(
        trByLang('he', ar: 'مرحبا', he: 'שלום', en: 'Hello'),
        'שלום',
      );
      expect(
        trByLang('en', ar: 'مرحبا', he: 'שלום', en: 'Hello'),
        'Hello',
      );
    });

    test('falls back to Arabic for unknown language codes', () {
      expect(
        trByLang('fr', ar: 'مرحبا', he: 'שלום', en: 'Hello'),
        'مرحبا',
      );
      expect(
        trByLang('', ar: 'مرحبا', he: 'שלום', en: 'Hello'),
        'مرحبا',
      );
    });

    testWidgets('BuildContextTrL10n extension delegates to trByLang',
        (WidgetTester tester) async {
      late String capturedHe;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedHe = context.trLang('he', ar: 'أ', he: 'ב', en: 'C');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(capturedHe, 'ב');
    });
  });
}
