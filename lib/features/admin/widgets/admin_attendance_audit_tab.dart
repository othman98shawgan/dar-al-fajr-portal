import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../../hifz/models/teacher_models.dart';
import '../models/admin_models.dart';
import '../providers/admin_providers.dart';

class AdminAttendanceAuditTab extends ConsumerStatefulWidget {
  final String langCode;
  final List<StudyGroup> groups;
  final bool isDemoFallback;

  const AdminAttendanceAuditTab({
    super.key,
    required this.langCode,
    required this.groups,
    required this.isDemoFallback,
  });

  @override
  ConsumerState<AdminAttendanceAuditTab> createState() => _AdminAttendanceAuditTabState();
}

class _AdminAttendanceAuditTabState extends ConsumerState<AdminAttendanceAuditTab> {
  String? _auditGroupFilter;
  AttendanceStatus? _auditStatusFilter;

  @override
  Widget build(BuildContext context) {
    final langCode = widget.langCode;
    final liveLogs = ref.watch(adminAttendanceLogsProvider).asData?.value ?? const <AttendanceLog>[];
    final now = DateTime.now();
    final logs = liveLogs.isNotEmpty
        ? liveLogs
        : (widget.isDemoFallback
            ? [
                AttendanceLog(
                  id: 'demo-log-1',
                  groupId: 'grp-hifz-1',
                  studentId: 'st-1042',
                  studentName: 'إبراهيم طه عثمان',
                  teacherId: 't-1',
                  sessionDate: now,
                  sessionMode: SessionMode.group,
                  status: AttendanceStatus.present,
                ),
                AttendanceLog(
                  id: 'demo-log-2',
                  groupId: 'grp-tajweed-1',
                  studentId: 'st-1049',
                  studentName: 'ياسين أحمد علي',
                  teacherId: 't-1',
                  sessionDate: now,
                  sessionMode: SessionMode.oneOnOne,
                  status: AttendanceStatus.late,
                  notes: trByLang(langCode, ar: 'تأخر 10 دقائق', he: 'איחור של 10 דקות', en: '10 mins late'),
                ),
                AttendanceLog(
                  id: 'demo-log-3',
                  groupId: 'grp-qaidah-1',
                  studentId: 'st-1055',
                  studentName: 'أحمد سامي خالد',
                  teacherId: 't-2',
                  sessionDate: now.subtract(const Duration(days: 1)),
                  sessionMode: SessionMode.group,
                  status: AttendanceStatus.absent,
                ),
              ]
            : const <AttendanceLog>[]);

    final groupNameById = <String, String>{
      for (final g in widget.groups) g.id: g.name,
    };

    final presentCount = logs.where((l) => l.status == AttendanceStatus.present).length;
    final lateCount = logs.where((l) => l.status == AttendanceStatus.late).length;
    final absentCount = logs.where((l) => l.status == AttendanceStatus.absent).length;
    final attendanceRate = logs.isNotEmpty ? (((presentCount + lateCount) / logs.length) * 100).round() : 0;

    final filteredLogs = logs.where((l) {
      if (_auditGroupFilter != null && l.groupId != _auditGroupFilter) return false;
      if (_auditStatusFilter != null && l.status != _auditStatusFilter) return false;
      return true;
    }).toList();

    final uniqueGroupIds = logs.map((l) => l.groupId).toSet().toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trByLang(
                langCode,
                ar: 'سجل الحضور والغياب (Attendance Audit)',
                he: 'ביקורת נוכחות והיעדרויות',
                en: 'Attendance Audit',
              ),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              trByLang(
                langCode,
                ar: 'متابعة سجلات حضور المعلمين للحلقات والجلسات الفردية بشكل مباشر',
                he: 'מעקב בזמן אמת אחר רישומי הנוכחות של המורים',
                en: 'Live audit of teacher attendance records for group and 1-on-1 sessions',
              ),
              style: const TextStyle(color: Color(0xFF6D7A77)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _AuditStatChip(
              label: trByLang(langCode, ar: 'إجمالي السجلات', he: 'סה״כ רשומות', en: 'Total Logs'),
              value: '${logs.length}',
              color: DarAlFajrTheme.primary,
            ),
            _AuditStatChip(
              label: trByLang(langCode, ar: 'نسبة الحضور', he: 'אחוז נוכחות', en: 'Attendance Rate'),
              value: '$attendanceRate%',
              color: const Color(0xFF1E6661),
            ),
            _AuditStatChip(
              label: AttendanceStatus.present.localizedName(langCode),
              value: '$presentCount',
              color: Colors.green.shade700,
            ),
            _AuditStatChip(
              label: AttendanceStatus.late.localizedName(langCode),
              value: '$lateCount',
              color: Colors.orange.shade800,
            ),
            _AuditStatChip(
              label: AttendanceStatus.absent.localizedName(langCode),
              value: '$absentCount',
              color: Colors.red.shade700,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 240,
              child: DropdownButtonFormField<String?>(
                initialValue: _auditGroupFilter != null && uniqueGroupIds.contains(_auditGroupFilter)
                    ? _auditGroupFilter
                    : null,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: trByLang(langCode, ar: 'تصفية حسب الحلقة', he: 'סינון לפי קבוצה', en: 'Filter by Group'),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(trByLang(langCode, ar: 'كل الحلقات', he: 'כל הקבוצות', en: 'All Groups')),
                  ),
                  ...uniqueGroupIds.map(
                    (gid) => DropdownMenuItem<String?>(
                      value: gid,
                      child: Text(groupNameById[gid] ?? gid, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (val) => setState(() => _auditGroupFilter = val),
              ),
            ),
            ChoiceChip(
              label: Text(trByLang(langCode, ar: 'الكل', he: 'הכל', en: 'All')),
              selected: _auditStatusFilter == null,
              onSelected: (_) => setState(() => _auditStatusFilter = null),
            ),
            ...AttendanceStatus.values.map(
              (status) => ChoiceChip(
                label: Text(status.localizedName(langCode)),
                selected: _auditStatusFilter == status,
                onSelected: (_) => setState(() {
                  _auditStatusFilter = _auditStatusFilter == status ? null : status;
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: filteredLogs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      trByLang(
                        langCode,
                        ar: 'لا توجد سجلات حضور مطابقة حالياً.',
                        he: 'אין רשומות נוכחות תואמות כרגע.',
                        en: 'No matching attendance logs found.',
                      ),
                      style: const TextStyle(color: Color(0xFF6D7A77)),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredLogs.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final log = filteredLogs[idx];
                    final statusColor = switch (log.status) {
                      AttendanceStatus.present => Colors.green.shade700,
                      AttendanceStatus.late => Colors.orange.shade800,
                      AttendanceStatus.absent => Colors.red.shade700,
                      AttendanceStatus.excused => Colors.blue.shade700,
                    };
                    final statusIcon = switch (log.status) {
                      AttendanceStatus.present => Icons.check_circle_rounded,
                      AttendanceStatus.late => Icons.access_time_filled_rounded,
                      AttendanceStatus.absent => Icons.cancel_rounded,
                      AttendanceStatus.excused => Icons.event_available_rounded,
                    };
                    final groupLabel = groupNameById[log.groupId] ?? log.groupId;
                    final dateStr =
                        '${log.sessionDate.year}-${log.sessionDate.month.toString().padLeft(2, '0')}-${log.sessionDate.day.toString().padLeft(2, '0')}';
                    final modeLabel = log.sessionMode == SessionMode.oneOnOne
                        ? trByLang(langCode, ar: 'فردي', he: 'אישי', en: '1-on-1')
                        : trByLang(langCode, ar: 'جماعي', he: 'קבוצתי', en: 'Group');

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withValues(alpha: 0.12),
                        child: Icon(statusIcon, color: statusColor),
                      ),
                      title: Text(
                        log.studentName.isNotEmpty ? log.studentName : log.studentId,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '$groupLabel • $modeLabel • $dateStr${log.notes != null && log.notes!.isNotEmpty ? ' — ${log.notes}' : ''}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          log.status.localizedName(langCode),
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AuditStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AuditStatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: DarAlFajrTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF3D4947))),
        ],
      ),
    );
  }
}
