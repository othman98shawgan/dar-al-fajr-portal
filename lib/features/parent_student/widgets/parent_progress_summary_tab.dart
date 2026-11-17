import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_tr.dart';
import '../models/parent_student_models.dart';
import 'parent_student_tokens.dart';

/// Tab 1 of `ParentStudentHomeScreen`: automated Quran memorization progress
/// KPIs, last recitation audio card, in-progress Surahs/Ajzaa, and completed Surahs cloud.
class ParentProgressSummaryTab extends StatefulWidget {
  final String langCode;
  final ChildPortalProfile child;
  final bool isDemoMode;

  const ParentProgressSummaryTab({
    super.key,
    required this.langCode,
    required this.child,
    required this.isDemoMode,
  });

  @override
  State<ParentProgressSummaryTab> createState() =>
      _ParentProgressSummaryTabState();
}

class _ParentProgressSummaryTabState extends State<ParentProgressSummaryTab> {
  bool _isPlayingLastRecitation = false;
  bool _showAllCompletedSurahs = false;
  bool _isReminderEnabled = false;

  @override
  Widget build(BuildContext context) {
    final langCode = widget.langCode;
    final child = widget.child;
    final topPadding = MediaQuery.paddingOf(context).top + 112 + 12;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 80 + 24;

    final displayedSurahs = _showAllCompletedSurahs
        ? child.completedSurahNames
        : child.completedSurahNames.take(38).toList();

    return ListView(
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: bottomPadding,
        left: 16,
        right: 16,
      ),
      children: [
        // 1. Motivational Banner Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ParentStudentTokens.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ParentStudentTokens.secondaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: ParentStudentTokens.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: ParentStudentTokens.secondaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: ParentStudentTokens.onSecondaryFixedVariant,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'إنجاز مبارك',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: ParentStudentTokens
                                      .onSecondaryFixedVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'محدث اليوم',
                          style: TextStyle(
                            fontSize: 11,
                            color: ParentStudentTokens.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13.5,
                              color: ParentStudentTokens.onSurface,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                        children: [
                          const TextSpan(text: 'ختم '),
                          TextSpan(
                            text: child.motivationalBannerHighlight,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ParentStudentTokens.primary,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' حتى الآن • ${child.motivationalBannerBody}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Top KPI Grid (2x2 Compact Bento)
        Row(
          children: [
            Expanded(
              child: _buildBentoStatCard(
                title: 'الصفحات المحفوظة',
                icon: Icons.menu_book_rounded,
                iconBg: ParentStudentTokens.surfaceContainer,
                iconColor: ParentStudentTokens.primary,
                mainValue: '${child.memorizedPagesCount}',
                unitLabel: 'صفحة',
                subtitle: 'من أصل 604 صفحة',
                progressFraction: child.memorizedPagesCount / 604.0,
                progressColor: ParentStudentTokens.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoStatCard(
                title: 'نسبة الإنجاز',
                icon: Icons.pie_chart_rounded,
                iconBg: ParentStudentTokens.primaryFixed,
                iconColor: ParentStudentTokens.primary,
                mainValue:
                    '${child.overallQuranPercentage.toStringAsFixed(1)}%',
                mainValueColor: ParentStudentTokens.primary,
                subtitle: 'من إجمالي المصحف الشريف',
                progressFraction: child.memorizedPagesCount / 604.0,
                progressColor: ParentStudentTokens.primaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBentoStatCard(
                title: 'السور المكتملة',
                icon: Icons.military_tech_rounded,
                iconBg: ParentStudentTokens.secondaryFixed,
                iconColor: ParentStudentTokens.secondary,
                mainValue: '${child.completedSurahsCount}',
                unitLabel: 'سورة',
                subtitle: 'من 114 سورة كريمة',
                progressFraction: child.surahsProgressFraction,
                progressColor: ParentStudentTokens.secondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoStatCard(
                title: 'الأجزاء المكتملة',
                icon: Icons.bookmark_added_rounded,
                iconBg: ParentStudentTokens.surfaceContainer,
                iconColor: ParentStudentTokens.tertiary,
                mainValue: '${child.completedJuzCount}',
                unitLabel: 'جزء تام',
                subtitle: child.completedJuzSubtitle,
                progressFraction: child.juzProgressFraction,
                progressColor: ParentStudentTokens.tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 3. Interactive Visual Progress Meter & Recitation Audio Feature
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                ParentStudentTokens.primary,
                ParentStudentTokens.primaryContainer,
              ],
              begin: AlignmentDirectional.centerEnd,
              end: AlignmentDirectional.centerStart,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ParentStudentTokens.primary.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.headphones_rounded,
                          color: ParentStudentTokens.primaryFixed,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'آخر تسميع مسجّل',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        child.lastRecitationWhen,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: ParentStudentTokens.primaryFixed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          setState(() {
                            _isPlayingLastRecitation =
                                !_isPlayingLastRecitation;
                          });
                        },
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            _isPlayingLastRecitation
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: ParentStudentTokens.primary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.lastRecitationTitle,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            child.lastRecitationNote,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          child.lastRecitationScore,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: ParentStudentTokens.secondaryFixed,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          child.lastRecitationDuration,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Card 2: In-Progress Surahs (السور قيد الحفظ)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ParentStudentTokens.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: ParentStudentTokens.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.cached_rounded,
                            color: ParentStudentTokens.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'السور قيد الحفظ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: ParentStudentTokens.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: ParentStudentTokens.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'جاري العمل',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ParentStudentTokens.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (child.inProgressSurahs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    trByLang(
                      langCode,
                      ar: 'لا توجد سور قيد الحفظ حاليًا.',
                      he: 'אין סורות בתהליך שינון כרגע.',
                      en: 'No Surahs currently in progress.',
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: ParentStudentTokens.outline,
                    ),
                  ),
                ),
              ...child.inProgressSurahs.map(
                (surah) => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ParentStudentTokens.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: ParentStudentTokens.primaryFixed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: ParentStudentTokens.onPrimaryFixed,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    surah.surahName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: ParentStudentTokens.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${surah.progressPercent}% (الآية ${surah.fromAyah} إلى ${surah.toAyah})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: ParentStudentTokens.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: surah.progressFraction,
                          minHeight: 10,
                          backgroundColor:
                              ParentStudentTokens.surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            ParentStudentTokens.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.edit_calendar_rounded,
                                  size: 14,
                                  color: ParentStudentTokens.outline,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'المتبقي: ${surah.remainingVerses} آية',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: ParentStudentTokens.outline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.event_available_rounded,
                                  size: 14,
                                  color: ParentStudentTokens.secondary,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'المتوقع: ${surah.expectedCompletionLabel}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: ParentStudentTokens.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 5. Card 3: In-Progress Ajzaa (الأجزاء قيد الحفظ)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ParentStudentTokens.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: ParentStudentTokens.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: ParentStudentTokens.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'الأجزاء قيد الحفظ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: ParentStudentTokens.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (child.inProgressAjzaa.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    trByLang(
                      langCode,
                      ar: 'لا توجد أجزاء قيد الحفظ حاليًا.',
                      he: 'אין חלקים בתהליך שינון כרגע.',
                      en: 'No Ajzaa currently in progress.',
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: ParentStudentTokens.outline,
                    ),
                  ),
                ),
              ...child.inProgressAjzaa.map((juz) {
                if (juz.isActive) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ParentStudentTokens.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.trip_origin_rounded,
                                      size: 18,
                                      color: ParentStudentTokens.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        juz.juzTitle,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: ParentStudentTokens.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${juz.progressPercent}% (${juz.completedPages} من ${juz.totalPages} صفحة)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: ParentStudentTokens.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: juz.progressFraction,
                              minHeight: 10,
                              backgroundColor:
                                  ParentStudentTokens.surfaceContainerHighest,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                ParentStudentTokens.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  juz.startedDateLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: ParentStudentTokens.outline,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'متبقي ${juz.remainingPages} صفحات فقط',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: ParentStudentTokens.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ParentStudentTokens.surface.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.radio_button_unchecked_rounded,
                              size: 18,
                              color: ParentStudentTokens.outline,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                juz.juzTitle,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: ParentStudentTokens.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ParentStudentTokens.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'قيد التحضير (0%)',
                          style: TextStyle(
                            fontSize: 11,
                            color: ParentStudentTokens.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 6. Card 4: Finished Surahs Tag Cloud (السور المكتملة)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ParentStudentTokens.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: ParentStudentTokens.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: ParentStudentTokens.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'السور المكتملة',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: ParentStudentTokens.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: ParentStudentTokens.primaryFixed,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${child.completedSurahsCount} سورة مُتقنة',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ParentStudentTokens.onPrimaryFixed,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.isDemoMode) ...[
                const SizedBox(height: 8),
                const Text(
                  'تشمل سورة الفاتحة وجزء عمّ كاملاً بفضل الله، مع ثبوت التلاوة وأحكام التجويد:',
                  style: TextStyle(
                    fontSize: 13,
                    color: ParentStudentTokens.outline,
                  ),
                ),
              ] else if (displayedSurahs.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  trByLang(
                    langCode,
                    ar: 'لم تُكتمل سور مسجّلة بعد.',
                    he: 'טרם הושלמו סורות רשומות.',
                    en: 'No completed Surahs recorded yet.',
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    color: ParentStudentTokens.outline,
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Emerald Tag Cloud
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...displayedSurahs.map(
                    (surahName) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: ParentStudentTokens.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        surahName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: ParentStudentTokens.primary,
                        ),
                      ),
                    ),
                  ),
                  if (child.completedSurahNames.length > 38)
                    Material(
                      color: _showAllCompletedSurahs
                          ? ParentStudentTokens.tertiaryContainer
                          : ParentStudentTokens.primary,
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {
                          setState(() {
                            _showAllCompletedSurahs = !_showAllCompletedSurahs;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _showAllCompletedSurahs
                                    ? 'تم عرض السور الـ ${child.completedSurahNames.length}'
                                    : '+${child.completedSurahNames.length - 38} سور أخرى',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                _showAllCompletedSurahs
                                    ? Icons.check_rounded
                                    : Icons.expand_more_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 7. Weekly Review Schedule Reminder
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ParentStudentTokens.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ParentStudentTokens.secondaryFixed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.event_repeat_rounded,
                        color: ParentStudentTokens.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'جلسة مراجعة الحزب الأخير',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ParentStudentTokens.onSurface,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'الخميس القادم بعد صلاة العصر',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: ParentStudentTokens.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: _isReminderEnabled
                    ? ParentStudentTokens.primaryFixed
                    : ParentStudentTokens.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      _isReminderEnabled = !_isReminderEnabled;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isReminderEnabled
                              ? 'تم تفعيل التذكير لجلسة مراجعة الخميس القادم'
                              : 'تم إلغاء التذكير',
                        ),
                        backgroundColor: ParentStudentTokens.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    child: Text(
                      _isReminderEnabled ? 'مفعّل ✓' : 'تذكير',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isReminderEnabled
                            ? ParentStudentTokens.onPrimaryFixed
                            : ParentStudentTokens.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBentoStatCard({
    required String title,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String mainValue,
    String? unitLabel,
    Color? mainValueColor,
    required String subtitle,
    required double progressFraction,
    required Color progressColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ParentStudentTokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ParentStudentTokens.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                mainValue,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: mainValueColor ?? ParentStudentTokens.onSurface,
                  height: 1.1,
                ),
              ),
              if (unitLabel != null) ...[
                const SizedBox(width: 4),
                Text(
                  unitLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: ParentStudentTokens.outline,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: ParentStudentTokens.outline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressFraction.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: ParentStudentTokens.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }
}
