import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../../hifz/models/teacher_models.dart';
import '../models/admin_models.dart';
import '../providers/admin_providers.dart';

class AdminReportsAnalyticsTab extends ConsumerWidget {
  final String langCode;
  final List<StudentProfile> students;
  final List<StudyGroup> groups;
  final List<Enrollment> enrollments;
  final bool isDemoFallback;

  const AdminReportsAnalyticsTab({
    super.key,
    required this.langCode,
    required this.students,
    required this.groups,
    required this.enrollments,
    required this.isDemoFallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(adminAttendanceLogsProvider).asData?.value ?? const <AttendanceLog>[];
    final assignments = ref.watch(adminHifzAssignmentsProvider).asData?.value ?? const <HifzAssignment>[];

    final totalPagesMemorized = isDemoFallback
        ? 134
        : students.fold<int>(0, (sum, s) => sum + s.memorizedCenterPagesCount);
    final totalCompletedSurahs = isDemoFallback
        ? 42
        : students.fold<int>(0, (sum, s) => sum + s.completedSurahs.length);

    final attendancePercent = logs.isNotEmpty
        ? (((logs.where((l) => l.status == AttendanceStatus.present || l.status == AttendanceStatus.late).length) /
                    logs.length) *
                100)
            .round()
        : (isDemoFallback ? 94 : 0);

    final gradedAssignments = assignments.where((a) => a.grade != EvaluationGrade.pending).toList();
    final passedAssignments = gradedAssignments
        .where((a) => a.grade == EvaluationGrade.excellent || a.grade == EvaluationGrade.good)
        .length;
    final masteryPercent = gradedAssignments.isNotEmpty
        ? ((passedAssignments / gradedAssignments.length) * 100).round()
        : (isDemoFallback ? 88 : 0);

    final trackCounts = <CenterTrack, int>{
      for (final track in CenterTrack.values)
        track: isDemoFallback
            ? switch (track) {
                CenterTrack.hifz => 3,
                CenterTrack.qaidahNouraniah => 1,
                CenterTrack.readingTajweed => 1,
                CenterTrack.tarbawi => 1,
              }
            : enrollments.where((e) => e.track == track).length,
    };
    final maxTrackCount = trackCounts.values.fold<int>(1, (maxVal, v) => v > maxVal ? v : maxVal);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trByLang(
                langCode,
                ar: 'التقارير والإحصائيات الأكاديمية',
                he: 'דוחות וסטטיסטיקה אקדמית',
                en: 'Academic Reports & Analytics',
              ),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              trByLang(
                langCode,
                ar: 'مؤشرات الحفظ، التقييمات الأسبوعية، ونسب الحضور المباشرة',
                he: 'מדדי שינון, הערכות שבועיות ונוכחות בזמן אמת',
                en: 'Live metrics for Quran memorization, weekly evaluations, and attendance',
              ),
              style: const TextStyle(color: Color(0xFF6D7A77)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _ReportKpiTile(
              title: trByLang(langCode, ar: 'متوسط الحضور العام', he: 'נוכחות כללית', en: 'Overall Attendance'),
              value: '$attendancePercent%',
              subtitle: isDemoFallback
                  ? trByLang(langCode, ar: 'بيانات تجريبية', he: 'נתוני הדגמה', en: 'Demo sample')
                  : '${logs.length} ${trByLang(langCode, ar: 'سجل', he: 'רשומות', en: 'logs')}',
              color: Colors.green.shade700,
              icon: Icons.fact_check_rounded,
            ),
            _ReportKpiTile(
              title: trByLang(langCode, ar: 'إجمالي الصفحات المحفوظة', he: 'עמודים שנלמדו', en: 'Memorized Pages'),
              value: '$totalPagesMemorized',
              subtitle:
                  '$totalCompletedSurahs ${trByLang(langCode, ar: 'سورة مكتملة', he: 'סורות שהושלמו', en: 'completed surahs')}',
              color: DarAlFajrTheme.primary,
              icon: Icons.menu_book_rounded,
            ),
            _ReportKpiTile(
              title: trByLang(langCode, ar: 'نسبة الإتقان الأسبوعي', he: 'אחוז הצלחה שבועי', en: 'Weekly Mastery Rate'),
              value: '$masteryPercent%',
              subtitle: '${assignments.length} ${trByLang(langCode, ar: 'تكليف', he: 'משימות', en: 'assignments')}',
              color: DarAlFajrTheme.accent,
              icon: Icons.stars_rounded,
            ),
            _ReportKpiTile(
              title: trByLang(langCode, ar: 'الحلقات والمسارات', he: 'קבוצות ומסלולים', en: 'Active Circles'),
              value: '${isDemoFallback ? 3 : groups.length}',
              subtitle:
                  '${isDemoFallback ? 6 : enrollments.length} ${trByLang(langCode, ar: 'تسجيل', he: 'רישומים', en: 'enrollments')}',
              color: const Color(0xFF1E6661),
              icon: Icons.hub_rounded,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trByLang(
                    langCode,
                    ar: 'توزيع التسجيلات حسب المسار',
                    he: 'התפלגות רישומים לפי מסלול',
                    en: 'Enrollments by Track',
                  ),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                ...CenterTrack.values.map((track) {
                  final count = trackCounts[track] ?? 0;
                  final ratio = maxTrackCount > 0 ? count / maxTrackCount : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(track.localizedName(langCode), style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE6E8EA),
                            color: DarAlFajrTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trByLang(
                    langCode,
                    ar: 'أحدث تقييمات الحفظ والمراجعة',
                    he: 'הערכות שינון וחזרה אחרונות',
                    en: 'Recent Hifz & Revision Evaluations',
                  ),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (assignments.isEmpty)
                  Text(
                    trByLang(
                      langCode,
                      ar: 'لا توجد تقييمات مسجلة بعد.',
                      he: 'אין הערכות רשומות עדיין.',
                      en: 'No recorded evaluations yet.',
                    ),
                    style: const TextStyle(color: Color(0xFF6D7A77)),
                  )
                else
                  ...assignments.take(8).map((a) {
                    final gradeColor = switch (a.grade) {
                      EvaluationGrade.excellent => Colors.green.shade700,
                      EvaluationGrade.good => DarAlFajrTheme.primary,
                      EvaluationGrade.needsRepeat => Colors.red.shade700,
                      EvaluationGrade.pending => Colors.orange.shade800,
                    };
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${a.studentName.isNotEmpty ? a.studentName : a.studentId} — ${a.surahName.isNotEmpty ? a.surahName : 'Surah ${a.surahId}'} (${a.fromAyah}-${a.toAyah})',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(a.type.localizedName(langCode)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: gradeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          a.grade.localizedName(langCode),
                          style: TextStyle(color: gradeColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportKpiTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _ReportKpiTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DarAlFajrTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A77), fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF6D7A77))),
        ],
      ),
    );
  }
}
