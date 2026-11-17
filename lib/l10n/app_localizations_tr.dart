import 'package:flutter/widgets.dart';

/// Resolves an inline trilingual string by [langCode] (`'ar'`, `'he'`, `'en'`).
///
/// Centralizes localization lookups across screens so screens do not duplicate
/// private `_tr(...)` helpers while remaining compatible with widget tests that
/// pump screens inside a bare `MaterialApp` without localization delegates.
String trByLang(
  String langCode, {
  required String ar,
  required String he,
  required String en,
}) {
  switch (langCode) {
    case 'he':
      return he;
    case 'en':
      return en;
    case 'ar':
    default:
      return ar;
  }
}

extension BuildContextTrL10n on BuildContext {
  String trLang(
    String langCode, {
    required String ar,
    required String he,
    required String en,
  }) =>
      trByLang(langCode, ar: ar, he: he, en: en);
}
