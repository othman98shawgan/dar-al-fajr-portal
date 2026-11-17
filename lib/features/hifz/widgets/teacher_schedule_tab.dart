import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_tr.dart';
import '../../admin/models/admin_models.dart';
import 'teacher_home_models.dart';

class TeacherScheduleTab extends StatefulWidget {
  final String langCode;
  final List<StudyGroup> groups;
  final List<Enrollment> enrollments;
  final bool isDemoFallback;
  final ValueChanged<String> onOpenGroupDetail;
  final ValueChanged<String> onOpenAttendanceLogging;
  final ValueChanged<OneOnOneSlotData> onOneOnOneTap;

  const TeacherScheduleTab({
    super.key,
    required this.langCode,
    required this.groups,
    required this.enrollments,
    required this.isDemoFallback,
    required this.onOpenGroupDetail,
    required this.onOpenAttendanceLogging,
    required this.onOneOnOneTap,
  });

  @override
  State<TeacherScheduleTab> createState() => _TeacherScheduleTabState();
}

class _TeacherScheduleTabState extends State<TeacherScheduleTab> {
  bool _isWeeklyView = false;
  late int _selectedWeekday;

  @override
  void initState() {
    super.initState();
    _selectedWeekday = DateTime.now().weekday;
  }

  @override
  Widget build(BuildContext context) {
    final langCode = widget.langCode;
    final topPadding = MediaQuery.paddingOf(context).top + 64 + 16;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 64 + 24;
    final todayWeekday = DateTime.now().weekday;

    return ListView(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding, left: 16, right: 16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trByLang(
                      langCode,
                      ar: 'جدول الحلقات والتسميع',
                      he: 'מערכת שעות ומפגשים',
                      en: 'Groups & 1-on-1 Schedule',
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: TeacherHomeTokens.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isWeeklyView
                        ? trByLang(
                            langCode,
                            ar: 'العرض الأسبوعي الكامل للحلقات والجلسات الفردية',
                            he: 'תצוגה שבועית מלאה של הקבוצות והמפגשים',
                            en: 'Full weekly overview of group classes and 1-on-1 slots',
                          )
                        : trByLang(
                            langCode,
                            ar: 'اختر اليوم لعرض مواعيد الحلقات والجلسات الفردية',
                            he: 'בחר יום להצגת השיעורים והמפגשים הפרטניים',
                            en: 'Switch days to view group classes and 1-on-1 slots',
                          ),
                    style: const TextStyle(color: TeacherHomeTokens.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Daily vs Weekly Segmented Switcher
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: TeacherHomeTokens.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _ScheduleViewToggleButton(
                label: trByLang(langCode, ar: 'يومي', he: 'יומי', en: 'Daily'),
                icon: Icons.today_rounded,
                isSelected: !_isWeeklyView,
                onTap: () => setState(() => _isWeeklyView = false),
              ),
              _ScheduleViewToggleButton(
                label: trByLang(langCode, ar: 'أسبوعي', he: 'שבועי', en: 'Weekly'),
                icon: Icons.calendar_view_week_rounded,
                isSelected: _isWeeklyView,
                onTap: () => setState(() => _isWeeklyView = true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (!_isWeeklyView) ...[
          // Day Switcher Strip (all 7 days visible without horizontal scrolling)
          _DailyDaySwitcher(
            langCode: langCode,
            selectedWeekday: _selectedWeekday,
            todayWeekday: todayWeekday,
            onSelectWeekday: (wd) => setState(() => _selectedWeekday = wd),
          ),
          const SizedBox(height: 16),
          _buildDayEntriesSection(
            context: context,
            weekday: _selectedWeekday,
            todayWeekday: todayWeekday,
            showDayHeader: true,
          ),
        ] else ...[
          ...ScheduleDayHelper.centerWeekOrder.map((weekday) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _buildDayEntriesSection(
                context: context,
                weekday: weekday,
                todayWeekday: todayWeekday,
                showDayHeader: true,
                compactEmpty: true,
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildDayEntriesSection({
    required BuildContext context,
    required int weekday,
    required int todayWeekday,
    bool showDayHeader = true,
    bool compactEmpty = false,
  }) {
    final langCode = widget.langCode;
    final entries = buildTeacherScheduleForWeekday(
      weekday: weekday,
      groups: widget.groups,
      enrollments: widget.enrollments,
      langCode: langCode,
      isDemoFallback: widget.isDemoFallback,
    );
    final dayTitle = ScheduleDayHelper.localizedDayName(weekday, langCode);
    final isToday = weekday == todayWeekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDayHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    dayTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isToday ? TeacherHomeTokens.primary : TeacherHomeTokens.onSurface,
                        ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: TeacherHomeTokens.primaryFixed,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        trByLang(langCode, ar: 'اليوم', he: 'היום', en: 'Today'),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: TeacherHomeTokens.onPrimaryFixed,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                trByLang(
                  langCode,
                  ar: '${formatTeacherNum(entries.length, langCode)} مواعيد',
                  he: '${entries.length} מפגשים',
                  en: '${entries.length} items',
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TeacherHomeTokens.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        if (entries.isEmpty)
          Container(
            padding: EdgeInsets.symmetric(vertical: compactEmpty ? 14 : 36, horizontal: 16),
            decoration: BoxDecoration(
              color: TeacherHomeTokens.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: compactEmpty
                  ? Text(
                      trByLang(
                        langCode,
                        ar: 'لا توجد حلقات أو جلسات مجدولة',
                        he: 'אין שיעורים או מפגשים מתוכננים',
                        en: 'No classes or slots scheduled',
                      ),
                      style: const TextStyle(color: TeacherHomeTokens.onSurfaceVariant, fontSize: 12.5),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_available_rounded,
                          size: 44,
                          color: TeacherHomeTokens.onSurfaceVariant.withValues(alpha: 0.45),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          trByLang(
                            langCode,
                            ar: 'لا توجد حلقات أو جلسات فردية في هذا اليوم',
                            he: 'אין שיעורים או מפגשים פרטניים ביום זה',
                            en: 'No group classes or 1-on-1 slots on this day',
                          ),
                          style: const TextStyle(
                            color: TeacherHomeTokens.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          )
        else
          ...entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ScheduleEntryCard(
                  langCode: langCode,
                  entry: entry,
                  onTap: () {
                    if (entry.isGroupSession) {
                      showTeacherGroupOptionsSheet(
                        context: context,
                        groupId: entry.groupId,
                        groupTitle: entry.title,
                        langCode: langCode,
                        onOpenGroupDetail: widget.onOpenGroupDetail,
                        onOpenAttendanceLogging: widget.onOpenAttendanceLogging,
                      );
                    } else if (entry.oneOnOneSlot != null) {
                      widget.onOneOnOneTap(entry.oneOnOneSlot!);
                    }
                  },
                ),
              )),
      ],
    );
  }
}

class _ScheduleViewToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScheduleViewToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? TeacherHomeTokens.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? TeacherHomeTokens.primary : TeacherHomeTokens.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? TeacherHomeTokens.primary : TeacherHomeTokens.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyDaySwitcher extends StatelessWidget {
  final String langCode;
  final int selectedWeekday;
  final int todayWeekday;
  final ValueChanged<int> onSelectWeekday;

  const _DailyDaySwitcher({
    required this.langCode,
    required this.selectedWeekday,
    required this.todayWeekday,
    required this.onSelectWeekday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: TeacherHomeTokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: ScheduleDayHelper.centerWeekOrder.map((wd) {
          final isSelected = wd == selectedWeekday;
          final isToday = wd == todayWeekday;
          final shortLabel = ScheduleDayHelper.localizedShortDayName(wd, langCode);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                onTap: () => onSelectWeekday(wd),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? TeacherHomeTokens.primary : TeacherHomeTokens.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: isToday && !isSelected
                        ? Border.all(color: TeacherHomeTokens.primary.withValues(alpha: 0.45), width: 1)
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          shortLabel,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : TeacherHomeTokens.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday
                              ? (isSelected ? Colors.white : TeacherHomeTokens.primary)
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ScheduleEntryCard extends StatelessWidget {
  final String langCode;
  final TeacherScheduleEntry entry;
  final VoidCallback onTap;

  const _ScheduleEntryCard({
    required this.langCode,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGroup = entry.isGroupSession;
    final accentColor = isGroup ? TeacherHomeTokens.primary : TeacherHomeTokens.secondary;
    final badgeBg = isGroup
        ? TeacherHomeTokens.primaryFixed.withValues(alpha: 0.65)
        : TeacherHomeTokens.secondaryFixed.withValues(alpha: 0.75);
    final badgeFg = isGroup ? TeacherHomeTokens.onPrimaryFixed : TeacherHomeTokens.onSecondaryFixed;
    final typeLabel = isGroup
        ? trByLang(langCode, ar: 'حلقة جماعية', he: 'שיעור קבוצתי', en: 'Group Class')
        : trByLang(langCode, ar: 'جلسة فردية', he: 'מפגש פרטני', en: '1-on-1 Slot');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: TeacherHomeTokens.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            PositionedDirectional(
              top: 0,
              bottom: 0,
              start: 0,
              width: 5,
              child: Container(color: accentColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      entry.timeLabel,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: badgeFg),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                entry.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                  color: TeacherHomeTokens.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                typeLabel,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeFg),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isGroup && entry.enrolledCount != null
                              ? '${entry.subtitle} • ${trByLang(langCode, ar: '${formatTeacherNum(entry.enrolledCount!, langCode)} طلاب', he: '${entry.enrolledCount} תלמידים', en: '${entry.enrolledCount} students')}'
                              : entry.subtitle,
                          style: const TextStyle(color: TeacherHomeTokens.onSurfaceVariant, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: TeacherHomeTokens.onSurfaceVariant),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
