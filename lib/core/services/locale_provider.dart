import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
