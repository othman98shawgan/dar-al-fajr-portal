import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_tr.dart';
import 'group_detail_models.dart';

class GroupSummaryHeader extends StatelessWidget {
  final String langCode;
  final String groupTitle;
  final String groupTrackSubtitle;
  final bool isHifzGroup;
  final GroupModuleTab effectiveTab;
  final VoidCallback onToggleSearch;
  final ValueChanged<GroupModuleTab> onTabSelected;

  const GroupSummaryHeader({
    super.key,
    required this.langCode,
    required this.groupTitle,
    required this.groupTrackSubtitle,
    required this.isHifzGroup,
    required this.effectiveTab,
    required this.onToggleSearch,
    required this.onTabSelected,
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
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: GroupDetailTokens.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.groups_rounded, color: GroupDetailTokens.primary, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupTrackSubtitle,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: GroupDetailTokens.onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          groupTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: GroupDetailTokens.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (effectiveTab == GroupModuleTab.assignments || effectiveTab == GroupModuleTab.studentsRoster)
              Material(
                color: GroupDetailTokens.surfaceContainer,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onToggleSearch,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.search_rounded, color: GroupDetailTokens.onSurfaceVariant, size: 20),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: GroupDetailTokens.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: isHifzGroup
              ? Row(
                  children: [
                    _ModuleTabButton(
                      stacked: true,
                      label: trByLang(langCode, ar: 'قائمة الطلاب', he: 'רשימת תלמידים', en: 'Students Roster'),
                      icon: Icons.groups_rounded,
                      isSelected: effectiveTab == GroupModuleTab.studentsRoster,
                      onTap: () => onTabSelected(GroupModuleTab.studentsRoster),
                    ),
                    _ModuleTabButton(
                      stacked: true,
                      label: trByLang(langCode, ar: 'الواجبات والتسميع', he: 'מטלות ושינון', en: 'Assignments'),
                      icon: Icons.menu_book_rounded,
                      isSelected: effectiveTab == GroupModuleTab.assignments,
                      onTap: () => onTabSelected(GroupModuleTab.assignments),
                    ),
                    _ModuleTabButton(
                      stacked: true,
                      label: trByLang(langCode, ar: 'خطة المراجعة', he: 'תוכנית חזרה', en: 'Revision Plan'),
                      icon: Icons.calendar_view_week_rounded,
                      isSelected: effectiveTab == GroupModuleTab.weeklyRevision,
                      onTap: () => onTabSelected(GroupModuleTab.weeklyRevision),
                    ),
                    _ModuleTabButton(
                      stacked: true,
                      label: trByLang(langCode, ar: 'الحضور الشهري', he: 'נוכחות חודשית', en: 'Monthly Attendance'),
                      icon: Icons.fact_check_rounded,
                      isSelected: effectiveTab == GroupModuleTab.monthlyAttendance,
                      onTap: () => onTabSelected(GroupModuleTab.monthlyAttendance),
                    ),
                  ],
                )
              : Row(
                  children: [
                    _ModuleTabButton(
                      label: trByLang(langCode, ar: 'قائمة الطلاب', he: 'רשימת תלמידים', en: 'Students Roster'),
                      icon: Icons.groups_rounded,
                      isSelected: effectiveTab == GroupModuleTab.studentsRoster,
                      onTap: () => onTabSelected(GroupModuleTab.studentsRoster),
                    ),
                    _ModuleTabButton(
                      label: trByLang(langCode, ar: 'الحضور الشهري', he: 'נוכחות חודשית', en: 'Monthly Attendance'),
                      icon: Icons.fact_check_rounded,
                      isSelected: effectiveTab == GroupModuleTab.monthlyAttendance,
                      onTap: () => onTabSelected(GroupModuleTab.monthlyAttendance),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ModuleTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool stacked;

  const _ModuleTabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.stacked = false,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = isSelected ? GroupDetailTokens.primary : GroupDetailTokens.onSurfaceVariant;
    final textStyle = TextStyle(
      fontSize: stacked ? 10.5 : 11.5,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
      color: fgColor,
    );

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: stacked ? 8 : 9, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? GroupDetailTokens.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: stacked
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 17, color: fgColor),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(label, style: textStyle, maxLines: 1, textAlign: TextAlign.center),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 16, color: fgColor),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(label, style: textStyle, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
