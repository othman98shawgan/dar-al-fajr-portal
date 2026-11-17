import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_tr.dart';
import '../models/teacher_models.dart';
import 'group_detail_models.dart';

class GroupNonHifzRosterSection extends StatelessWidget {
  final String langCode;
  final List<({String id, String name, String parentName})> filteredStudents;
  final List<AttendanceLog> groupAttendanceLogs;
  final bool isLiveFirebase;
  final VoidCallback onLogAttendance;
  final void Function(String studentId, String studentName) onShowStudentStats;

  const GroupNonHifzRosterSection({
    super.key,
    required this.langCode,
    required this.filteredStudents,
    required this.groupAttendanceLogs,
    required this.isLiveFirebase,
    required this.onLogAttendance,
    required this.onShowStudentStats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              trByLang(
                langCode,
                ar: 'قائمة الطلاب المسجلين (${formatGroupNum(filteredStudents.length, langCode)})',
                he: 'רשימת תלמידים (${filteredStudents.length})',
                en: 'Enrolled Students (${filteredStudents.length})',
              ),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: GroupDetailTokens.onSurface,
                  ),
            ),
            OutlinedButton.icon(
              onPressed: onLogAttendance,
              icon: const Icon(Icons.how_to_reg_rounded, size: 16),
              label: Text(
                trByLang(langCode, ar: 'رصد الحضور', he: 'רישום נוכחות', en: 'Log Attendance'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filteredStudents.isEmpty)
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
          ...filteredStudents.map((st) {
            final stLogs = groupAttendanceLogs.where((l) => l.studentId == st.id).toList();
            final attended =
                stLogs.where((l) => l.status == AttendanceStatus.present || l.status == AttendanceStatus.late).length;
            final total = stLogs.isNotEmpty || isLiveFirebase ? stLogs.length : 10;
            final rate = total > 0 ? (((stLogs.isNotEmpty || isLiveFirebase ? attended : 9) / total) * 100).round() : 0;
            final attendanceText = total == 0
                ? trByLang(
                    langCode,
                    ar: 'لا توجد جلسات حضور مسجلة بعد',
                    he: 'אין עדיין רישומי נוכחות',
                    en: 'No attendance sessions logged yet',
                  )
                : trByLang(
                    langCode,
                    ar: 'نسبة الحضور في الحلقة: ${formatGroupNum(rate, langCode)}%',
                    he: 'נוכחות בקבוצה: $rate%',
                    en: 'Group Attendance: $rate%',
                  );

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: GroupDetailTokens.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: GroupDetailTokens.primaryFixed,
                    child: Text(
                      st.name.characters.first,
                      style: const TextStyle(
                        color: GroupDetailTokens.onPrimaryFixed,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          st.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: GroupDetailTokens.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          attendanceText,
                          style: const TextStyle(fontSize: 11.5, color: GroupDetailTokens.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => onShowStudentStats(st.id, st.name),
                    icon: const Icon(Icons.insights_rounded, size: 16),
                    label: Text(
                      trByLang(langCode, ar: 'الإحصائيات', he: 'סטטיסטיקה', en: 'Stats'),
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
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
