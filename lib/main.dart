import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dar_al_fajr_portal/core/routing/app_router.dart';
import 'package:dar_al_fajr_portal/core/services/locale_provider.dart';
import 'package:dar_al_fajr_portal/core/theme/app_theme.dart';
import 'package:dar_al_fajr_portal/l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: DarAlFajrApp()));
}

class DarAlFajrApp extends ConsumerWidget {
  const DarAlFajrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isRtl = isRtlLocale(currentLocale);

    return MaterialApp.router(
      title: 'بوابة دار الفجر',
      debugShowCheckedModeBanner: false,
      theme: DarAlFajrTheme.lightTheme,
      routerConfig: appRouter,
      locale: currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
