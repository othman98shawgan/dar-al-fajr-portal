import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/locale_provider.dart';
import '../../../core/theme/app_theme.dart';

/// Placeholder for AttendanceLoggingView — awaiting Google Stitch UI code.
class AttendanceLoggingView extends ConsumerWidget {
  final String groupId;

  const AttendanceLoggingView({
    super.key,
    this.groupId = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isRtl = isRtlLocale(currentLocale);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: DarAlFajrTheme.background,
        appBar: AppBar(
          backgroundColor: DarAlFajrTheme.primary,
          title: Text('رصد الحضور ($groupId)'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.how_to_reg_rounded,
                  size: 56,
                  color: DarAlFajrTheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'شاشة رصد الحضور ($groupId)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'بانتظار كود Google Stitch لشاشة AttendanceLoggingView (Screen 6).',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
