import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: implementation_imports
import 'package:flutter_localizations/src/l10n/generated_date_localizations.dart'
    as date_localizations;

import '../../features/auth/models/app_user.dart';
import '../../features/auth/providers/auth_providers.dart';

class LocaleNotifier extends Notifier<Locale> {
  String? _lastSyncedUid;

  @override
  Locale build() {
    ref.listen<AsyncValue<AppUser?>>(currentAppUserProvider, (prev, next) {
      final user = next.asData?.value;
      if (user == null) {
        _lastSyncedUid = null;
        return;
      }
      if (_lastSyncedUid != user.uid) {
        _lastSyncedUid = user.uid;
        final lang = user.preferredLanguage.trim().toLowerCase();
        if ((lang == 'ar' || lang == 'he' || lang == 'en') &&
            state.languageCode != lang) {
          state = Locale(lang);
        }
      }
    });
    return const Locale('ar');
  }

  Future<void> setLocale(Locale newLocale, {bool persist = true}) async {
    state = newLocale;
    if (!persist || Firebase.apps.isEmpty) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(
            {'preferredLanguage': newLocale.languageCode},
            SetOptions(merge: true),
          );
    } catch (_) {
      // Non-fatal: UI locale already updated locally
    }
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
