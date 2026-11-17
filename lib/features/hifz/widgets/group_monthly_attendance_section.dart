import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_tr.dart';
import '../models/teacher_models.dart';
import 'group_detail_models.dart';

class GroupMonthlyAttendanceSection extends StatefulWidget {
  final String langCode;
  final List<AttendanceLog> groupAttendanceLogs;
  final List<({String id, String name, String parentName})> Function(List<AttendanceLog> extraLogs) resolveStudents;
  final bool isLiveFirebase;

  const GroupMonthlyAttendanceSection({
    super.key,
    required this.langCode,
    required this.groupAttendanceLogs,
    required this.resolveStudents,
    required this.isLiveFirebase,
  });

  @override
  State<GroupMonthlyAttendanceSection> createState() => _GroupMonthlyAttendanceSectionState();
}

class _GroupMonthlyAttendanceSectionState extends State<GroupMonthlyAttendanceSection> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final langCode = widget.langCode;
    const monthsAr = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    const monthsEn = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final monthName =
        langCode == 'en' ? monthsEn[(_selectedMonth.month - 1) % 12] : monthsAr[(_selectedMonth.month - 1) % 12];
    final monthLabel = '$monthName ${formatGroupNum(_selectedMonth.year, langCode)}';

    final monthLogs = widget.groupAttendanceLogs
        .where((l) => l.sessionDate.year == _selectedMonth.year && l.sessionDate.month == _selectedMonth.month)
        .toList();

    final resolvedStudents = widget.resolveStudents(monthLogs);
    final roster = <String, String>{};
    if (!widget.isLiveFirebase) {
      roster['st-1042'] = 'إبراهيم طه عثمان';
      roster['st-1088'] = 'عبد الرحمن يوسف الشريف';
      roster['st-1102'] = 'زياد المنصور';
      roster['st-1115'] = 'حمزة كمال الدين';
    }
    for (final st in resolvedStudents) {
      roster[st.id] = st.name;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: GroupDetailTokens.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                  });
                },
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: GroupDetailTokens.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(monthLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                  });
                },
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (roster.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: GroupDetailTokens.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              trByLang(
                langCode,
                ar: 'لا يوجد طلاب مسجلون في هذه الحلقة حالياً.',
                he: 'אין תלמידים רשומים בקבוצה זו כעת.',
                en: 'No students enrolled in this group yet.',
              ),
              style: const TextStyle(color: GroupDetailTokens.onSurfaceVariant),
            ),
          )
        else
          ...roster.entries.map((entry) {
            final stId = entry.key;
            final stName = entry.value;
            final stLogs = monthLogs.where((l) => l.studentId == stId).toList();

            final present = stLogs.isNotEmpty || widget.isLiveFirebase
                ? stLogs.where((l) => l.status == AttendanceStatus.present).length
                : (stId == 'st-1115' ? 6 : 8);
            final lateCount = stLogs.isNotEmpty || widget.isLiveFirebase
                ? stLogs.where((l) => l.status == AttendanceStatus.late).length
                : (stId == 'st-1102' ? 1 : 0);
            final absent = stLogs.isNotEmpty || widget.isLiveFirebase
                ? stLogs
                    .where((l) => l.status == AttendanceStatus.absent || l.status == AttendanceStatus.excused)
                    .length
                : (stId == 'st-1115' ? 2 : 0);
            final total = present + lateCount + absent;
            final rate = total > 0 ? (((present + lateCount) / total) * 100).round() : 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: GroupDetailTokens.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          trByLang(
                            langCode,
                            ar: 'حاضر: ${formatGroupNum(present, langCode)} • متأخر: ${formatGroupNum(lateCount, langCode)} • غائب/معذور: ${formatGroupNum(absent, langCode)}',
                            he: 'נוכח: $present • איחור: $lateCount • חיסור: $absent',
                            en: 'Present: $present • Late: $lateCount • Absent: $absent',
                          ),
                          style: const TextStyle(fontSize: 11.5, color: GroupDetailTokens.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: total == 0
                          ? GroupDetailTokens.surfaceContainerHigh
                          : (rate >= 85 ? GroupDetailTokens.primaryFixed : GroupDetailTokens.secondaryFixed),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      total == 0 ? '—' : '${formatGroupNum(rate, langCode)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: total == 0
                            ? GroupDetailTokens.onSurfaceVariant
                            : (rate >= 85 ? GroupDetailTokens.onPrimaryFixed : GroupDetailTokens.onSecondaryFixed),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
