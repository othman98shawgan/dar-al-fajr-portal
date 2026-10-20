import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dar_al_fajr_portal/core/services/locale_provider.dart';
import 'package:dar_al_fajr_portal/core/theme/app_theme.dart';
import 'package:dar_al_fajr_portal/features/auth/providers/auth_providers.dart';
import 'package:dar_al_fajr_portal/l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final appUserAsync = ref.watch(currentAppUserProvider);
    final appUser = appUserAsync.asData?.value;

    final isFirebaseActive = Firebase.apps.isNotEmpty;
    if (isFirebaseActive && (appUserAsync.isLoading || appUser == null)) {
      return const Scaffold(
        backgroundColor: DarAlFajrTheme.background,
        body: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: DarAlFajrTheme.primary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: l10n.switchLanguage,
            onSelected: (code) {
              ref.read(localeProvider.notifier).setLocale(Locale(code));
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'ar',
                child: Text('العربية (AR)'),
              ),
              PopupMenuItem(
                value: 'he',
                child: Text('עברית (HE)'),
              ),
              PopupMenuItem(
                value: 'en',
                child: Text('English (EN)'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'تسجيل الخروج',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.welcome,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: DarAlFajrTheme.primaryDark,
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appUser != null
                          ? 'مرحباً بك: ${appUser.fullName} (${appUser.email})'
                          : 'بوابة ولي الأمر والطالب (المرحلة 5)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: DarAlFajrTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Locale: ${currentLocale.languageCode.toUpperCase()} | Direction: ${isRtl ? "RTL (يمين إلى يسار)" : "LTR"}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: DarAlFajrTheme.accent,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(height: 32),
                    Text(
                      '${l10n.newHifz} / ${l10n.revision}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.check_circle,
                              color: DarAlFajrTheme.primary),
                          label: Text(l10n.present),
                        ),
                        Chip(
                          avatar: const Icon(Icons.access_time,
                              color: DarAlFajrTheme.accent),
                          label: Text(l10n.late),
                        ),
                        Chip(
                          avatar: const Icon(Icons.cancel, color: Colors.red),
                          label: Text(l10n.absent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
