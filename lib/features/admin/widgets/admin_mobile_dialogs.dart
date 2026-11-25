import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../../auth/models/app_user.dart';
import '../models/admin_models.dart';
import '../providers/admin_providers.dart';
import '../repositories/admin_repository.dart';
import 'admin_dialogs.dart';
import 'admin_mobile_models.dart';
import 'admin_shell_models.dart';

void showMobileAdminActionModal(
  BuildContext context,
  WidgetRef ref,
  String langCode, {
  required bool isDemoMode,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalCtx) {
      final isRtl = Directionality.of(context) == TextDirection.rtl;
      return Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      trByLang(langCode, ar: 'إجراء إداري جديد', he: 'פעולה ניהולית חדשה', en: 'New Administrative Action'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: DarAlFajrTheme.onSurface,
                          ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(modalCtx).pop(),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFE6E8EA),
                        foregroundColor: const Color(0xFF3D4947),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  trByLang(
                    langCode,
                    ar: 'اختر نوع التسجيل للبدء في إدخال بيانات المسار وحجز المواعيد التعليمية:',
                    he: 'בחר סוג רישום כדי להתחיל בהזנת נתוני מסלול ומועדים:',
                    en: 'Select an action to enroll students or create new study groups:',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6D7A77)),
                ),
                const SizedBox(height: 20),
                Material(
                  color: const Color(0xFFF2F4F6),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(modalCtx).pop();
                      showMobileCreateStudentDialog(context, ref, langCode);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: DarAlFajrTheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person_add_rounded, color: DarAlFajrTheme.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trByLang(langCode, ar: 'إنشاء طالب أو مستخدم', he: 'יצירת תלמיד או משתמש', en: 'Create Student or User'),
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: DarAlFajrTheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  trByLang(
                                    langCode,
                                    ar: 'تسجيل طالب، ولي أمر، أو معلم جديد',
                                    he: 'רישום תלמיד, הורה או מורה חדש',
                                    en: 'Register a new student, parent, or teacher',
                                  ),
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF6D7A77)),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF6D7A77)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: const Color(0xFFF2F4F6),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(modalCtx).pop();
                      showMobileCreateGroupDialog(context, ref, langCode, isDemoMode: isDemoMode);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFE932C).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.groups_rounded, color: Color(0xFF904D00), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trByLang(langCode, ar: 'إنشاء حلقة جديدة', he: 'יצירת קבוצה חדשה', en: 'Create New Study Group'),
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: DarAlFajrTheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  trByLang(
                                    langCode,
                                    ar: 'تحديد المعلم المشرف والأيام ومسار الحفظ',
                                    he: 'הגדרת מורה אחראי, ימים ומסלול שינון',
                                    en: 'Assign teacher, weekly days, and track',
                                  ),
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF6D7A77)),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF6D7A77)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void showMobileCreateStudentDialog(
  BuildContext context,
  WidgetRef ref,
  String langCode,
) {
  showAdminAddStudentOrUserDialog(
    context,
    ref,
    langCode,
    initialRole: UserRole.student,
  );
}

void showMobileCreateGroupDialog(
  BuildContext context,
  WidgetRef ref,
  String langCode, {
  required bool isDemoMode,
}) {
  showAdminCreateGroupDialog(
    context,
    ref,
    langCode,
    isDemoFallback: isDemoMode,
  );
}

void showMobileEnrollmentSheet(
  BuildContext context,
  WidgetRef ref,
  MobileStudentCardData student,
  String langCode,
  List<StudyGroup> firestoreGroups, {
  required bool isDemoMode,
}) {
  CenterTrack selectedTrack = student.primaryTrack;
  String selectedGroupId = firestoreGroups.isNotEmpty
      ? firestoreGroups.first.id
      : (isDemoMode ? 'grp-tajweed-1' : '');
  String selectedGroupName = firestoreGroups.isNotEmpty
      ? firestoreGroups.first.name
      : (isDemoMode ? 'حلقة الإتقان والتجويد (مسار التجويد)' : '');
  bool hasOneOnOne = true;
  String oneOnOneDay = 'الخميس';
  String oneOnOneTime = '17:15';
  final messenger = ScaffoldMessenger.maybeOf(context);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
      final isRtl = Directionality.of(context) == TextDirection.rtl;
      return Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            final currentEnrollments = ref.read(adminEnrollmentsProvider).asData?.value ?? const [];
            final isAlreadyEnrolled = currentEnrollments.any(
              (e) => e.studentId == student.id && e.groupId == selectedGroupId,
            );
            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: DarAlFajrTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.group_add_rounded, color: DarAlFajrTheme.primary, size: 22),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                trByLang(langCode, ar: 'تسجيل في حلقة', he: 'רישום לקבוצה', en: 'Enroll in Group'),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetCtx).pop(),
                            icon: const Icon(Icons.close_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFE6E8EA),
                              foregroundColor: const Color(0xFF3D4947),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: DarAlFajrTheme.primary.withValues(alpha: 0.15),
                              child: Text(
                                student.initial,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: DarAlFajrTheme.primary),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('${student.code} • ${student.parentName}', style: const TextStyle(color: Color(0xFF6D7A77), fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        trByLang(langCode, ar: 'المسار التعليمي المستهدف', he: 'מסלול חינוכי', en: 'Target Educational Track'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<CenterTrack>(
                        initialValue: selectedTrack,
                        isExpanded: true,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: CenterTrack.values
                            .map((t) => DropdownMenuItem(value: t, child: Text(t.localizedName(langCode))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setSheetState(() => selectedTrack = val);
                        },
                      ),
                      const SizedBox(height: 14),
                      Text(
                        trByLang(langCode, ar: 'الحلقة التعليمية', he: 'קבוצת לימוד', en: 'Study Group'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedGroupId.isEmpty ? null : selectedGroupId,
                        isExpanded: true,
                        hint: Text(trByLang(langCode, ar: 'اختر الحلقة', he: 'בחר קבוצה', en: 'Select group')),
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: firestoreGroups.isNotEmpty
                            ? firestoreGroups
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g.id,
                                    child: Text('${g.name} (${g.formatScheduleSummary(langCode)})'),
                                  ),
                                )
                                .toList()
                            : (isDemoMode
                                ? const [
                                    DropdownMenuItem(
                                      value: 'grp-tajweed-1',
                                      child: Text('حلقة الإتقان والتجويد (الأحد والثلاثاء 16:30)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'grp-hifz-1',
                                      child: Text('حلقة الحفظ المكثف (السبت والاثنين 17:00)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'grp-nouraniah-1',
                                      child: Text('حلقة البراعم النورانية (الخميس 15:30)'),
                                    ),
                                  ]
                                : const []),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() {
                              selectedGroupId = val;
                              final found = firestoreGroups.where((g) => g.id == val).firstOrNull;
                              if (found != null) selectedGroupName = found.name;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          trByLang(langCode, ar: 'تخصيص موعد تسميع فردي (1-on-1)', he: 'הקצאת תור אישי', en: 'Assign 1-on-1 Recitation Slot'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Text(
                          trByLang(langCode, ar: 'تحديد وقت دقيق لوصول الطالب للتسميع الفردي', he: 'שעת הגעה מדויקת', en: 'Precise individual arrival slot'),
                          style: const TextStyle(color: Color(0xFF6D7A77), fontSize: 11),
                        ),
                        value: hasOneOnOne,
                        activeColor: DarAlFajrTheme.primary,
                        onChanged: (val) => setSheetState(() => hasOneOnOne = val ?? false),
                      ),
                      if (hasOneOnOne)
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: oneOnOneDay,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: trByLang(langCode, ar: 'اليوم', he: 'יום', en: 'Day'),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                items: adminWeekDaysAr.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                                onChanged: (d) {
                                  if (d != null) setSheetState(() => oneOnOneDay = d);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: oneOnOneTime,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: trByLang(langCode, ar: 'وقت الوصول', he: 'שעה', en: 'Time'),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                items: const ['16:00', '16:30', '17:00', '17:15', '17:45', '18:15', '18:45']
                                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                    .toList(),
                                onChanged: (t) {
                                  if (t != null) setSheetState(() => oneOnOneTime = t);
                                },
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      if (isAlreadyEnrolled) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDAD6).withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.block_rounded, color: Theme.of(context).colorScheme.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  trByLang(
                                    langCode,
                                    ar: 'الطالب مسجل بالفعل في هذه الحلقة',
                                    he: 'התלמיד כבר רשום לקבוצה זו',
                                    en: 'Student is already enrolled in this group',
                                  ),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ElevatedButton.icon(
                        onPressed: (selectedGroupId.isEmpty || isAlreadyEnrolled)
                            ? null
                            : () async {
                                Navigator.of(sheetCtx).pop();

                                final matchedGroup = firestoreGroups.where((g) => g.id == selectedGroupId).firstOrNull;
                                final arrivalTime = matchedGroup != null
                                    ? matchedGroup.formatScheduleSummary(langCode)
                                    : (isDemoMode ? 'الأحد والثلاثاء والخميس 16:30' : '');

                                try {
                                  final repo = ref.read(adminRepositoryProvider);
                                  await repo.assignStudentToGroup(
                                    studentId: student.id,
                                    studentName: student.fullName,
                                    groupId: selectedGroupId,
                                    groupName: selectedGroupName,
                                    track: selectedTrack,
                                    groupArrivalTime: arrivalTime,
                                    oneOnOneSlotTime: hasOneOnOne ? '$oneOnOneDay $oneOnOneTime (فردي)' : null,
                                  );
                                  messenger?.showSnackBar(
                                    SnackBar(
                                      content: Text(trByLang(langCode, ar: 'تم تثبيت التسجيل بنجاح!', he: 'הרישום נשמר בהצלחה!', en: 'Enrollment confirmed!')),
                                      backgroundColor: DarAlFajrTheme.primary,
                                    ),
                                  );
                                } on DuplicateEnrollmentException {
                                  messenger?.showSnackBar(
                                    SnackBar(
                                      content: Text(trByLang(langCode, ar: 'الطالب مسجل بالفعل في هذه الحلقة', he: 'התלמיד כבר רשום לקבוצה זו', en: 'Student is already enrolled in this group')),
                                      backgroundColor: Colors.red.shade700,
                                    ),
                                  );
                                } catch (_) {}
                              },
                        icon: const Icon(Icons.check_circle_rounded),
                        label: Text(trByLang(langCode, ar: 'حفظ وتثبيت التسجيل', he: 'שמור רישום', en: 'Confirm Enrollment')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DarAlFajrTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
