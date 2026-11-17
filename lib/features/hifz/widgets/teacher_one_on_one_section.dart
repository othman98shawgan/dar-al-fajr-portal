import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_tr.dart';
import 'teacher_home_models.dart';

class TeacherTodayOneOnOneSection extends StatelessWidget {
  final String langCode;
  final List<OneOnOneSlotData> slots;
  final ValueChanged<OneOnOneSlotData> onSlotTap;

  const TeacherTodayOneOnOneSection({
    super.key,
    required this.langCode,
    required this.slots,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.person_pin_circle_rounded, color: TeacherHomeTokens.secondary, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    trByLang(langCode, ar: 'جلسات فردية اليوم', he: 'מפגשים פרטניים להיום', en: "Today's 1-on-1 Slots"),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: TeacherHomeTokens.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: TeacherHomeTokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${formatTeacherNum(slots.length, langCode)} ${trByLang(langCode, ar: 'جلسات مجدولة', he: 'מפגשים מתוכננים', en: 'slots scheduled')}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: TeacherHomeTokens.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (slots.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: TeacherHomeTokens.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 40,
                    color: TeacherHomeTokens.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trByLang(
                      langCode,
                      ar: 'لا توجد جلسات فردية مجدولة لليوم',
                      he: 'אין מפגשים פרטניים מתוכננים להיום',
                      en: 'No individual 1-on-1 slots scheduled today',
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
        else
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: slots.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final slot = slots[index];
                return InkWell(
                  onTap: () => onSlotTap(slot),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 210,
                    decoration: BoxDecoration(
                      color: TeacherHomeTokens.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        if (slot.hasTopBarAccent)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 4,
                            child: Container(color: TeacherHomeTokens.primary),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: slot.badgeBgColor,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          slot.timeLabel,
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                color: slot.badgeTextColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      Icon(slot.topIcon, size: 18, color: slot.topIconColor),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    slot.studentName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: TeacherHomeTokens.onSurface,
                                          fontWeight: FontWeight.w600,
                                          height: 1.25,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(slot.taskIcon, size: 16, color: slot.taskIconColor),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          slot.taskTitle,
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                color: TeacherHomeTokens.onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: TeacherHomeTokens.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        slot.rangeSubtitle,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: TeacherHomeTokens.onSurfaceVariant,
                                              fontSize: 11,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: slot.isPrimaryAction
                                            ? TeacherHomeTokens.primary
                                            : TeacherHomeTokens.surfaceContainerHigh,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        slot.actionIcon,
                                        size: 16,
                                        color: slot.isPrimaryAction ? Colors.white : TeacherHomeTokens.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class TeacherMotivationalHadithCard extends StatelessWidget {
  final String langCode;

  const TeacherMotivationalHadithCard({super.key, required this.langCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TeacherHomeTokens.primary.withValues(alpha: 0.10),
            TeacherHomeTokens.primary.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: TeacherHomeTokens.primary, shape: BoxShape.circle),
            child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trByLang(langCode, ar: 'تذكير نبوي شريف', he: 'תזכורת נבואית מבורכת', en: 'Prophetic Reminder'),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: TeacherHomeTokens.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  trByLang(
                    langCode,
                    ar: '"خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ" — بارك الله في أوقاتكم وسعيكم.',
                    he: '"הטובים שבכם הם אלה שלומדים את הקוראן ומלמדים אותו" — יברך אללה את זמנכם.',
                    en: '"The best among you are those who learn the Quran and teach it."',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TeacherHomeTokens.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherDailyScheduleTab extends StatelessWidget {
  final String langCode;
  final List<OneOnOneSlotData> slots;
  final ValueChanged<OneOnOneSlotData> onSlotTap;

  const TeacherDailyScheduleTab({
    super.key,
    required this.langCode,
    required this.slots,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top + 64 + 16;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 64 + 24;

    return ListView(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding, left: 16, right: 16),
      children: [
        Text(
          trByLang(
            langCode,
            ar: 'الجدول اليومي وجلسات التسميع',
            he: 'לוח זמנים יומי ומפגשי שינון',
            en: 'Daily Schedule & Recitation Slots',
          ),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: TeacherHomeTokens.onSurface,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          trByLang(
            langCode,
            ar: 'مواعيد الحلقات الجماعية والجلسات الفردية المجدولة لهذا اليوم',
            he: 'זמני השיעורים הקבוצתיים והמפגשים הפרטניים להיום',
            en: 'Group classes and individual 1-on-1 slots scheduled for today',
          ),
          style: const TextStyle(color: TeacherHomeTokens.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        if (slots.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: 48,
                    color: TeacherHomeTokens.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    trByLang(
                      langCode,
                      ar: 'لا توجد جلسات فردية مجدولة لليوم',
                      he: 'אין מפגשים פרטניים מתוכננים להיום',
                      en: 'No individual 1-on-1 slots scheduled today',
                    ),
                    style: const TextStyle(color: TeacherHomeTokens.onSurfaceVariant, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          )
        else
          ...slots.map((slot) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onSlotTap(slot),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TeacherHomeTokens.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: slot.badgeBgColor, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          slot.timeLabel,
                          style: TextStyle(fontWeight: FontWeight.bold, color: slot.badgeTextColor),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(slot.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(
                              '${slot.taskTitle} • ${slot.rangeSubtitle}',
                              style: const TextStyle(color: TeacherHomeTokens.onSurfaceVariant, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: TeacherHomeTokens.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
