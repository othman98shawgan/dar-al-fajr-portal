import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations_tr.dart';
import '../../admin/models/admin_models.dart';
import '../models/teacher_models.dart';
import '../providers/teacher_providers.dart';

class TeacherHomeTokens {
  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E5);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF3D4947);
  static const Color primary = Color(0xFF00685F);
  static const Color primaryContainer = Color(0xFF008378);
  static const Color primaryFixed = Color(0xFF89F5E7);
  static const Color onPrimaryFixed = Color(0xFF00201D);
  static const Color secondary = Color(0xFF904D00);
  static const Color secondaryFixed = Color(0xFFFFDCC3);
  static const Color secondaryFixedDim = Color(0xFFFFB77D);
  static const Color onSecondaryFixed = Color(0xFF2F1500);
  static const Color tertiary = Color(0xFF1E6661);
  static const Color tertiaryFixed = Color(0xFFABEFE8);
  static const Color tertiaryFixedDim = Color(0xFF8FD3CC);
  static const Color onTertiaryFixed = Color(0xFF00201E);
}

class OneOnOneSlotData {
  final String studentId;
  final String groupId;
  final String groupName;
  final String timeLabel;
  final int? weekday;
  final int sortMinutes;
  final String studentName;
  final String taskTitle;
  final String rangeSubtitle;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final IconData topIcon;
  final Color topIconColor;
  final IconData taskIcon;
  final Color taskIconColor;
  final IconData actionIcon;
  final bool isPrimaryAction;
  final bool hasTopBarAccent;

  const OneOnOneSlotData({
    required this.studentId,
    required this.groupId,
    this.groupName = '',
    required this.timeLabel,
    this.weekday,
    this.sortMinutes = 1440,
    required this.studentName,
    required this.taskTitle,
    required this.rangeSubtitle,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.topIcon,
    required this.topIconColor,
    required this.taskIcon,
    required this.taskIconColor,
    required this.actionIcon,
    this.isPrimaryAction = false,
    this.hasTopBarAccent = false,
  });
}

class TeacherScheduleEntry {
  final bool isGroupSession;
  final int weekday;
  final String timeLabel;
  final int sortMinutes;
  final String groupId;
  final String title;
  final String subtitle;
  final CenterTrack track;
  final int? enrolledCount;
  final OneOnOneSlotData? oneOnOneSlot;

  const TeacherScheduleEntry({
    required this.isGroupSession,
    required this.weekday,
    required this.timeLabel,
    required this.sortMinutes,
    required this.groupId,
    required this.title,
    required this.subtitle,
    required this.track,
    this.enrolledCount,
    this.oneOnOneSlot,
  });
}

List<OneOnOneSlotData> buildOneOnOneSlotsFromEnrollments({
  required List<Enrollment> enrollments,
  required String langCode,
}) {
  final list = enrollments
      .where((e) => e.oneOnOneSlotTime != null && e.oneOnOneSlotTime!.trim().isNotEmpty)
      .map((e) {
    final parsed = ScheduleDayHelper.parseOneOnOneSlot(e.oneOnOneSlotTime!);
    final isHifz = e.track == CenterTrack.hifz;
    final dayPrefix = parsed.weekday != null
        ? '${ScheduleDayHelper.localizedDayName(parsed.weekday!, langCode)} • '
        : '';
    return OneOnOneSlotData(
      studentId: e.studentId,
      groupId: e.groupId,
      groupName: e.groupName,
      timeLabel: parsed.timeLabel,
      weekday: parsed.weekday,
      sortMinutes: parsed.sortMinutes,
      studentName: e.studentName,
      taskTitle: e.track.localizedName(langCode),
      rangeSubtitle: '$dayPrefix${isHifz ? trByLang(langCode, ar: 'جلسة تسميع فردية', he: 'מפגש שינון פרטני', en: '1-on-1 Tasmee\'') : trByLang(langCode, ar: 'متابعة فردية', he: 'מעקב פרטני', en: '1-on-1 Follow-up')}',
      badgeBgColor: const Color(0x8089F5E7),
      badgeTextColor: TeacherHomeTokens.primary,
      topIcon: Icons.schedule_rounded,
      topIconColor: TeacherHomeTokens.primary,
      taskIcon: Icons.bookmark_rounded,
      taskIconColor: TeacherHomeTokens.primary,
      actionIcon: Icons.arrow_forward_rounded,
      isPrimaryAction: true,
      hasTopBarAccent: true,
    );
  }).toList();

  list.sort((a, b) => a.sortMinutes.compareTo(b.sortMinutes));
  return list;
}

List<TeacherScheduleEntry> buildTeacherScheduleForWeekday({
  required int weekday,
  required List<StudyGroup> groups,
  required List<Enrollment> enrollments,
  required String langCode,
  required bool isDemoFallback,
}) {
  final entries = <TeacherScheduleEntry>[];
  final effectiveGroups = groups.isNotEmpty
      ? groups
      : (isDemoFallback ? teacherDemoScheduleGroups : const <StudyGroup>[]);

  for (final g in effectiveGroups) {
    final daySlots = g.slotsForWeekday(weekday);
    if (daySlots.isEmpty) continue;
    final count = enrollments.where((e) => e.groupId == g.id).length;
    for (final slot in daySlots) {
      final range = slot.formatTimeRange();
      entries.add(
        TeacherScheduleEntry(
          isGroupSession: true,
          weekday: weekday,
          timeLabel: range.isNotEmpty ? range : '—',
          sortMinutes: slot.sortMinutes,
          groupId: g.id,
          title: g.name,
          subtitle: g.track.localizedName(langCode),
          track: g.track,
          enrolledCount: count > 0 ? count : (isDemoFallback ? g.capacity : 0),
        ),
      );
    }
  }

  final oneOnOneSlots = enrollments.isNotEmpty
      ? buildOneOnOneSlotsFromEnrollments(enrollments: enrollments, langCode: langCode)
      : (isDemoFallback ? teacherDemoWeeklyOneOnOneSlots : const <OneOnOneSlotData>[]);

  for (final slot in oneOnOneSlots) {
    final matchesDay = slot.weekday == weekday || (slot.weekday == null && weekday == DateTime.now().weekday);
    if (!matchesDay) continue;
    final matchedGroup = effectiveGroups.where((g) => g.id == slot.groupId).firstOrNull;
    entries.add(
      TeacherScheduleEntry(
        isGroupSession: false,
        weekday: weekday,
        timeLabel: slot.timeLabel,
        sortMinutes: slot.sortMinutes,
        groupId: slot.groupId,
        title: slot.studentName,
        subtitle: slot.groupName.isNotEmpty
            ? '${slot.groupName} • ${slot.taskTitle}'
            : slot.taskTitle,
        track: matchedGroup?.track ?? CenterTrack.hifz,
        oneOnOneSlot: slot,
      ),
    );
  }

  entries.sort((a, b) {
    final cmp = a.sortMinutes.compareTo(b.sortMinutes);
    if (cmp != 0) return cmp;
    if (a.isGroupSession != b.isGroupSession) return a.isGroupSession ? -1 : 1;
    return a.title.compareTo(b.title);
  });
  return entries;
}

const List<StudyGroup> teacherDemoScheduleGroups = [
  StudyGroup(
    id: 'grp-hifz-1',
    name: 'حلقة أبي بكر الصديق',
    track: CenterTrack.hifz,
    teacherId: 'teacher-1',
    scheduleSlots: [
      GroupScheduleSlot(day: 'الأحد', startTime: '16:30', endTime: '18:00'),
      GroupScheduleSlot(day: 'الثلاثاء', startTime: '16:30', endTime: '18:00'),
      GroupScheduleSlot(day: 'الخميس', startTime: '17:00', endTime: '18:30'),
    ],
    capacity: 12,
  ),
  StudyGroup(
    id: 'grp-tajweed-1',
    name: 'حلقة الإتقان والتجويد',
    track: CenterTrack.readingTajweed,
    teacherId: 'teacher-1',
    scheduleSlots: [
      GroupScheduleSlot(day: 'السبت', startTime: '18:45', endTime: '19:45'),
      GroupScheduleSlot(day: 'الاثنين', startTime: '18:45', endTime: '19:45'),
      GroupScheduleSlot(day: 'الأربعاء', startTime: '18:45', endTime: '19:45'),
    ],
    capacity: 8,
  ),
  StudyGroup(
    id: 'grp-nouraniah-1',
    name: 'حلقة البراعم النورانية',
    track: CenterTrack.qaidahNouraniah,
    teacherId: 'teacher-1',
    scheduleSlots: [
      GroupScheduleSlot(day: 'السبت', startTime: '16:00', endTime: '17:00'),
      GroupScheduleSlot(day: 'الأحد', startTime: '16:00', endTime: '17:00'),
      GroupScheduleSlot(day: 'الاثنين', startTime: '16:00', endTime: '17:00'),
      GroupScheduleSlot(day: 'الثلاثاء', startTime: '16:00', endTime: '17:00'),
      GroupScheduleSlot(day: 'الأربعاء', startTime: '16:00', endTime: '17:00'),
      GroupScheduleSlot(day: 'الخميس', startTime: '16:00', endTime: '17:00'),
    ],
    capacity: 10,
  ),
  StudyGroup(
    id: 'grp-tarbawi-1',
    name: 'حلقة التربية والتدبر',
    track: CenterTrack.tarbawi,
    teacherId: 'teacher-1',
    scheduleSlots: [
      GroupScheduleSlot(day: 'الجمعة', startTime: '08:00', endTime: '09:30'),
    ],
    capacity: 15,
  ),
];

const List<OneOnOneSlotData> teacherDemoWeeklyOneOnOneSlots = [
  OneOnOneSlotData(
    studentId: 'st-1042',
    groupId: 'grp-hifz-1',
    groupName: 'حلقة أبي بكر الصديق',
    timeLabel: '16:30',
    weekday: DateTime.sunday,
    sortMinutes: 16 * 60 + 30,
    studentName: 'إبراهيم طه',
    taskTitle: 'حفظ سورة النحل',
    rangeSubtitle: 'الآيات: ١ - ٣٠',
    badgeBgColor: Color(0x8089F5E7),
    badgeTextColor: TeacherHomeTokens.primary,
    topIcon: Icons.verified_rounded,
    topIconColor: TeacherHomeTokens.primary,
    taskIcon: Icons.bookmark_rounded,
    taskIconColor: TeacherHomeTokens.primary,
    actionIcon: Icons.play_arrow_rounded,
    isPrimaryAction: true,
    hasTopBarAccent: true,
  ),
  OneOnOneSlotData(
    studentId: 'st-1088',
    groupId: 'grp-hifz-1',
    groupName: 'حلقة أبي بكر الصديق',
    timeLabel: '17:00',
    weekday: DateTime.tuesday,
    sortMinutes: 17 * 60,
    studentName: 'عبد الرحمن يوسف',
    taskTitle: 'مراجعة سورة الكهف',
    rangeSubtitle: 'كامل السورة',
    badgeBgColor: Color(0x80FFDCC3),
    badgeTextColor: TeacherHomeTokens.secondary,
    topIcon: Icons.schedule_rounded,
    topIconColor: TeacherHomeTokens.onSurfaceVariant,
    taskIcon: Icons.cached_rounded,
    taskIconColor: TeacherHomeTokens.secondary,
    actionIcon: Icons.check_rounded,
  ),
  OneOnOneSlotData(
    studentId: 'st-1102',
    groupId: 'grp-tajweed-1',
    groupName: 'حلقة الإتقان والتجويد',
    timeLabel: '17:30',
    weekday: DateTime.wednesday,
    sortMinutes: 17 * 60 + 30,
    studentName: 'زياد المنصور',
    taskTitle: 'اختبار تجويد',
    rangeSubtitle: 'أحكام المدود',
    badgeBgColor: Color(0x80ABEFE8),
    badgeTextColor: TeacherHomeTokens.tertiary,
    topIcon: Icons.fact_check_outlined,
    topIconColor: TeacherHomeTokens.onSurfaceVariant,
    taskIcon: Icons.assignment_turned_in_outlined,
    taskIconColor: TeacherHomeTokens.tertiary,
    actionIcon: Icons.description_outlined,
  ),
  OneOnOneSlotData(
    studentId: 'st-1115',
    groupId: 'grp-hifz-1',
    groupName: 'حلقة أبي بكر الصديق',
    timeLabel: '18:00',
    weekday: DateTime.thursday,
    sortMinutes: 18 * 60,
    studentName: 'أحمد العلي',
    taskTitle: 'سرد الربع الأخير',
    rangeSubtitle: 'من الجزء الثلاثين',
    badgeBgColor: TeacherHomeTokens.surfaceContainer,
    badgeTextColor: TeacherHomeTokens.onSurfaceVariant,
    topIcon: Icons.mic_none_rounded,
    topIconColor: TeacherHomeTokens.onSurfaceVariant,
    taskIcon: Icons.record_voice_over_outlined,
    taskIconColor: TeacherHomeTokens.primary,
    actionIcon: Icons.arrow_forward_rounded,
  ),
];

const List<OneOnOneSlotData> teacherDemoTodaySlots = [
  OneOnOneSlotData(
    studentId: 'st-1042',
    groupId: 'grp-hifz-1',
    timeLabel: '١٦:٣٠',
    studentName: 'إبراهيم طه',
    taskTitle: 'حفظ سورة النحل',
    rangeSubtitle: 'الآيات: ١ - ٣٠',
    badgeBgColor: Color(0x8089F5E7),
    badgeTextColor: TeacherHomeTokens.primary,
    topIcon: Icons.verified_rounded,
    topIconColor: TeacherHomeTokens.primary,
    taskIcon: Icons.bookmark_rounded,
    taskIconColor: TeacherHomeTokens.primary,
    actionIcon: Icons.play_arrow_rounded,
    isPrimaryAction: true,
    hasTopBarAccent: true,
  ),
  OneOnOneSlotData(
    studentId: 'st-1088',
    groupId: 'grp-hifz-1',
    timeLabel: '١٧:٠٠',
    studentName: 'عبد الرحمن يوسف',
    taskTitle: 'مراجعة سورة الكهف',
    rangeSubtitle: 'كامل السورة',
    badgeBgColor: Color(0x80FFDCC3),
    badgeTextColor: TeacherHomeTokens.secondary,
    topIcon: Icons.schedule_rounded,
    topIconColor: TeacherHomeTokens.onSurfaceVariant,
    taskIcon: Icons.cached_rounded,
    taskIconColor: TeacherHomeTokens.secondary,
    actionIcon: Icons.check_rounded,
  ),
  OneOnOneSlotData(
    studentId: 'st-1102',
    groupId: 'grp-tajweed-1',
    timeLabel: '١٧:٣٠',
    studentName: 'زياد المنصور',
    taskTitle: 'اختبار تجويد',
    rangeSubtitle: 'أحكام المدود',
    badgeBgColor: Color(0x80ABEFE8),
    badgeTextColor: TeacherHomeTokens.tertiary,
    topIcon: Icons.fact_check_outlined,
    topIconColor: TeacherHomeTokens.onSurfaceVariant,
    taskIcon: Icons.assignment_turned_in_outlined,
    taskIconColor: TeacherHomeTokens.tertiary,
    actionIcon: Icons.description_outlined,
  ),
  OneOnOneSlotData(
    studentId: 'st-1115',
    groupId: 'grp-hifz-1',
    timeLabel: '١٨:٠٠',
    studentName: 'أحمد العلي',
    taskTitle: 'سرد الربع الأخير',
    rangeSubtitle: 'من الجزء الثلاثين',
    badgeBgColor: TeacherHomeTokens.surfaceContainer,
    badgeTextColor: TeacherHomeTokens.onSurfaceVariant,
    topIcon: Icons.mic_none_rounded,
    topIconColor: TeacherHomeTokens.onSurfaceVariant,
    taskIcon: Icons.record_voice_over_outlined,
    taskIconColor: TeacherHomeTokens.primary,
    actionIcon: Icons.arrow_forward_rounded,
  ),
];

String formatTeacherCurrentDate(DateTime date, String langCode) {
  const arDays = ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
  const heDays = ['יום שני', 'יום שלישי', 'יום רביעי', 'יום חמישי', 'יום שישי', 'שבת', 'יום ראשון'];
  const enDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  const arMonths = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  const heMonths = ['בינואר', 'בפברואר', 'במרץ', 'באפריל', 'במאי', 'ביוני', 'ביולי', 'באוגוסט', 'בספטמבר', 'באוקטובר', 'בנובמבר', 'בדצמבר'];
  const enMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  final weekdayIdx = date.weekday - 1;
  final monthIdx = date.month - 1;
  switch (langCode) {
    case 'he':
      return '${heDays[weekdayIdx]}, ${date.day} ${heMonths[monthIdx]} ${date.year}';
    case 'en':
      return '${enDays[weekdayIdx]}, ${enMonths[monthIdx]} ${date.day}, ${date.year}';
    case 'ar':
    default:
      return '${arDays[weekdayIdx]}، ${date.day} ${arMonths[monthIdx]} ${date.year}';
  }
}

String formatTeacherNum(int number, String langCode) {
  if (langCode != 'ar') return '$number';
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return '$number'.split('').map((char) {
    final digit = int.tryParse(char);
    return digit != null ? arabicDigits[digit] : char;
  }).join();
}

void showTeacherGroupOptionsSheet({
  required BuildContext context,
  required String groupId,
  required String groupTitle,
  required String langCode,
  required ValueChanged<String> onOpenGroupDetail,
  required ValueChanged<String> onOpenAttendanceLogging,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: TeacherHomeTokens.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TeacherHomeTokens.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                groupTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: TeacherHomeTokens.onSurface,
                    ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: TeacherHomeTokens.primaryFixed.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.groups_rounded, color: TeacherHomeTokens.primary),
                ),
                title: Text(
                  trByLang(
                    langCode,
                    ar: 'فتح الحلقة',
                    he: 'פתח קבוצה',
                    en: 'Open Group',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onOpenGroupDetail(groupId);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: TeacherHomeTokens.secondaryFixed.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.how_to_reg_rounded, color: TeacherHomeTokens.secondary),
                ),
                title: Text(
                  trByLang(
                    langCode,
                    ar: 'رصد الحضور السريع للحلقة',
                    he: 'רישום נוכחות מהיר לקבוצה',
                    en: 'Quick Group Attendance Logging',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onOpenAttendanceLogging(groupId);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> handleTeacherOneOnOneSlotTap({
  required BuildContext context,
  required WidgetRef ref,
  required OneOnOneSlotData slot,
  required String langCode,
  required ValueChanged<String> onOpenGroupDetail,
  void Function(String groupId, String studentId)? onOpenStudentProfile,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: TeacherHomeTokens.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${slot.studentName} • ${slot.timeLabel}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: slot.badgeBgColor, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      slot.taskTitle,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: slot.badgeTextColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(slot.rangeSubtitle, style: const TextStyle(color: TeacherHomeTokens.onSurfaceVariant)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(sheetContext).pop();
                        await ref.read(teacherControllerProvider.notifier).logAttendance(
                              groupId: slot.groupId,
                              studentId: slot.studentId,
                              studentName: slot.studentName,
                              status: AttendanceStatus.present,
                              sessionMode: SessionMode.oneOnOne,
                            );
                        messenger?.showSnackBar(
                          SnackBar(
                            content: Text(
                              trByLang(
                                langCode,
                                ar: 'تم تسجيل حضور جلسة التسميع الفردي للطالب ${slot.studentName}',
                                he: 'נרשמה נוכחות למפגש פרטני עבור ${slot.studentName}',
                                en: '1-on-1 attendance logged for ${slot.studentName}',
                              ),
                            ),
                            backgroundColor: TeacherHomeTokens.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TeacherHomeTokens.primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: Text(
                        trByLang(langCode, ar: 'تسجيل حاضر (فردي)', he: 'סמן נוכח (פרטני)', en: 'Mark Present (1-on-1)'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        onOpenGroupDetail(slot.groupId);
                      },
                      icon: const Icon(Icons.menu_book_rounded, size: 18),
                      label: Text(
                        trByLang(langCode, ar: 'فتح الحلقة', he: 'פתח קבוצה', en: 'Open Group'),
                      ),
                    ),
                  ),
                ],
              ),
              if (onOpenStudentProfile != null && slot.studentId.isNotEmpty) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    onOpenStudentProfile(slot.groupId, slot.studentId);
                  },
                  icon: const Icon(Icons.person_search_rounded, size: 18),
                  label: Text(
                    trByLang(langCode, ar: 'عرض ملف الطالب', he: 'פתח פרופיל תלמיד', en: 'View Student Profile'),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class TeacherBottomNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const TeacherBottomNavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = TeacherHomeTokens.primary;
    const inactiveColor = TeacherHomeTokens.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minWidth: 64, minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: isSelected ? activeColor : inactiveColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
