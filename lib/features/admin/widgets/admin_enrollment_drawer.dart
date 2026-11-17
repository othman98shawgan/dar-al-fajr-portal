import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../models/admin_models.dart';
import '../providers/admin_providers.dart';
import 'admin_shell_models.dart';

class AdminEnrollmentDrawer extends ConsumerWidget {
  final String langCode;
  final List<AdminRosterRowData> rosterRows;
  final String selectedStudentId;
  final String selectedStudentName;
  final String selectedStudentCode;
  final CenterTrack selectedTargetTrack;
  final String selectedGroupId;
  final String selectedGroupLabel;
  final bool hasOneOnOneSlot;
  final String selectedOneOnOneDay;
  final String selectedOneOnOneTime;
  final bool isDemoFallback;
  final bool hasQaidahTajweedConflict;
  final bool isAlreadyEnrolledInGroup;
  final VoidCallback onClose;
  final ValueChanged<AdminRosterRowData> onStudentSelected;
  final void Function(CenterTrack track, String groupId, String groupName) onGroupSelected;
  final ValueChanged<bool> onOneOnOneToggled;
  final ValueChanged<String> onOneOnOneDaySelected;
  final VoidCallback onPickOneOnOneTime;
  final VoidCallback onSaveEnrollment;

  const AdminEnrollmentDrawer({
    super.key,
    required this.langCode,
    required this.rosterRows,
    required this.selectedStudentId,
    required this.selectedStudentName,
    required this.selectedStudentCode,
    required this.selectedTargetTrack,
    required this.selectedGroupId,
    required this.selectedGroupLabel,
    required this.hasOneOnOneSlot,
    required this.selectedOneOnOneDay,
    required this.selectedOneOnOneTime,
    required this.isDemoFallback,
    required this.hasQaidahTajweedConflict,
    this.isAlreadyEnrolledInGroup = false,
    required this.onClose,
    required this.onStudentSelected,
    required this.onGroupSelected,
    required this.onOneOnOneToggled,
    required this.onOneOnOneDaySelected,
    required this.onPickOneOnOneTime,
    required this.onSaveEnrollment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: const Color(0xFF2D3133).withValues(alpha: 0.4),
          alignment: AlignmentDirectional.centerEnd,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 430,
              height: double.infinity,
              decoration: BoxDecoration(
                color: DarAlFajrTheme.surface,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 24)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Drawer Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.group_add_rounded, color: DarAlFajrTheme.primary, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    trByLang(
                                      langCode,
                                      ar: 'تسجيل طالب في حلقة',
                                      he: 'רישום תלמיד לקבוצה',
                                      en: 'Enroll Student in Group',
                                    ),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                trByLang(
                                  langCode,
                                  ar: 'تحديد المسار، المجموعة، والمواعيد الفردية للطالب',
                                  he: 'בחירת מסלול, קבוצה ומועדים אישיים לתלמיד',
                                  en: 'Select track, group, and 1-on-1 arrival slots',
                                ),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6D7A77)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onClose,
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFECEEF0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.close_rounded, size: 20),
                        ),
                      ],
                    ),
                  ),

                  // Drawer Scrollable Form Body
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        Row(
                          children: [
                            Text(
                              trByLang(langCode, ar: 'اختيار الطالب', he: 'בחירת תלמיד', en: 'Select Student'),
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '*',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        PopupMenuButton<AdminRosterRowData>(
                          onSelected: onStudentSelected,
                          itemBuilder: (context) => rosterRows
                              .map((r) => PopupMenuItem(value: r, child: Text('${r.fullName} (${r.code})')))
                              .toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        color: DarAlFajrTheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        selectedStudentName.isNotEmpty ? selectedStudentName.characters.first : 'إ',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedStudentName,
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'رقم القيد: $selectedStudentCode',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: DarAlFajrTheme.primary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Icon(Icons.expand_more_rounded, color: Color(0xFF6D7A77)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Text(
                              trByLang(
                                langCode,
                                ar: 'المسار والحلقة المستهدفة',
                                he: 'מסלול וקבוצת יעד',
                                en: 'Target Track & Group',
                              ),
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '*',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        PopupMenuButton<(CenterTrack, String, String)>(
                          onSelected: (tuple) => onGroupSelected(tuple.$1, tuple.$2, tuple.$3),
                          itemBuilder: (context) {
                            final liveGroups = ref.read(adminGroupsProvider).value ?? [];
                            if (liveGroups.isNotEmpty) {
                              return liveGroups
                                  .map(
                                    (g) => PopupMenuItem<(CenterTrack, String, String)>(
                                      value: (g.track, g.id, g.name),
                                      child: Text('${g.name} (${g.formatScheduleSummary(langCode)})'),
                                    ),
                                  )
                                  .toList();
                            }
                            if (isDemoFallback) {
                              return const [
                                PopupMenuItem(
                                  value: (
                                    CenterTrack.readingTajweed,
                                    'grp-tajweed-1',
                                    'حلقة الإتقان والتجويد (مسار التجويد المتقدم)',
                                  ),
                                  child: Text('حلقة الإتقان والتجويد (مسار التجويد المتقدم)'),
                                ),
                                PopupMenuItem(
                                  value: (CenterTrack.hifz, 'grp-hifz-1', 'حلقة الفجر للحفظ المكثف (مسار الحفظ)'),
                                  child: Text('حلقة الفجر للحفظ المكثف (مسار الحفظ)'),
                                ),
                                PopupMenuItem(
                                  value: (
                                    CenterTrack.qaidahNouraniah,
                                    'grp-qaidah-1',
                                    'حلقة القاعدة النورانية التأسيسية',
                                  ),
                                  child: Text('حلقة القاعدة النورانية التأسيسية'),
                                ),
                                PopupMenuItem(
                                  value: (
                                    CenterTrack.tarbawi,
                                    'grp-tarbawi-1',
                                    'حلقة الآداب والتدبر (المسار التربوي)',
                                  ),
                                  child: Text('حلقة الآداب والتدبر (المسار التربوي)'),
                                ),
                              ];
                            }
                            return [
                              PopupMenuItem<(CenterTrack, String, String)>(
                                enabled: false,
                                child: Text(
                                  trByLang(
                                    langCode,
                                    ar: 'لا توجد حلقات مسجلة — أنشئ حلقة أولاً',
                                    he: 'אין קבוצות עדיין — צור קבוצה תחילה',
                                    en: 'No study groups yet — create one first',
                                  ),
                                ),
                              ),
                            ];
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.menu_book_rounded, size: 20, color: DarAlFajrTheme.accent),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          selectedGroupLabel,
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.expand_more_rounded, color: Color(0xFF6D7A77)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (isAlreadyEnrolledInGroup) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDAD6).withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.block_rounded, color: Theme.of(context).colorScheme.error, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    trByLang(
                                      langCode,
                                      ar: 'الطالب مسجل بالفعل في هذه الحلقة. لا يمكن تكرار التسجيل في نفس الحلقة.',
                                      he: 'התלמיד כבר רשום לקבוצה זו. לא ניתן לרשום פעמיים.',
                                      en: 'This student is already enrolled in this group. Duplicate enrollment is not allowed.',
                                    ),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.error,
                                          fontWeight: FontWeight.w600,
                                          height: 1.4,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (hasQaidahTajweedConflict) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDAD6).withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'تنبيه: لا يمكن تسجيل الطالب في القاعدة النورانية والتجويد في نفس الوقت',
                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                              color: Theme.of(context).colorScheme.error,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'الطالب مسجل حالياً في مسار القاعدة النورانية. يرجى إتمام المسار أو إلغاء التسجيل السابق قبل الانضمام لحلقة التجويد.',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.9),
                                              height: 1.4,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        const Divider(color: Color(0xFFE6E8EA)),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.record_voice_over_rounded, color: DarAlFajrTheme.accent, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trByLang(
                                            langCode,
                                            ar: 'تخصيص موعد فردي (1-on-1)',
                                            he: 'הקצאת מועד אישי (1-on-1)',
                                            en: 'Assign 1-on-1 Slot',
                                          ),
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          trByLang(
                                            langCode,
                                            ar: 'جلسة تسميع فردية خاصة مع الشيخ',
                                            he: 'מפגש דקלום אישי עם המורה',
                                            en: 'Private recitation slot with the teacher',
                                          ),
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF6D7A77)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: hasOneOnOneSlot,
                              activeThumbColor: Colors.white,
                              activeTrackColor: DarAlFajrTheme.primary,
                              onChanged: onOneOnOneToggled,
                            ),
                          ],
                        ),

                        if (hasOneOnOneSlot) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            trByLang(
                                              langCode,
                                              ar: 'يوم الجلسة الفردية',
                                              he: 'יום המפגש האישי',
                                              en: '1-on-1 Day',
                                            ),
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF6D7A77)),
                                          ),
                                          const SizedBox(height: 4),
                                          PopupMenuButton<String>(
                                            onSelected: onOneOnOneDaySelected,
                                            itemBuilder: (context) => adminWeekDaysAr
                                                .map((d) => PopupMenuItem(value: d, child: Text(d)))
                                                .toList(),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: DarAlFajrTheme.surface,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    selectedOneOnOneDay,
                                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                  const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF6D7A77)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            trByLang(
                                              langCode,
                                              ar: 'وقت الحضور الفردي',
                                              he: 'שעת הגעה אישית',
                                              en: '1-on-1 Arrival Time',
                                            ),
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF6D7A77)),
                                          ),
                                          const SizedBox(height: 4),
                                          InkWell(
                                            onTap: onPickOneOnOneTime,
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: DarAlFajrTheme.surface,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    selectedOneOnOneTime,
                                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                  const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF6D7A77)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: DarAlFajrTheme.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF904D00)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Builder(
                                          builder: (context) {
                                            final liveGroups = ref.watch(adminGroupsProvider).asData?.value ?? const [];
                                            final matchedGroup = liveGroups
                                                .where((g) => g.id == selectedGroupId)
                                                .firstOrNull;
                                            final teacherName = matchedGroup != null && matchedGroup.teacherName.trim().isNotEmpty
                                                ? matchedGroup.teacherName.trim()
                                                : (isDemoFallback
                                                    ? 'الشيخ عبد الرحمن'
                                                    : trByLang(langCode, ar: 'المعلم المشرف', he: 'המורה האחראי', en: 'Group Teacher'));
                                            return Text(
                                              trByLang(
                                                langCode,
                                                ar: 'المدة: 30 دقيقة - مع $teacherName',
                                                he: 'משך: 30 דקות - עם $teacherName',
                                                en: 'Duration: 30 mins - with $teacherName',
                                              ),
                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                    color: const Color(0xFF904D00),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Drawer Action Footer
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: DarAlFajrTheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: isAlreadyEnrolledInGroup ? null : onSaveEnrollment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DarAlFajrTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                          label: Text(
                            trByLang(
                              langCode,
                              ar: 'حفظ التسجيل والتثبيت',
                              he: 'שמור ואשר רישום',
                              en: 'Save & Confirm Enrollment',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: onClose,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFECEEF0),
                            foregroundColor: const Color(0xFF3D4947),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            trByLang(langCode, ar: 'إلغاء الأمر', he: 'ביטול', en: 'Cancel'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
