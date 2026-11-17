import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations_tr.dart';
import '../../hifz/models/teacher_models.dart';
import '../../hifz/providers/teacher_providers.dart';
import '../models/parent_student_models.dart';
import '../providers/parent_student_providers.dart';
import 'parent_message_teacher_dialog.dart';
import 'parent_student_tokens.dart';

/// Tab 0 of `ParentStudentHomeScreen`: weekly arrival schedule, Hifz/Revision
/// homework card, teacher feedback audio pill, and daily revision checklist.
class ParentScheduleHomeworkTab extends ConsumerStatefulWidget {
  final String langCode;
  final ChildPortalProfile child;
  final bool isHomeworkSigned;

  const ParentScheduleHomeworkTab({
    super.key,
    required this.langCode,
    required this.child,
    required this.isHomeworkSigned,
  });

  @override
  ConsumerState<ParentScheduleHomeworkTab> createState() =>
      _ParentScheduleHomeworkTabState();
}

class _ParentScheduleHomeworkTabState
    extends ConsumerState<ParentScheduleHomeworkTab> {
  bool _isPlayingTeacherVoice = false;
  final Map<int, RevisionTaskStatus> _localRevisionStatusOverrides = {};

  @override
  Widget build(BuildContext context) {
    final langCode = widget.langCode;
    final child = widget.child;
    final isHomeworkSigned = widget.isHomeworkSigned;

    final topPadding = MediaQuery.paddingOf(context).top + 112 + 12;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 80 + 24;

    return ListView(
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: bottomPadding,
        left: 16,
        right: 16,
      ),
      children: [
        // 1. Child Quick Status Banner
        Container(
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
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                top: -24,
                left: -24,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color:
                        ParentStudentTokens.primaryFixed.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
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
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: ParentStudentTokens.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  child.groupName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: ParentStudentTokens.primary,
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
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ParentStudentTokens.primaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: ParentStudentTokens.onPrimaryFixed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'حضور ${child.attendancePercent}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: ParentStudentTokens.onPrimaryFixed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.school_rounded,
                                size: 16,
                                color: ParentStudentTokens.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  child.teacherName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: ParentStudentTokens.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            child.periodLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: ParentStudentTokens.outline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Motivational Micro-Streak Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: ParentStudentTokens.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.workspace_premium_rounded,
                                  color: ParentStudentTokens.secondary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    child.streakBannerTitle,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: ParentStudentTokens.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            child.streakDaysLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: ParentStudentTokens.secondary,
                            ),
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
        const SizedBox(height: 16),

        // 2. Card 1: Weekly Arrival Schedule (مواعيد الحضور هذا الأسبوع)
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ParentStudentTokens.primaryContainer
                                .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: ParentStudentTokens.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trByLang(
                                  langCode,
                                  ar: 'مواعيد الحضور هذا الأسبوع',
                                  he: 'זמני הגעה השבוע',
                                  en: 'Weekly Arrival Schedule',
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: ParentStudentTokens.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatParentAcademicWeekRange(
                                  DateTime.now(),
                                  langCode,
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: ParentStudentTokens.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            trByLang(
                              langCode,
                              ar: 'جميع مواعيد ${child.shortName} محدثة حسب جدول المركز',
                              he: 'כל המועדים מעודכנים',
                              en: 'All schedule slots are synced with center calendar',
                            ),
                          ),
                          backgroundColor: ParentStudentTokens.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.event_repeat_rounded,
                      color: ParentStudentTokens.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Schedule List Rows
              if (child.weeklySchedule.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    trByLang(
                      langCode,
                      ar: 'لا توجد مواعيد مسجّلة في الحلقات بعد.',
                      he: 'אין מועדים רשומים בקבוצות עדיין.',
                      en: 'No group or 1-on-1 arrival slots scheduled yet.',
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: ParentStudentTokens.outline,
                    ),
                  ),
                )
              else
                ...child.weeklySchedule.map(
                  (slot) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildScheduleSlotCard(slot),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Card 2: Current Weekly Assignment (واجب هذا الأسبوع)
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
              // Header with Rating Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ParentStudentTokens.primaryContainer
                                .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: ParentStudentTokens.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trByLang(
                                  langCode,
                                  ar: 'واجب هذا الأسبوع',
                                  he: 'מטלת השבוע',
                                  en: 'This Week\'s Assignment',
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: ParentStudentTokens.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                trByLang(
                                  langCode,
                                  ar: 'مقرر الإتقان والمراجعة الدورية',
                                  he: 'שינון וחזרה תקופתית',
                                  en: 'Hifz & Periodic Revision Syllabus',
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: ParentStudentTokens.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: ParentStudentTokens.primaryFixed,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 15,
                          color: ParentStudentTokens.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'تم التقييم',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: ParentStudentTokens.onPrimaryFixed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Visual Quran Milestone Progress Container
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ParentStudentTokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    // Item 1: New Memorization (الحفظ الجديد)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ParentStudentTokens.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: ParentStudentTokens.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'الحفظ الجديد',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: ParentStudentTokens.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  child.newHifzPagesLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: ParentStudentTokens.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  child.newHifzSurah,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: ParentStudentTokens.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  child.newHifzAyahRange,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: ParentStudentTokens.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: child.newHifzProgress,
                              minHeight: 8,
                              backgroundColor:
                                  ParentStudentTokens.surfaceContainerHigh,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                ParentStudentTokens.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  child.newHifzStatusLeft,
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
                                  child.newHifzStatusRight,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Item 2: Revision (المراجعة والتثبيت)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ParentStudentTokens.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
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
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: ParentStudentTokens
                                            .secondaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'المراجعة والتثبيت',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: ParentStudentTokens.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                child.revisionHizbLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: ParentStudentTokens.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  child.revisionSurah,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: ParentStudentTokens.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  child.revisionAyahRange,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: ParentStudentTokens.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: child.revisionProgress,
                              minHeight: 8,
                              backgroundColor:
                                  ParentStudentTokens.surfaceContainerHigh,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                ParentStudentTokens.secondaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  child.revisionStatusLeft,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: ParentStudentTokens.secondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  child.revisionStatusRight,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Overall Grade Ribbon
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: ParentStudentTokens.primaryFixed.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            color: ParentStudentTokens.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'درجة الإتقان الأسبوعية',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: ParentStudentTokens.primary,
                                  ),
                                ),
                                Text(
                                  child.weeklyGradeLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ParentStudentTokens.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        child.weeklyStarsCount,
                        (_) => const Icon(
                          Icons.star_rounded,
                          color: ParentStudentTokens.secondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Highlighted Teacher Note & Voice Note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ParentStudentTokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.format_quote_rounded,
                          color: ParentStudentTokens.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'ملاحظة المعلم (${child.teacherNoteAuthor}):',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: ParentStudentTokens.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: Text(
                        child.teacherNoteText,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.55,
                          color: ParentStudentTokens.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Audio Player Pill Micro-interaction
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ParentStudentTokens.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Material(
                                  color: _isPlayingTeacherVoice
                                      ? ParentStudentTokens.secondary
                                      : ParentStudentTokens.primary,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () {
                                      setState(() {
                                        _isPlayingTeacherVoice =
                                            !_isPlayingTeacherVoice;
                                      });
                                    },
                                    child: SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: Icon(
                                        _isPlayingTeacherVoice
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'توجيه صوتي من المعلم',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: ParentStudentTokens.onSurface,
                                        ),
                                      ),
                                      Text(
                                        'المدة: ${child.teacherVoiceDuration}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
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
                          // Waveform indicator bars
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildWaveBar(height: 12),
                              const SizedBox(width: 3),
                              _buildWaveBar(height: 20),
                              const SizedBox(width: 3),
                              _buildWaveBar(height: 8),
                              const SizedBox(width: 3),
                              _buildWaveBar(height: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Direct Follow-up Action CTA
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        ref
                            .read(acknowledgedHomeworkProvider.notifier)
                            .markAcknowledged(child.id);
                        try {
                          await ref
                              .read(parentStudentRepositoryProvider)
                              .acknowledgeHomework(
                                studentId: child.id,
                                assignmentId:
                                    child.firestoreAssignments.firstOrNull?.id,
                              );
                        } catch (_) {}

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              trByLang(
                                langCode,
                                ar: 'تم تأكيد الاطلاع وتوقيع واجب ${child.shortName} بنجاح!',
                                he: 'המטלה אושרה ונחתמה בהצלחה!',
                                en: 'Homework acknowledged and signed!',
                              ),
                            ),
                            backgroundColor: ParentStudentTokens.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isHomeworkSigned
                            ? ParentStudentTokens.tertiaryContainer
                            : ParentStudentTokens.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        isHomeworkSigned
                            ? Icons.task_alt_rounded
                            : Icons.verified_rounded,
                        size: 18,
                      ),
                      label: Text(
                        isHomeworkSigned
                            ? trByLang(
                                langCode,
                                ar: 'تم توقيع الواجب والاطلاع ✓',
                                he: 'המטלה נחתמה ✓',
                                en: 'Homework Signed ✓',
                              )
                            : trByLang(
                                langCode,
                                ar: 'تأكيد الاطلاع وتوقيع الواجب',
                                he: 'אישור וחתימה על המטלה',
                                en: 'Acknowledge & Sign Homework',
                              ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: ParentStudentTokens.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => showParentMessageTeacherSheet(
                        context: context,
                        langCode: langCode,
                        child: child,
                      ),
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.chat_outlined,
                          color: ParentStudentTokens.onSurfaceVariant,
                          size: 22,
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

        // 4. Card 3: Weekly Revision Plan & Student Self-Check
        _buildStudentWeeklyRevisionCard(
          context: context,
          langCode: langCode,
          child: child,
        ),
      ],
    );
  }

  Widget _buildStudentWeeklyRevisionCard({
    required BuildContext context,
    required String langCode,
    required ChildPortalProfile child,
  }) {
    final plans =
        ref.watch(studentWeeklyPlansProvider(child.id)).asData?.value ??
            const [];
    final activePlan = plans.firstOrNull;

    final tasks = activePlan?.dailyTasks ??
        List<DailyRevisionTask>.generate(7, (idx) {
          if (idx == 5 || idx == 6) {
            return DailyRevisionTask(dayIndex: idx, isRestDay: true);
          }
          return DailyRevisionTask(
            dayIndex: idx,
            isRestDay: false,
            targetType: RevisionTargetType.juz,
            juzNumber: 30 - (idx % 2),
            status: idx < 2
                ? RevisionTaskStatus.doneOnTime
                : RevisionTaskStatus.pending,
          );
        });

    const dayNamesAr = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    const dayNamesEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const dayNamesHe = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת'];

    String getDayName(int idx) {
      if (langCode == 'he') return dayNamesHe[idx % 7];
      if (langCode == 'en') return dayNamesEn[idx % 7];
      return dayNamesAr[idx % 7];
    }

    return Container(
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ParentStudentTokens.primaryContainer
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.checklist_rtl_rounded,
                  color: ParentStudentTokens.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trByLang(
                        langCode,
                        ar: 'خطة المراجعة الأسبوعية اليومية',
                        he: 'תוכנית חזרה שבועית יומית',
                        en: 'Weekly Daily Revision Plan',
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ParentStudentTokens.onSurface,
                      ),
                    ),
                    Text(
                      trByLang(
                        langCode,
                        ar: 'اضغط لتحديد إنجاز ورد المراجعة اليومي (تم بالوقت / تم متأخراً)',
                        he: 'סמן ביצוע משימת חזרה יומית (בזמן / באיחור)',
                        en: 'Mark daily revision tasks as Done on Time or Done Late',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: ParentStudentTokens.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tasks.map((task) {
            final effectiveStatus =
                _localRevisionStatusOverrides[task.dayIndex] ?? task.status;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: task.isRestDay
                    ? ParentStudentTokens.surfaceContainerLow
                    : ParentStudentTokens.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: ParentStudentTokens.surfaceContainerHigh),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: task.isRestDay
                                ? ParentStudentTokens.surfaceContainerHigh
                                : ParentStudentTokens.primaryFixed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            getDayName(task.dayIndex),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: task.isRestDay
                                  ? ParentStudentTokens.onSurfaceVariant
                                  : ParentStudentTokens.onPrimaryFixed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            task.displaySummary(langCode),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: task.isRestDay
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: task.isRestDay
                                  ? ParentStudentTokens.outline
                                  : ParentStudentTokens.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!task.isRestDay)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _localRevisionStatusOverrides[task.dayIndex] =
                                  RevisionTaskStatus.doneOnTime;
                            });
                            if (activePlan != null) {
                              ref
                                  .read(teacherControllerProvider.notifier)
                                  .updateDailyRevisionTaskStatus(
                                    plan: activePlan,
                                    dayIndex: task.dayIndex,
                                    status: RevisionTaskStatus.doneOnTime,
                                  );
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: effectiveStatus ==
                                      RevisionTaskStatus.doneOnTime
                                  ? ParentStudentTokens.primary
                                  : ParentStudentTokens.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              trByLang(
                                langCode,
                                ar: 'تم بالوقت',
                                he: 'בזמן',
                                en: 'Done',
                              ),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: effectiveStatus ==
                                        RevisionTaskStatus.doneOnTime
                                    ? Colors.white
                                    : ParentStudentTokens.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _localRevisionStatusOverrides[task.dayIndex] =
                                  RevisionTaskStatus.doneLate;
                            });
                            if (activePlan != null) {
                              ref
                                  .read(teacherControllerProvider.notifier)
                                  .updateDailyRevisionTaskStatus(
                                    plan: activePlan,
                                    dayIndex: task.dayIndex,
                                    status: RevisionTaskStatus.doneLate,
                                  );
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: effectiveStatus ==
                                      RevisionTaskStatus.doneLate
                                  ? ParentStudentTokens.secondary
                                  : ParentStudentTokens.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              trByLang(
                                langCode,
                                ar: 'تم متأخراً',
                                he: 'באיחור',
                                en: 'Late',
                              ),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: effectiveStatus ==
                                        RevisionTaskStatus.doneLate
                                    ? Colors.white
                                    : ParentStudentTokens.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWaveBar({required double height}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 4,
      height: _isPlayingTeacherVoice ? height + 4 : height,
      decoration: BoxDecoration(
        color: _isPlayingTeacherVoice
            ? ParentStudentTokens.secondary
            : ParentStudentTokens.primary,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _buildScheduleSlotCard(ChildScheduleSlot slot) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ParentStudentTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
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
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: slot.isCompleted
                            ? ParentStudentTokens.primaryFixedDim
                                .withValues(alpha: 0.30)
                            : ParentStudentTokens.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        slot.dayAbbrev,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: slot.isCompleted
                              ? ParentStudentTokens.primary
                              : ParentStudentTokens.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.dayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ParentStudentTokens.onSurface,
                            ),
                          ),
                          Text(
                            slot.dateLabel,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: ParentStudentTokens.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (slot.statusLabel.isNotEmpty &&
                  slot.statusLabel != slot.trackBadgeLabel) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: slot.isCompleted
                          ? ParentStudentTokens.primaryFixed
                          : ParentStudentTokens.surfaceContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          slot.isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.schedule_rounded,
                          size: 14,
                          color: slot.isCompleted
                              ? ParentStudentTokens.onPrimaryFixed
                              : ParentStudentTokens.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            slot.statusLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: slot.isCompleted
                                  ? ParentStudentTokens.onPrimaryFixed
                                  : ParentStudentTokens.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: slot.isTertiaryTrackBadge
                          ? ParentStudentTokens.tertiaryFixed
                          : ParentStudentTokens.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      slot.trackBadgeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: slot.isTertiaryTrackBadge
                            ? ParentStudentTokens.onTertiaryFixed
                            : ParentStudentTokens.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: slot.isOneOnOne
                          ? ParentStudentTokens.secondaryFixed
                          : ParentStudentTokens.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          slot.isOneOnOne
                              ? Icons.person_rounded
                              : Icons.groups_rounded,
                          size: 13,
                          color: slot.isOneOnOne
                              ? ParentStudentTokens.onSecondaryFixed
                              : ParentStudentTokens.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            slot.sessionModeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: slot.isOneOnOne
                                  ? ParentStudentTokens.onSecondaryFixed
                                  : ParentStudentTokens.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: ParentStudentTokens.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: ParentStudentTokens.outline,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          slot.arrivalTime,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ParentStudentTokens.onSurface,
                          ),
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
    );
  }
}
