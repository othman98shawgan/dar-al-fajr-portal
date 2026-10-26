import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: implementation_imports
import 'package:flutter_localizations/src/l10n/generated_date_localizations.dart'
    as date_localizations;

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    return const Locale('ar');
  }

  void setLocale(Locale newLocale) {
    state = newLocale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

bool isRtlLocale(Locale locale) {
  return locale.languageCode == 'ar' || locale.languageCode == 'he';
}

/// Configures date symbols across the app so the first day of the week
/// is Sunday (الأحد) in Arabic, consistent with Hebrew and English.
void configureAppDateSymbols() {
  final arDateSymbols = date_localizations.dateSymbols['ar'];
  if (arDateSymbols != null) {
    arDateSymbols.FIRSTDAYOFWEEK = 6; // (6 + 1) % 7 = 0 (Sunday)
  }
}
