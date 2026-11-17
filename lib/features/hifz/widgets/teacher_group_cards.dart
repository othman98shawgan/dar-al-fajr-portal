import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_tr.dart';
import '../../admin/models/admin_models.dart';
import 'teacher_home_models.dart';

class TeacherMyGroupsSection extends StatelessWidget {
  final String langCode;
  final List<StudyGroup> firestoreGroups;
  final bool isDemoFallback;
  final VoidCallback onSwitchToScheduleTab;
  final ValueChanged<String> onOpenGroupDetail;
  final ValueChanged<String> onOpenAttendanceLogging;
  final void Function(String groupId, String groupTitle) onShowGroupOptions;

  const TeacherMyGroupsSection({
    super.key,
    required this.langCode,
    required this.firestoreGroups,
    required this.isDemoFallback,
    required this.onSwitchToScheduleTab,
    required this.onOpenGroupDetail,
    required this.onOpenAttendanceLogging,
    required this.onShowGroupOptions,
  });

  @override
  Widget build(BuildContext context) {
    final isLiveMode = !isDemoFallback;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu_book_rounded, color: TeacherHomeTokens.primary, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    trByLang(langCode, ar: 'حلقاتي التعليمية', he: 'הקבוצות החינוכיות שלי', en: 'My Study Groups'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: TeacherHomeTokens.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              InkWell(
                onTap: onSwitchToScheduleTab,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trByLang(langCode, ar: 'الجدول الأسبوعي', he: 'מערכת שעות שבועית', en: 'Weekly Schedule'),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: TeacherHomeTokens.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward_rounded, size: 16, color: TeacherHomeTokens.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (firestoreGroups.isNotEmpty)
          ...firestoreGroups.map((group) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _DynamicGroupCard(
                langCode: langCode,
                group: group,
                onOpenGroupDetail: () => onOpenGroupDetail(group.id),
                onOpenAttendanceLogging: () => onOpenAttendanceLogging(group.id),
              ),
            );
          })
        else if (isLiveMode)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.class_outlined,
                    size: 48,
                    color: TeacherHomeTokens.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    trByLang(
                      langCode,
                      ar: 'لا توجد حلقات مسندة إليك حالياً',
                      he: 'אין קבוצות המשויכות אליך כעת',
                      en: 'No study groups assigned to you yet',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: TeacherHomeTokens.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          _HifzPrimaryGroupCard(
            langCode: langCode,
            groupId: 'grp-hifz-1',
            onOpenGroupDetail: () => onOpenGroupDetail('grp-hifz-1'),
            onShowOptions: (title) => onShowGroupOptions('grp-hifz-1', title),
          ),
          const SizedBox(height: 16),
          _TajweedGroupCard(
            langCode: langCode,
            onOpenGroupDetail: () => onOpenGroupDetail('grp-tajweed-1'),
          ),
          const SizedBox(height: 16),
          _NouraniahGroupCard(
            langCode: langCode,
            onOpenGroupDetail: () => onOpenGroupDetail('grp-nouraniah-1'),
          ),
          const SizedBox(height: 16),
          _TarbawiGroupCard(
            langCode: langCode,
            onOpenGroupDetail: () => onOpenGroupDetail('grp-tarbawi-1'),
          ),
        ],
      ],
    );
  }
}

class _DynamicGroupCard extends StatelessWidget {
  final String langCode;
  final StudyGroup group;
  final VoidCallback onOpenGroupDetail;
  final VoidCallback onOpenAttendanceLogging;

  const _DynamicGroupCard({
    required this.langCode,
    required this.group,
    required this.onOpenGroupDetail,
    required this.onOpenAttendanceLogging,
  });

  @override
  Widget build(BuildContext context) {
    final Color trackColor;
    final Color trackFixedColor;
    final Color onTrackFixedColor;
    final IconData trackIcon;

    switch (group.track) {
      case CenterTrack.hifz:
        trackColor = TeacherHomeTokens.primary;
        trackFixedColor = TeacherHomeTokens.primaryFixed;
        onTrackFixedColor = TeacherHomeTokens.onPrimaryFixed;
        trackIcon = Icons.auto_stories_rounded;
        break;
      case CenterTrack.readingTajweed:
        trackColor = TeacherHomeTokens.secondary;
        trackFixedColor = TeacherHomeTokens.secondaryFixed;
        onTrackFixedColor = TeacherHomeTokens.onSecondaryFixed;
        trackIcon = Icons.record_voice_over_rounded;
        break;
      case CenterTrack.qaidahNouraniah:
        trackColor = TeacherHomeTokens.tertiary;
        trackFixedColor = TeacherHomeTokens.tertiaryFixed;
        onTrackFixedColor = TeacherHomeTokens.onTertiaryFixed;
        trackIcon = Icons.menu_book_rounded;
        break;
      case CenterTrack.tarbawi:
        trackColor = const Color(0xFF386A20);
        trackFixedColor = const Color(0xFFB7F397);
        onTrackFixedColor = const Color(0xFF042100);
        trackIcon = Icons.school_rounded;
        break;
    }

    final scheduleText = StringBuffer();
    if (group.scheduleDays.isNotEmpty) {
      scheduleText.write(group.scheduleDays.join(' • '));
    }
    if (group.startTime.isNotEmpty) {
      if (scheduleText.isNotEmpty) scheduleText.write(' • ');
      scheduleText.write(group.startTime);
      if (group.endTime.isNotEmpty) {
        scheduleText.write(' - ${group.endTime}');
      }
    }
    final displaySchedule = scheduleText.isNotEmpty
        ? scheduleText.toString()
        : trByLang(
            langCode,
            ar: 'مواعيد منتظمة بحسب الجدول الأسبوعي',
            he: 'זמנים קבועים לפי המערכת השבועית',
            en: 'Regular schedule per weekly calendar',
          );

    return Container(
      decoration: BoxDecoration(
        color: TeacherHomeTokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(top: 0, bottom: 0, start: 0, width: 6, child: Container(color: trackColor)),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                group.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: TeacherHomeTokens.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: trackFixedColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  group.track.localizedName(langCode),
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: onTrackFixedColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          if (group.teacherName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              group.teacherName,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: TeacherHomeTokens.onSurfaceVariant),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(color: TeacherHomeTokens.surfaceContainer, shape: BoxShape.circle),
                      child: Icon(trackIcon, color: trackColor, size: 20),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TeacherHomeTokens.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 18, color: trackColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          displaySchedule,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: TeacherHomeTokens.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: onOpenGroupDetail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: trackColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.menu_book_rounded, size: 18),
                          label: Text(
                            trByLang(
                              langCode,
                              ar: 'فتح تفاصيل ومقررات الحلقة',
                              he: 'פתח פרטי ומשימות קבוצה',
                              en: 'Open Group & Assignments',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: onOpenAttendanceLogging,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: trackColor,
                        side: BorderSide(color: trackColor.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(44, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      icon: const Icon(Icons.how_to_reg_rounded, size: 18),
                      label: Text(
                        trByLang(langCode, ar: 'رصد الحضور', he: 'רישום נוכחות', en: 'Attendance'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
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

class _HifzPrimaryGroupCard extends StatelessWidget {
  final String langCode;
  final String groupId;
  final VoidCallback onOpenGroupDetail;
  final ValueChanged<String> onShowOptions;

  const _HifzPrimaryGroupCard({
    required this.langCode,
    required this.groupId,
    required this.onOpenGroupDetail,
    required this.onShowOptions,
  });

  @override
  Widget build(BuildContext context) {
    final groupTitle = trByLang(
      langCode,
      ar: 'حلقة أبي بكر الصديق',
      he: 'קבוצת אבו בכר אל-סידיק',
      en: 'Abu Bakr As-Siddiq Circle',
    );

    return Container(
      decoration: BoxDecoration(
        color: TeacherHomeTokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(top: 0, bottom: 0, start: 0, width: 6, child: Container(color: TeacherHomeTokens.primary)),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                groupTitle,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: TeacherHomeTokens.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: TeacherHomeTokens.primaryFixed,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(color: TeacherHomeTokens.primary, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      trByLang(
                                        langCode,
                                        ar: 'مسار الحفظ المكثف',
                                        he: 'מסלול שינון מואץ',
                                        en: 'Intensive Hifz Track',
                                      ),
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: TeacherHomeTokens.onPrimaryFixed,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trByLang(
                              langCode,
                              ar: '١٢ طالباً مسجلاً • مرحلة الحفظ النهائي',
                              he: '12 תלמידים רשומים • שלב שינון מתקדם',
                              en: '12 enrolled students • Final Hifz stage',
                            ),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: TeacherHomeTokens.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(color: TeacherHomeTokens.surfaceContainer, shape: BoxShape.circle),
                      child: const Icon(Icons.auto_stories_rounded, color: TeacherHomeTokens.primary, size: 20),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TeacherHomeTokens.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 18, color: TeacherHomeTokens.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          trByLang(
                            langCode,
                            ar: 'الأحد والثلاثاء والخميس • بعد العصر (٤:٣٠ م - ٦:٠٠ م)',
                            he: 'א׳, ג׳, ה׳ • אחר הצהריים (16:30 - 18:00)',
                            en: 'Sun, Tue & Thu • Afternoon (4:30 PM - 6:00 PM)',
                          ),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: TeacherHomeTokens.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          trByLang(
                            langCode,
                            ar: 'إنجاز الخطة الشهرية (الجزء ٢٧ - الذاريات)',
                            he: 'התקדמות תוכנית חודשית (ג׳וז 27 - א-ד׳אריאת)',
                            en: 'Monthly Plan Progress (Juz 27 - Adh-Dhariyat)',
                          ),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: TeacherHomeTokens.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        Text(
                          langCode == 'ar' ? '٧٨٪' : '78%',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: TeacherHomeTokens.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: const LinearProgressIndicator(
                        value: 0.78,
                        minHeight: 8,
                        backgroundColor: TeacherHomeTokens.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation<Color>(TeacherHomeTokens.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: onOpenGroupDetail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TeacherHomeTokens.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.how_to_reg_rounded, size: 18),
                          label: Text(
                            trByLang(
                              langCode,
                              ar: 'فتح الحلقة ورصد الحضور',
                              he: 'פתח קבוצה ורשום נוכחות',
                              en: 'Open Group & Log Attendance',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: TeacherHomeTokens.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => onShowOptions(groupTitle),
                        borderRadius: BorderRadius.circular(12),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.more_vert_rounded, color: TeacherHomeTokens.onSurfaceVariant, size: 20),
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
    );
  }
}

class _TajweedGroupCard extends StatelessWidget {
  final String langCode;
  final VoidCallback onOpenGroupDetail;

  const _TajweedGroupCard({required this.langCode, required this.onOpenGroupDetail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TeacherHomeTokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          trByLang(
                            langCode,
                            ar: 'حلقة الإتقان والتجويد',
                            he: 'קבוצת דיוק וטג׳וויד',
                            en: 'Mastery & Tajweed Circle',
                          ),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: TeacherHomeTokens.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: TeacherHomeTokens.secondaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            trByLang(langCode, ar: 'تجويد متقدم', he: 'טג׳וויד מתקדם', en: 'Advanced Tajweed'),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: TeacherHomeTokens.onSecondaryFixed,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trByLang(
                        langCode,
                        ar: '٨ طلاب • متن الجزرية ومخارج الحروف',
                        he: '8 תלמידים • מתן אל-ג׳זריה ומוצאי האותיות',
                        en: '8 students • Al-Jazariyyah & Articulation',
                      ),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: TeacherHomeTokens.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: TeacherHomeTokens.secondaryFixedDim.withValues(alpha: 0.30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.record_voice_over_rounded, color: TeacherHomeTokens.secondary, size: 20),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TeacherHomeTokens.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 18, color: TeacherHomeTokens.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trByLang(
                      langCode,
                      ar: 'السبت والاثنين والأربعاء • بعد المغرب (٦:٤٥ م)',
                      he: 'שבת, ב׳, ד׳ • אחרי מעריב (18:45)',
                      en: 'Sat, Mon & Wed • After Maghrib (6:45 PM)',
                    ),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: TeacherHomeTokens.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.task_alt_rounded, size: 16, color: TeacherHomeTokens.secondary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        trByLang(
                          langCode,
                          ar: 'تم تصحيح تلاوة ٥ طلاب أمس',
                          he: 'תוקנה קריאה של 5 תלמידים אתמול',
                          en: '5 students graded yesterday',
                        ),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: TeacherHomeTokens.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: TeacherHomeTokens.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onOpenGroupDetail,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history_edu_rounded, size: 18, color: TeacherHomeTokens.onSurface),
                        const SizedBox(width: 6),
                        Text(
                          trByLang(langCode, ar: 'سجل المتابعة', he: 'יומן מעקב', en: 'Follow-up Log'),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: TeacherHomeTokens.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NouraniahGroupCard extends StatelessWidget {
  final String langCode;
  final VoidCallback onOpenGroupDetail;

  const _NouraniahGroupCard({required this.langCode, required this.onOpenGroupDetail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TeacherHomeTokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          trByLang(
                            langCode,
                            ar: 'حلقة البراعم النورانية',
                            he: 'קבוצת ניצני אל-נוראניה',
                            en: 'Nouraniah Sprouts Circle',
                          ),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: TeacherHomeTokens.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: TeacherHomeTokens.tertiaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            trByLang(langCode, ar: 'القاعدة النورانية', he: 'קאעידה נוראניה', en: "Qa'idah Nouraniah"),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: TeacherHomeTokens.onTertiaryFixed,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trByLang(
                        langCode,
                        ar: '١٠ طلاب • الدرس الحادي عشر: السكون',
                        he: '10 תלמידים • שיעור 11: סוכון',
                        en: '10 students • Lesson 11: Sukoon',
                      ),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: TeacherHomeTokens.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: TeacherHomeTokens.tertiaryFixedDim.withValues(alpha: 0.30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.child_care_rounded, color: TeacherHomeTokens.tertiary, size: 20),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TeacherHomeTokens.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_repeat_rounded, size: 18, color: TeacherHomeTokens.tertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trByLang(
                      langCode,
                      ar: 'يومياً عدا الجمعة • ٤:٠٠ م',
                      he: 'כל يوم פרט לשישי • 16:00',
                      en: 'Daily except Friday • 4:00 PM',
                    ),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: TeacherHomeTokens.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  trByLang(
                    langCode,
                    ar: 'المقر الحالي: القاعة التعليمية ٢',
                    he: 'מיקום נוכחי: חדר לימוד 2',
                    en: 'Location: Classroom 2',
                  ),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: TeacherHomeTokens.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: TeacherHomeTokens.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onOpenGroupDetail,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          trByLang(langCode, ar: 'عرض الحلقة', he: 'הצג קבוצה', en: 'View Group'),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: TeacherHomeTokens.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: TeacherHomeTokens.onSurface),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarbawiGroupCard extends StatelessWidget {
  final String langCode;
  final VoidCallback onOpenGroupDetail;

  const _TarbawiGroupCard({required this.langCode, required this.onOpenGroupDetail});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpenGroupDetail,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TeacherHomeTokens.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            trByLang(
                              langCode,
                              ar: 'حلقة التربية والتدبر',
                              he: 'קבוצת חינוך והתבוננות',
                              en: 'Tarbawi & Reflection Circle',
                            ),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: TeacherHomeTokens.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: TeacherHomeTokens.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              trByLang(langCode, ar: 'مسار تربوي', he: 'מסלול חינוכי', en: 'Tarbawi Track'),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: TeacherHomeTokens.onSurfaceVariant,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trByLang(
                          langCode,
                          ar: '١٥ طالباً • مدارسة قصص الأنبياء وأخلاق القرآن',
                          he: '15 תלמידים • סיפורי הנביאים ומידות הקוראן',
                          en: '15 students • Stories of the Prophets & Ethics',
                        ),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: TeacherHomeTokens.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(color: TeacherHomeTokens.surfaceContainer, shape: BoxShape.circle),
                  child: const Icon(Icons.psychology_alt_rounded, color: TeacherHomeTokens.onSurfaceVariant, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TeacherHomeTokens.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.date_range_rounded, size: 18, color: TeacherHomeTokens.primary),
                      const SizedBox(width: 8),
                      Text(
                        trByLang(langCode, ar: 'الجمعة • ٨:٠٠ ص', he: 'יום שישי • 8:00 בבוקר', en: 'Friday • 8:00 AM'),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: TeacherHomeTokens.onSurfaceVariant),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: TeacherHomeTokens.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      trByLang(langCode, ar: 'أسبوعي', he: 'שבועי', en: 'Weekly'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: TeacherHomeTokens.onSurfaceVariant,
                            fontSize: 11,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
