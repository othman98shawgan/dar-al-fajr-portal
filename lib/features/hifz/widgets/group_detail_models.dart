import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/surah_page_map.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../../admin/models/admin_models.dart';
import '../models/teacher_models.dart';
import '../providers/teacher_providers.dart';

enum GroupModuleTab {
  assignments,
  studentsRoster,
  weeklyRevision,
  monthlyAttendance,
}

enum AssignmentFilterTab {
  all,
  newHifz,
  revision,
  pending,
}

class GroupDetailTokens {
  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF3D4947);
  static const Color primary = Color(0xFF00685F);
  static const Color primaryFixed = Color(0xFF89F5E7);
  static const Color onPrimaryFixed = Color(0xFF00201D);
  static const Color secondary = Color(0xFF904D00);
  static const Color secondaryContainer = Color(0xFFFE932C);
  static const Color secondaryFixed = Color(0xFFFFDCC3);
  static const Color onSecondaryFixed = Color(0xFF2F1500);
  static const Color onSecondaryFixedVariant = Color(0xFF6E3900);
  static const Color tertiary = Color(0xFF1E6661);
}

class AssignmentCardItem {
  final String id;
  final String studentId;
  final String studentName;
  final String initial;
  final String timeSubtitle;
  final bool isPendingTimeAlert;
  final AssignmentType assignmentType;
  final String assignmentBadgeLabel;
  final int surahId;
  final String surahName;
  final int fromAyah;
  final int toAyah;
  final int? targetPage;
  final int? juzNumber;
  final String rangeTitle;
  final EvaluationGrade grade;
  final int? score;
  final bool isPartialRead;
  final String gradeBadgeLabel;
  final double progressFactor;
  final String feedbackText;
  final String audioDurationLabel;
  final bool isFromFirestore;

  const AssignmentCardItem({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.initial,
    required this.timeSubtitle,
    this.isPendingTimeAlert = false,
    required this.assignmentType,
    required this.assignmentBadgeLabel,
    required this.surahId,
    required this.surahName,
    required this.fromAyah,
    required this.toAyah,
    this.targetPage,
    this.juzNumber,
    required this.rangeTitle,
    required this.grade,
    this.score,
    this.isPartialRead = false,
    required this.gradeBadgeLabel,
    required this.progressFactor,
    required this.feedbackText,
    required this.audioDurationLabel,
    this.isFromFirestore = false,
  });
}

const List<AssignmentCardItem> groupDetailSeedCards = [
  AssignmentCardItem(
    id: 'seed-assign-1',
    studentId: 'st-1042',
    studentName: 'إبراهيم طه عثمان',
    initial: 'إ',
    timeSubtitle: 'تم التسميع اليوم • ٤:١٥ م',
    assignmentType: AssignmentType.newHifz,
    assignmentBadgeLabel: 'صفحة كاملة (ص ٢٨٢)',
    surahId: 17,
    surahName: 'الإسراء',
    fromAyah: 1,
    toAyah: 15,
    targetPage: 282,
    juzNumber: 15,
    rangeTitle: 'سورة الإسراء • صفحة ٢٨٢',
    grade: EvaluationGrade.excellent,
    score: 97,
    gradeBadgeLabel: '٩٧ / ١٠٠ • ممتاز',
    progressFactor: 0.97,
    feedbackText: 'ما شاء الله، إتقان متين لأحكام النون الساكنة والمد المتصل، خطأ لفظي واحد فقط.',
    audioDurationLabel: 'تم الرصد اليوم',
  ),
  AssignmentCardItem(
    id: 'seed-assign-2',
    studentId: 'st-1088',
    studentName: 'عبد الرحمن يوسف الشريف',
    initial: 'ع',
    timeSubtitle: 'تم التسميع اليوم • ٤:٤٠ م',
    assignmentType: AssignmentType.revision,
    assignmentBadgeLabel: 'اختبار جزء كامل',
    surahId: 78,
    surahName: 'النبأ',
    fromAyah: 1,
    toAyah: 40,
    juzNumber: 30,
    rangeTitle: 'مراجعة واختبار الجزء ٣٠ كاملاً',
    grade: EvaluationGrade.good,
    score: 88,
    gradeBadgeLabel: '٨٨ / ١٠٠ • مجتاز الجزء',
    progressFactor: 0.88,
    feedbackText: 'تنبيه لموضع القلقلة في سورة البروج والانتباه لترقيق الراء. اجتاز اختبار الجزء بنجاح (الحد الأدنى ٧٩).',
    audioDurationLabel: 'اجتاز اختبار الجزء',
  ),
  AssignmentCardItem(
    id: 'seed-assign-3',
    studentId: 'st-1102',
    studentName: 'زياد المنصور',
    initial: 'ز',
    timeSubtitle: 'في الانتظار • موعده ٥:٣٠ م',
    isPendingTimeAlert: true,
    assignmentType: AssignmentType.newHifz,
    assignmentBadgeLabel: 'حفظ جديد (صفحة ٢٦٧)',
    surahId: 16,
    surahName: 'النحل',
    fromAyah: 1,
    toAyah: 35,
    targetPage: 267,
    juzNumber: 14,
    rangeTitle: 'سورة النحل • صفحة ٢٦٧ (آية ١ - ٣٥)',
    grade: EvaluationGrade.pending,
    gradeBadgeLabel: 'في الانتظار',
    progressFactor: 0.20,
    feedbackText: 'لم يتم التسميع بعد - مقرر اليوم جاهز للاستماع والرصد المباشر.',
    audioDurationLabel: 'بانتظار التسميع',
  ),
];

String formatGroupNum(int number, String langCode) {
  if (langCode != 'ar') return '$number';
  const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  var result = number.toString();
  for (var i = 0; i < western.length; i++) {
    result = result.replaceAll(western[i], eastern[i]);
  }
  return result;
}

class GroupStatKpiBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const GroupStatKpiBox({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF3D4947),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class GroupFilterPillButton extends StatelessWidget {
  final String label;
  final String countLabel;
  final Color? dotColor;
  final bool isWarningAccent;
  final bool isSelected;
  final VoidCallback onTap;

  const GroupFilterPillButton({
    super.key,
    required this.label,
    required this.countLabel,
    this.dotColor,
    this.isWarningAccent = false,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? GroupDetailTokens.primary : Colors.white;
    final fgColor = isSelected
        ? Colors.white
        : (isWarningAccent ? GroupDetailTokens.secondary : GroupDetailTokens.onSurfaceVariant);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(999),
      elevation: 0.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null && !isSelected) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: fgColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.20)
                      : (isWarningAccent ? GroupDetailTokens.secondaryFixed : Colors.transparent),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  countLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (isWarningAccent ? GroupDetailTokens.onSecondaryFixed : GroupDetailTokens.onSurfaceVariant),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showGroupStudentStatsBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String langCode,
  required String studentId,
  required String studentName,
  required List<AttendanceLog> groupAttendanceLogs,
  required bool isLiveFirebase,
}) {
  final studentsMap = ref.read(allStudentsMapProvider).asData?.value ?? const {};
  final profile = studentsMap[studentId] ??
      (isLiveFirebase
          ? StudentProfile(id: studentId, fullName: studentName, parentId: '')
          : StudentProfile(
              id: studentId,
              fullName: studentName,
              parentId: 'parent-1',
              memorizedPages: const [1, 2, 3, 4, 5, 582, 583, 584, 585, 586, 587],
              completedSurahs: List.generate(37, (i) => 78 + i),
              completedJuz: const [30, 29],
              juzStatuses: const {
                30: 'passed_exam',
                29: 'ready_for_exam',
                28: 'in_progress',
              },
            ));

  final studentLogs = groupAttendanceLogs.where((l) => l.studentId == studentId).toList();
  final totalSessions = studentLogs.isNotEmpty || isLiveFirebase ? studentLogs.length : 12;
  final attendedSessions = studentLogs.isNotEmpty || isLiveFirebase
      ? studentLogs
          .where((l) => l.status == AttendanceStatus.present || l.status == AttendanceStatus.late)
          .length
      : 11;
  final attendancePercent =
      totalSessions > 0 ? ((attendedSessions / totalSessions) * 100).round() : (isLiveFirebase ? 0 : 92);

  final centerPagesCount = profile.memorizedCenterPagesCount;
  final totalCenterPages = CenterQuranMap.totalCenterPages;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: GroupDetailTokens.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        builder: (_, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: GroupDetailTokens.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: GroupDetailTokens.primaryFixed,
                    child: Text(
                      studentName.characters.first,
                      style: const TextStyle(
                        color: GroupDetailTokens.onPrimaryFixed,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          trByLang(
                            langCode,
                            ar: 'سجل الإحصائيات المتكامل (الحفظ، اختبارات الأجزاء، والحضور)',
                            he: 'סטטיסטיקת תלמיד (שינון, מבחני ג׳וז ונוכחות)',
                            en: 'Student Hifz, Juz Exams & Attendance Stats',
                          ),
                          style: const TextStyle(fontSize: 12, color: GroupDetailTokens.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GroupStatKpiBox(
                      label: trByLang(langCode, ar: 'صفحات المركز', he: 'עמודי מרכז', en: 'Center Pages'),
                      value: '${formatGroupNum(centerPagesCount, langCode)} / ${formatGroupNum(totalCenterPages, langCode)}',
                      color: GroupDetailTokens.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GroupStatKpiBox(
                      label: trByLang(langCode, ar: 'السور المنجزة', he: 'סורות שהושלמו', en: 'Surahs Done'),
                      value: '${formatGroupNum(profile.completedSurahs.length, langCode)} / ${formatGroupNum(114, langCode)}',
                      color: GroupDetailTokens.tertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GroupStatKpiBox(
                      label: trByLang(langCode, ar: 'نسبة الحضور', he: 'אחוז נוכחות', en: 'Attendance'),
                      value: '${formatGroupNum(attendancePercent, langCode)}%',
                      color: GroupDetailTokens.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                trByLang(
                  langCode,
                  ar: 'حالة الأجزاء واختبارات الأجزاء (علامة النجاح: ٧٩ فأعلى)',
                  he: 'סטטוס ג׳וזים ומבחני ג׳וז (ציון מעבר: 79)',
                  en: 'Juz Progression & Whole-Juz Exam Status (Pass >= 79)',
                ),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(30, (idx) {
                  final juz = 30 - idx;
                  final rawStatus =
                      profile.juzStatuses[juz] ?? (profile.completedJuz.contains(juz) ? 'passed_exam' : null);
                  final status = rawStatus != null ? JuzProgressStatus.fromString(rawStatus) : null;

                  final bgColor = switch (status) {
                    JuzProgressStatus.passedExam => GroupDetailTokens.primaryFixed,
                    JuzProgressStatus.readyForExam => GroupDetailTokens.secondaryFixed,
                    JuzProgressStatus.inProgress => GroupDetailTokens.primary.withValues(alpha: 0.08),
                    null => GroupDetailTokens.surfaceContainerLow,
                  };
                  final textColor = switch (status) {
                    JuzProgressStatus.passedExam => GroupDetailTokens.onPrimaryFixed,
                    JuzProgressStatus.readyForExam => GroupDetailTokens.onSecondaryFixed,
                    JuzProgressStatus.inProgress => GroupDetailTokens.primary,
                    null => GroupDetailTokens.onSurfaceVariant,
                  };

                  return Container(
                    width: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Text(
                          trByLang(
                            langCode,
                            ar: 'الجزء ${formatGroupNum(juz, langCode)}',
                            he: 'ג׳וז $juz',
                            en: 'Juz $juz',
                          ),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: textColor),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          status != null
                              ? status.localizedName(langCode)
                              : trByLang(langCode, ar: 'لم يبدأ', he: 'טרם התחיל', en: 'Not Started'),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textColor),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          );
        },
      );
    },
  );
}
