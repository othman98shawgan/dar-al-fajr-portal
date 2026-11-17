import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_tr.dart';
import '../models/teacher_models.dart';
import 'group_detail_models.dart';

class GroupFilterAndOrderingControls extends StatelessWidget {
  final String langCode;
  final int totalCount;
  final int newHifzCount;
  final int revisionCount;
  final int pendingCount;
  final bool orderByDate;
  final AssignmentFilterTab activeFilter;
  final ValueChanged<bool> onOrderChanged;
  final ValueChanged<AssignmentFilterTab> onFilterSelected;

  const GroupFilterAndOrderingControls({
    super.key,
    required this.langCode,
    required this.totalCount,
    required this.newHifzCount,
    required this.revisionCount,
    required this.pendingCount,
    required this.orderByDate,
    required this.activeFilter,
    required this.onOrderChanged,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                trByLang(
                  langCode,
                  ar: 'قائمة الطلاب والواجبات المقررة',
                  he: 'רשימת תלמידים ומטלות',
                  en: 'Students & Assigned Homework',
                ),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: GroupDetailTokens.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: GroupDetailTokens.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => onOrderChanged(false),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: !orderByDate ? GroupDetailTokens.surfaceContainerLowest : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trByLang(langCode, ar: 'حسب الطالب', he: 'לפי תלמיד', en: 'By Student'),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: !orderByDate ? GroupDetailTokens.primary : GroupDetailTokens.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => onOrderChanged(true),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: orderByDate ? GroupDetailTokens.surfaceContainerLowest : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trByLang(langCode, ar: 'حسب التاريخ', he: 'לפי תאריך', en: 'By Date'),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: orderByDate ? GroupDetailTokens.primary : GroupDetailTokens.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GroupFilterPillButton(
                label: trByLang(langCode, ar: 'الكل', he: 'הכל', en: 'All'),
                countLabel: '$totalCount',
                isSelected: activeFilter == AssignmentFilterTab.all,
                onTap: () => onFilterSelected(AssignmentFilterTab.all),
              ),
              const SizedBox(width: 8),
              GroupFilterPillButton(
                label: trByLang(langCode, ar: 'من تبقى فقط (في الانتظار)', he: 'ממתינים בלבד', en: 'Pending Only'),
                countLabel: '$pendingCount',
                dotColor: GroupDetailTokens.secondaryContainer,
                isWarningAccent: true,
                isSelected: activeFilter == AssignmentFilterTab.pending,
                onTap: () => onFilterSelected(AssignmentFilterTab.pending),
              ),
              const SizedBox(width: 8),
              GroupFilterPillButton(
                label: trByLang(langCode, ar: 'حفظ جديد', he: 'שינון חדש', en: 'New Hifz'),
                countLabel: '$newHifzCount',
                dotColor: GroupDetailTokens.primary,
                isSelected: activeFilter == AssignmentFilterTab.newHifz,
                onTap: () => onFilterSelected(AssignmentFilterTab.newHifz),
              ),
              const SizedBox(width: 8),
              GroupFilterPillButton(
                label: trByLang(langCode, ar: 'مراجعة واختبار جزء', he: 'חזרה ומבחן ג׳וז', en: 'Juz Revision'),
                countLabel: '$revisionCount',
                dotColor: GroupDetailTokens.secondary,
                isSelected: activeFilter == AssignmentFilterTab.revision,
                onTap: () => onFilterSelected(AssignmentFilterTab.revision),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GroupAssignmentCard extends StatelessWidget {
  final String langCode;
  final AssignmentCardItem card;
  final VoidCallback onShowStats;
  final VoidCallback onEditHomework;
  final VoidCallback onEvaluateNow;

  const GroupAssignmentCard({
    super.key,
    required this.langCode,
    required this.card,
    required this.onShowStats,
    required this.onEditHomework,
    required this.onEvaluateNow,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = card.grade == EvaluationGrade.pending && !card.isPartialRead;
    final isRevision = card.assignmentType == AssignmentType.revision;
    final sideBarColor = isPending
        ? GroupDetailTokens.secondaryContainer
        : (isRevision ? GroupDetailTokens.secondary : GroupDetailTokens.primary);

    return Container(
      decoration: BoxDecoration(
        color: GroupDetailTokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(
            top: 0,
            bottom: 0,
            start: 0,
            width: 6,
            child: Container(color: sideBarColor),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: sideBarColor.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              card.initial,
                              style: TextStyle(color: sideBarColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.studentName,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: GroupDetailTokens.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  card.timeSubtitle,
                                  style: TextStyle(
                                    color: card.isPendingTimeAlert
                                        ? GroupDetailTokens.secondary
                                        : GroupDetailTokens.primary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPending ? GroupDetailTokens.secondaryFixed : GroupDetailTokens.primaryFixed,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        card.gradeBadgeLabel,
                        style: TextStyle(
                          color: isPending
                              ? GroupDetailTokens.onSecondaryFixedVariant
                              : GroupDetailTokens.onPrimaryFixed,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GroupDetailTokens.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              card.rangeTitle,
                              style: TextStyle(
                                color: isRevision ? GroupDetailTokens.secondary : GroupDetailTokens.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            card.assignmentBadgeLabel,
                            style: const TextStyle(color: GroupDetailTokens.onSurfaceVariant, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: card.progressFactor,
                          minHeight: 6,
                          backgroundColor: GroupDetailTokens.surfaceContainerHigh,
                          valueColor: AlwaysStoppedAnimation<Color>(sideBarColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  card.feedbackText,
                  style: const TextStyle(color: GroupDetailTokens.onSurfaceVariant, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: onShowStats,
                      icon: const Icon(Icons.insights_rounded, size: 16),
                      label: Text(
                        trByLang(langCode, ar: 'إحصائيات الطالب والأجزاء', he: 'סטטיסטיקת תלמיד', en: 'Student Stats'),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onEditHomework,
                          icon: const Icon(Icons.edit_calendar_rounded, size: 15),
                          label: Text(
                            trByLang(langCode, ar: 'تعديل الواجب', he: 'ערוך מטלה', en: 'Edit Homework'),
                            style: const TextStyle(fontSize: 11.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: onEvaluateNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GroupDetailTokens.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.mic_rounded, size: 16),
                          label: Text(
                            isPending
                                ? trByLang(langCode, ar: 'تسميع الآن', he: 'שינון עכשיו', en: 'Tasmee Now')
                                : trByLang(langCode, ar: 'تعديل التسميع', he: 'ערוך הערכה', en: 'Edit Evaluation'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
