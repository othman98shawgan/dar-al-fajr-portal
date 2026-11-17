import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_tr.dart';
import 'teacher_home_models.dart';

class TeacherWelcomeStatCard extends StatelessWidget {
  final String langCode;
  final String displayTeacherName;
  final int activeGroupsCount;
  final int totalStudentsCount;
  final int? masteryPercentage;
  final bool isDemoFallback;

  const TeacherWelcomeStatCard({
    super.key,
    required this.langCode,
    required this.displayTeacherName,
    required this.activeGroupsCount,
    required this.totalStudentsCount,
    required this.masteryPercentage,
    required this.isDemoFallback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TeacherHomeTokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [TeacherHomeTokens.primary, TeacherHomeTokens.primaryContainer],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: TeacherHomeTokens.primaryContainer,
                              shape: BoxShape.circle,
                              border: Border.all(color: TeacherHomeTokens.surfaceContainerLowest, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  trByLang(
                                    langCode,
                                    ar: 'مرحباً، $displayTeacherName',
                                    he: 'שלום, $displayTeacherName',
                                    en: 'Welcome, $displayTeacherName',
                                  ),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: TeacherHomeTokens.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, color: TeacherHomeTokens.secondary, size: 18),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatTeacherCurrentDate(DateTime.now(), langCode),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: TeacherHomeTokens.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isDemoFallback) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: TeacherHomeTokens.secondaryFixed,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, size: 16, color: TeacherHomeTokens.onSecondaryFixed),
                      const SizedBox(width: 4),
                      Text(
                        trByLang(langCode, ar: '١٤ يوماً التزام', he: '14 ימי התמדה', en: '14d Streak'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: TeacherHomeTokens.onSecondaryFixed,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _VitalStatBox(
                  value: formatTeacherNum(activeGroupsCount, langCode),
                  label: trByLang(langCode, ar: 'حلقات', he: 'קבוצות', en: 'Groups'),
                  valueColor: TeacherHomeTokens.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _VitalStatBox(
                  value: formatTeacherNum(totalStudentsCount, langCode),
                  label: trByLang(langCode, ar: 'طلاب', he: 'תלמידים', en: 'Students'),
                  valueColor: TeacherHomeTokens.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _VitalStatBox(
                  value: masteryPercentage != null
                      ? '${formatTeacherNum(masteryPercentage!, langCode)}${langCode == 'ar' ? '٪' : '%'}'
                      : (isDemoFallback ? (langCode == 'ar' ? '٩٦٪' : '96%') : '—'),
                  label: trByLang(langCode, ar: 'نسبة الإتقان', he: 'אחוז שליטה', en: 'Mastery Rate'),
                  valueColor: TeacherHomeTokens.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VitalStatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _VitalStatBox({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TeacherHomeTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: valueColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: TeacherHomeTokens.onSurfaceVariant,
                  fontSize: 11,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
