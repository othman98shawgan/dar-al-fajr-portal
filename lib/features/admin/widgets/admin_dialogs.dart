import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../../auth/models/app_user.dart';
import '../../hifz/models/teacher_models.dart';
import '../../hifz/providers/teacher_providers.dart';
import '../models/admin_models.dart';
import '../providers/admin_providers.dart';
import 'admin_shell_models.dart';

Future<void> showAdminGradingSettingsDialog(
  BuildContext context,
  WidgetRef ref,
  String langCode,
) async {
  final currentConfig = ref.read(gradingPenaltyConfigProvider).asData?.value ??
      const GradingPenaltyConfig();
  final lafziCtrl = TextEditingController(text: '${currentConfig.lafziPenalty}');
  final fathCtrl = TextEditingController(text: '${currentConfig.fathPenalty}');
  final tataaCtrl = TextEditingController(text: '${currentConfig.tataaPenalty}');
  final pageThresholdCtrl =
      TextEditingController(text: '${currentConfig.pagePassingThreshold}');
  final juzThresholdCtrl =
      TextEditingController(text: '${currentConfig.juzExamPassingThreshold}');
  final priorJuzCtrl = TextEditingController(text: '30, 29');

  await showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      return AlertDialog(
        title: Text(
          trByLang(
            langCode,
            ar: 'إعدادات التقييم وحدود النجاح والرصيد السابق',
            he: 'הגדרות ציונים, סף מעבר ויתרה קודמת',
            en: 'Grading Penalties, Passing Thresholds & Prior Balance',
          ),
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: lafziCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: trByLang(
                      langCode,
                      ar: 'خصم الخطأ اللفظي (الافتراضي: 3 درجات)',
                      he: 'ניכוי טעות הגייה (ברירת מחדל: 3)',
                      en: 'Verbal Mistake Deduction (Default: 3)',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: fathCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: trByLang(
                      langCode,
                      ar: 'خصم الفتح / التوقف (الافتراضي: 3 درجات)',
                      he: 'ניכוי פתיחה / עצירה (ברירת מחדל: 3)',
                      en: 'Prompt / Fath Deduction (Default: 3)',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: tataaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: trByLang(
                      langCode,
                      ar: 'خصم التعتعة / الاستدراك (الافتراضي: 0)',
                      he: 'ניכוי תיקון עצמי (ברירת מחדל: 0)',
                      en: 'Hesitation / Self-Correction Deduction (Default: 0)',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: pageThresholdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: trByLang(
                      langCode,
                      ar: 'الحد الأدنى لاجتياز الصفحة / السورة (الافتراضي: 94)',
                      he: 'ציון מעבר מינימלי לעמוד / סורה (ברירת מחדל: 94)',
                      en: 'Page / Surah Minimum Passing Score (Default: 94)',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: juzThresholdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: trByLang(
                      langCode,
                      ar: 'الحد الأدنى لاجتياز اختبار الجزء الكامل (الافتراضي: 79)',
                      he: 'ציון מעבר מינימלי למבחן ג׳וז (ברירת מחדל: 79)',
                      en: 'Whole Juz Exam Minimum Passing Score (Default: 79)',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: priorJuzCtrl,
                  decoration: InputDecoration(
                    labelText: trByLang(
                      langCode,
                      ar: 'الرصيد السابق للأجزاء المحفوظة (مثال: 30, 29)',
                      he: 'יתרה קודמת של ג׳וזים (למשל: 30, 29)',
                      en: 'Student Prior Completed Juz Balance (e.g. 30, 29)',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(trByLang(langCode, ar: 'إلغاء', he: 'ביטול', en: 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = GradingPenaltyConfig(
                lafziPenalty: int.tryParse(lafziCtrl.text.trim()) ?? 3,
                fathPenalty: int.tryParse(fathCtrl.text.trim()) ?? 3,
                tataaPenalty: int.tryParse(tataaCtrl.text.trim()) ?? 0,
                pagePassingThreshold:
                    int.tryParse(pageThresholdCtrl.text.trim()) ?? 94,
                juzExamPassingThreshold:
                    int.tryParse(juzThresholdCtrl.text.trim()) ?? 79,
              );
              await ref
                  .read(teacherControllerProvider.notifier)
                  .saveGradingPenaltyConfig(updated);
              if (dialogCtx.mounted) {
                Navigator.of(dialogCtx).pop();
              }
            },
            child: Text(trByLang(langCode, ar: 'حفظ الإعدادات', he: 'שמור', en: 'Save')),
          ),
        ],
      );
    },
  );
}

Future<void> _pickAdminTime(
  BuildContext context,
  TextEditingController controller,
) async {
  final parts = controller.text.trim().split(':');
  final initialHour = int.tryParse(parts.firstOrNull ?? '') ?? 17;
  final initialMinute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(
      hour: initialHour.clamp(0, 23),
      minute: initialMinute.clamp(0, 59),
    ),
  );
  if (picked != null) {
    final hh = picked.hour.toString().padLeft(2, '0');
    final mm = picked.minute.toString().padLeft(2, '0');
    controller.text = '$hh:$mm';
  }
}

Future<void> _showAdminFormSheet({
  required BuildContext context,
  required Widget Function(BuildContext sheetContext, StateSetter setSheetState) builder,
}) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              elevation: 12,
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                ),
                child: StatefulBuilder(
                  builder: (ctx, setSheetState) => builder(sheetContext, setSheetState),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildSheetHeader(BuildContext sheetContext, String title) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Center(
        child: Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DarAlFajrTheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(sheetContext).pop(),
            icon: const Icon(Icons.close_rounded),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFE6E8EA),
              foregroundColor: const Color(0xFF3D4947),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
    ],
  );
}

void showAdminAddStudentOrUserDialog(
  BuildContext context,
  WidgetRef ref,
  String langCode, {
  UserRole initialRole = UserRole.student,
  StudentProfile? existingStudent,
}) {
  final isEditingStudent = existingStudent != null;
  final parents = ref.read(adminParentsProvider).value ?? const <AppUser>[];
  final nameController = TextEditingController(text: existingStudent?.fullName ?? '');
  final parentNameController = TextEditingController(text: existingStudent?.parentName ?? '');
  final emailController = TextEditingController(text: existingStudent?.email ?? '');
  final tempPasswordController = TextEditingController(text: 'Fajr@2026');
  final phoneController = TextEditingController(text: existingStudent?.phoneNumber ?? '');
  UserRole selectedRole = isEditingStudent
      ? UserRole.student
      : (initialRole == UserRole.admin ? UserRole.teacher : initialRole);
  const manualParentKey = '__manual__';
  String selectedParentId;
  if (isEditingStudent) {
    final hasMatchingParent = parents.any((p) => p.uid == existingStudent.parentId);
    selectedParentId = hasMatchingParent ? existingStudent.parentId : manualParentKey;
  } else {
    selectedParentId = parents.isNotEmpty ? parents.first.uid : manualParentKey;
  }
  bool isSaving = false;
  String? errorMessage;
  String? successMessage;
  final messenger = ScaffoldMessenger.maybeOf(context);

  _showAdminFormSheet(
    context: context,
    builder: (sheetContext, setSheetState) {
      Future<void> submit({required bool keepOpen}) async {
        final fullName = nameController.text.trim();
        final email = emailController.text.trim();
        final tempPass = tempPasswordController.text.trim();
        final phone = phoneController.text.trim();

        if (fullName.isEmpty) {
          setSheetState(() {
            errorMessage = trByLang(
              langCode,
              ar: 'يرجى إدخال الاسم الكامل.',
              he: 'נא להזין שם מלא.',
              en: 'Please enter the full name.',
            );
          });
          return;
        }

        if (!isEditingStudent &&
            selectedRole != UserRole.student &&
            (email.isEmpty || !email.contains('@'))) {
          setSheetState(() {
            errorMessage = trByLang(
              langCode,
              ar: 'البريد الإلكتروني مطلوب لحسابات المعلمين وأولياء الأمور.',
              he: 'נדרש אימייל תקין לחשבונות מורים והורים.',
              en: 'A valid email is required for Teacher and Parent accounts.',
            );
          });
          return;
        }

        if (!isEditingStudent &&
            (selectedRole != UserRole.student || email.isNotEmpty) &&
            tempPass.length < 6) {
          setSheetState(() {
            errorMessage = trByLang(
              langCode,
              ar: 'كلمة المرور المؤقتة يجب أن تكون 6 أحرف على الأقل.',
              he: 'הסיסמה הזמנית חייבת להכיל לפחות 6 תווים.',
              en: 'Temporary password must be at least 6 characters.',
            );
          });
          return;
        }

        setSheetState(() {
          isSaving = true;
          errorMessage = null;
          successMessage = null;
        });

        if (isEditingStudent) {
          final linkedParent = parents.where((p) => p.uid == selectedParentId).firstOrNull;
          final resolvedParentId = linkedParent?.uid ?? existingStudent.parentId;
          final resolvedParentName = linkedParent?.fullName ??
              (parentNameController.text.trim().isEmpty
                  ? existingStudent.parentName
                  : parentNameController.text.trim());

          await ref.read(adminControllerProvider.notifier).updateStudent(
                studentId: existingStudent.id,
                fullName: fullName,
                parentId: resolvedParentId,
                parentName: resolvedParentName,
                email: email,
                phoneNumber: phone,
              );
        } else if (selectedRole == UserRole.student) {
          final linkedParent = parents.where((p) => p.uid == selectedParentId).firstOrNull;
          final resolvedParentId = linkedParent?.uid ?? 'parent-default';
          final resolvedParentName = linkedParent?.fullName ??
              (parentNameController.text.trim().isEmpty
                  ? 'ولي الأمر'
                  : parentNameController.text.trim());

          await ref.read(adminControllerProvider.notifier).createStudent(
                fullName: fullName,
                parentId: resolvedParentId,
                parentName: resolvedParentName,
                email: email,
                temporaryPassword: tempPass,
                phoneNumber: phone.isNotEmpty ? phone : linkedParent?.phoneNumber,
              );
        } else {
          await ref.read(adminControllerProvider.notifier).createTeacherOrParent(
                email: email,
                temporaryPassword: tempPass,
                fullName: fullName,
                role: selectedRole,
                phoneNumber: phone,
                preferredLanguage: langCode,
              );
        }

        if (!sheetContext.mounted) return;

        final ctrlState = ref.read(adminControllerProvider);
        if (ctrlState.hasError) {
          setSheetState(() {
            isSaving = false;
            errorMessage = ctrlState.error.toString();
          });
          return;
        }

        if (keepOpen && !isEditingStudent) {
          nameController.clear();
          emailController.clear();
          phoneController.clear();
          parentNameController.clear();
          setSheetState(() {
            isSaving = false;
            successMessage = trByLang(
              langCode,
              ar: 'تمت إضافة "$fullName" بنجاح! يمكنك إضافة التالي الآن.',
              he: '"$fullName" נוסף בהצלחה! ניתן להוסיף את הבא.',
              en: 'Added "$fullName"! Ready for the next entry.',
            );
          });
          return;
        }

        Navigator.of(sheetContext).pop();
        messenger?.showSnackBar(
          SnackBar(
            content: Text(
              isEditingStudent
                  ? trByLang(langCode, ar: 'تم تحديث بيانات الطالب بنجاح!', he: 'פרטי התלמיד עודכנו בהצלחה!', en: 'Student updated successfully!')
                  : trByLang(langCode, ar: 'تمت الإضافة بنجاح!', he: 'נוסף בהצלחה!', en: 'Created successfully!'),
            ),
            backgroundColor: DarAlFajrTheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSheetHeader(
              sheetContext,
              isEditingStudent
                  ? trByLang(
                      langCode,
                      ar: 'تعديل بيانات الطالب',
                      he: 'עריכת פרטי תלמיד',
                      en: 'Edit Student Profile',
                    )
                  : trByLang(
                      langCode,
                      ar: 'إنشاء طالب أو مستخدم',
                      he: 'יצירת תלמיד או משתמש',
                      en: 'Create Student or User',
                    ),
            ),
            if (!isEditingStudent)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    avatar: const Icon(Icons.face_rounded, size: 16),
                    label: Text(trByLang(langCode, ar: 'طالب', he: 'תלמיד', en: 'Student')),
                    selected: selectedRole == UserRole.student,
                    onSelected: isSaving
                        ? null
                        : (_) => setSheetState(() {
                              selectedRole = UserRole.student;
                              errorMessage = null;
                            }),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.family_restroom_rounded, size: 16),
                    label: Text(trByLang(langCode, ar: 'ولي أمر', he: 'הורה', en: 'Parent')),
                    selected: selectedRole == UserRole.parent,
                    onSelected: isSaving
                        ? null
                        : (_) => setSheetState(() {
                              selectedRole = UserRole.parent;
                              errorMessage = null;
                            }),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.school_rounded, size: 16),
                    label: Text(trByLang(langCode, ar: 'معلم / شيخ', he: 'מורה', en: 'Teacher')),
                    selected: selectedRole == UserRole.teacher,
                    onSelected: isSaving
                        ? null
                        : (_) => setSheetState(() {
                              selectedRole = UserRole.teacher;
                              errorMessage = null;
                            }),
                  ),
                ],
              ),
            if (errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                ),
              ),
            ],
            if (successMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  successMessage!,
                  style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: trByLang(langCode, ar: 'الاسم الكامل *', he: 'שם מלא *', en: 'Full Name *'),
              ),
            ),
            if (selectedRole == UserRole.student) ...[
              const SizedBox(height: 12),
              if (parents.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: selectedParentId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: trByLang(
                      langCode,
                      ar: 'ربط بحساب ولي الأمر',
                      he: 'שיוך לחשבון הורה',
                      en: 'Link to Parent Account',
                    ),
                  ),
                  items: [
                    ...parents.map(
                      (p) => DropdownMenuItem<String>(
                        value: p.uid,
                        child: Text('${p.fullName} (${p.email})', overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: manualParentKey,
                      child: Text(
                        trByLang(
                          langCode,
                          ar: 'إدخال اسم ولي الأمر يدوياً',
                          he: 'הזנת שם הורה ידנית',
                          en: 'Enter parent name manually',
                        ),
                      ),
                    ),
                  ],
                  onChanged: isSaving
                      ? null
                      : (val) {
                          if (val != null) {
                            setSheetState(() => selectedParentId = val);
                          }
                        },
                ),
              if (parents.isEmpty || selectedParentId == manualParentKey) ...[
                if (parents.isNotEmpty) const SizedBox(height: 12),
                TextField(
                  controller: parentNameController,
                  decoration: InputDecoration(
                    labelText: trByLang(langCode, ar: 'اسم ولي الأمر', he: 'שם ההורה', en: 'Parent Name'),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: selectedRole == UserRole.student
                    ? trByLang(langCode, ar: 'البريد الإلكتروني (اختياري للطالب)', he: 'דוא״ל (אופציונלי לתלמיד)', en: 'Email (Optional for Student)')
                    : trByLang(langCode, ar: 'البريد الإلكتروني *', he: 'דוא״ל *', en: 'Email Address *'),
              ),
            ),
            if (!isEditingStudent) ...[
              const SizedBox(height: 12),
              TextField(
                controller: tempPasswordController,
                decoration: InputDecoration(
                  labelText: trByLang(
                    langCode,
                    ar: 'كلمة المرور المؤقتة (للدخول الأول)',
                    he: 'סיסמה זמנית',
                    en: 'Temporary Password (First-Login)',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: trByLang(langCode, ar: 'رقم الهاتف', he: 'מספר טלפון', en: 'Phone Number'),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (!isEditingStudent) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isSaving ? null : () => submit(keepOpen: true),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        trByLang(langCode, ar: 'إنشاء وإضافة آخر', he: 'צור והוסף עוד', en: 'Create & Add Another'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSaving ? null : () => submit(keepOpen: false),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            isEditingStudent
                                ? trByLang(langCode, ar: 'حفظ التعديلات', he: 'שמור שינויים', en: 'Save Changes')
                                : trByLang(langCode, ar: 'إنشاء', he: 'יצירה', en: 'Create'),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

void showAdminCreateGroupDialog(
  BuildContext context,
  WidgetRef ref,
  String langCode, {
  required bool isDemoFallback,
}) {
  showAdminGroupFormDialog(
    context,
    ref,
    langCode,
    isDemoFallback: isDemoFallback,
  );
}

void showAdminEditGroupDialog(
  BuildContext context,
  WidgetRef ref,
  String langCode, {
  required StudyGroup group,
  required bool isDemoFallback,
}) {
  showAdminGroupFormDialog(
    context,
    ref,
    langCode,
    existingGroup: group,
    isDemoFallback: isDemoFallback,
  );
}

void showAdminGroupFormDialog(
  BuildContext context,
  WidgetRef ref,
  String langCode, {
  StudyGroup? existingGroup,
  required bool isDemoFallback,
}) {
  final isEditing = existingGroup != null;
  final nameController = TextEditingController(text: existingGroup?.name ?? '');
  CenterTrack selectedTrack = existingGroup?.track ?? CenterTrack.hifz;

  final existingSlots = existingGroup?.effectiveScheduleSlots ?? const <GroupScheduleSlot>[];
  final defaultStart = existingSlots.firstOrNull?.startTime.isNotEmpty == true
      ? existingSlots.first.startTime
      : (existingGroup?.startTime.isNotEmpty == true ? existingGroup!.startTime : '17:00');
  final defaultEnd = existingSlots.firstOrNull?.endTime.isNotEmpty == true
      ? existingSlots.first.endTime
      : (existingGroup?.endTime.isNotEmpty == true ? existingGroup!.endTime : '18:30');

  final startTimeController = TextEditingController(text: defaultStart);
  final endTimeController = TextEditingController(text: defaultEnd);
  final capacityController = TextEditingController(text: '${existingGroup?.capacity ?? 15}');

  final selectedDays = <String>{};
  final perDayStartCtrls = <String, TextEditingController>{};
  final perDayEndCtrls = <String, TextEditingController>{};

  for (final slot in existingSlots) {
    final matchedArDay = adminWeekDaysAr.firstWhere(
      (d) => ScheduleDayHelper.parseWeekday(d) == slot.weekday,
      orElse: () => slot.day,
    );
    selectedDays.add(matchedArDay);
    perDayStartCtrls[matchedArDay] = TextEditingController(
      text: slot.startTime.isNotEmpty ? slot.startTime : defaultStart,
    );
    perDayEndCtrls[matchedArDay] = TextEditingController(
      text: slot.endTime.isNotEmpty ? slot.endTime : defaultEnd,
    );
  }
  if (selectedDays.isEmpty) {
    selectedDays.addAll({'السبت', 'الاثنين'});
  }
  for (final day in adminWeekDaysAr) {
    perDayStartCtrls.putIfAbsent(day, () => TextEditingController(text: defaultStart));
    perDayEndCtrls.putIfAbsent(day, () => TextEditingController(text: defaultEnd));
  }

  bool customPerDayTimes = existingSlots.length > 1 &&
      existingSlots.any(
        (s) => s.startTime != existingSlots.first.startTime || s.endTime != existingSlots.first.endTime,
      );

  String? selectedTeacherId =
      existingGroup?.teacherId.isNotEmpty == true ? existingGroup!.teacherId : null;
  final messenger = ScaffoldMessenger.maybeOf(context);
  bool isSaving = false;
  String? errorMessage;
  String? successMessage;

  _showAdminFormSheet(
    context: context,
    builder: (dialogContext, setDialogState) {
      return Consumer(
        builder: (consumerContext, cRef, _) {
          final directTeachers = cRef.watch(adminTeachersProvider).value ?? const <AppUser>[];
          final allUsers = cRef.watch(adminAllUsersProvider).value ?? const <AppUser>[];
          final activeTeachers = directTeachers.isNotEmpty
              ? directTeachers
              : allUsers.where((u) => u.role == UserRole.teacher).toList();
          final allEnrollments = cRef.watch(adminEnrollmentsProvider).value ?? const <Enrollment>[];
          final groupRosterCount = isEditing
              ? allEnrollments.where((e) => e.groupId == existingGroup.id).length
              : 0;

          if (activeTeachers.isNotEmpty &&
              (selectedTeacherId == null ||
                  !activeTeachers.any((t) => t.uid == selectedTeacherId))) {
            selectedTeacherId = activeTeachers.first.uid;
          }

          final orderedSelectedDays = adminWeekDaysAr.where(selectedDays.contains).toList();

          Future<void> submitGroup({required bool keepOpen}) async {
            final groupName = nameController.text.trim();
            if (groupName.isEmpty) {
              setDialogState(() {
                errorMessage = trByLang(
                  langCode,
                  ar: 'يرجى إدخال اسم الحلقة.',
                  he: 'נא להזין שם קבוצה.',
                  en: 'Please enter the group name.',
                );
              });
              return;
            }

            final matchedTeacher =
                activeTeachers.where((t) => t.uid == selectedTeacherId).firstOrNull;
            if (matchedTeacher == null && !isDemoFallback) {
              setDialogState(() {
                errorMessage = trByLang(
                  langCode,
                  ar: 'يرجى اختيار معلم نشط من قائمة المستخدمين أولاً.',
                  he: 'יש לבחור מורה פעיל מרשימת המשתמשים.',
                  en: 'Please select an active teacher from the users list.',
                );
              });
              return;
            }

            setDialogState(() {
              isSaving = true;
              errorMessage = null;
              successMessage = null;
            });

            final parsedCapacity =
                (int.tryParse(capacityController.text.trim()) ?? 15)
                    .clamp(1, 200);

            final slots = orderedSelectedDays.map((day) {
              final s = customPerDayTimes
                  ? perDayStartCtrls[day]!.text.trim()
                  : startTimeController.text.trim();
              final e = customPerDayTimes
                  ? perDayEndCtrls[day]!.text.trim()
                  : endTimeController.text.trim();
              return GroupScheduleSlot(
                day: day,
                startTime: s.isNotEmpty ? s : startTimeController.text.trim(),
                endTime: e.isNotEmpty ? e : endTimeController.text.trim(),
              );
            }).toList();

            final resolvedStart = slots.firstOrNull?.startTime ?? startTimeController.text.trim();
            final resolvedEnd = slots.firstOrNull?.endTime ?? endTimeController.text.trim();
            final resolvedTeacherId = matchedTeacher?.uid ??
                (existingGroup?.teacherId.isNotEmpty == true
                    ? existingGroup!.teacherId
                    : (isDemoFallback ? 'teacher-1' : ''));
            final resolvedTeacherName = matchedTeacher?.fullName ??
                (existingGroup?.teacherName ?? '');

            if (isEditing) {
              await ref.read(adminControllerProvider.notifier).updateGroup(
                    groupId: existingGroup.id,
                    name: groupName,
                    track: selectedTrack,
                    teacherId: resolvedTeacherId,
                    teacherName: resolvedTeacherName,
                    scheduleDays: orderedSelectedDays,
                    startTime: resolvedStart,
                    endTime: resolvedEnd,
                    scheduleSlots: slots,
                    capacity: parsedCapacity,
                  );
            } else {
              await ref.read(adminControllerProvider.notifier).createGroup(
                    name: groupName,
                    track: selectedTrack,
                    teacherId: resolvedTeacherId,
                    teacherName: resolvedTeacherName,
                    scheduleDays: orderedSelectedDays,
                    startTime: resolvedStart,
                    endTime: resolvedEnd,
                    scheduleSlots: slots,
                    capacity: parsedCapacity,
                  );
            }

            if (!dialogContext.mounted) return;
            final ctrlState = ref.read(adminControllerProvider);
            if (ctrlState.hasError) {
              setDialogState(() {
                isSaving = false;
                errorMessage = ctrlState.error.toString();
              });
              return;
            }

            if (keepOpen && !isEditing) {
              nameController.clear();
              setDialogState(() {
                isSaving = false;
                successMessage = trByLang(
                  langCode,
                  ar: 'تم إنشاء "$groupName"! يمكنك إنشاء الحلقة التالية الآن.',
                  he: '"$groupName" נוצרה! ניתן ליצור את הקבוצה הבאה.',
                  en: 'Created "$groupName"! Ready for the next group.',
                );
              });
              return;
            }

            Navigator.of(dialogContext).pop();
            messenger?.showSnackBar(
              SnackBar(
                content: Text(
                  isEditing
                      ? trByLang(
                          langCode,
                          ar: 'تم تحديث بيانات وجدول الحلقة بنجاح!',
                          he: 'הקבוצה עודכנה בהצלחה!',
                          en: 'Study group updated successfully!',
                        )
                      : trByLang(
                          langCode,
                          ar: 'تم إنشاء الحلقة بنجاح!',
                          he: 'הקבוצה נוצרה בהצלחה!',
                          en: 'Study group created successfully!',
                        ),
                ),
                backgroundColor: DarAlFajrTheme.primary,
              ),
            );
          }

      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSheetHeader(
              dialogContext,
              isEditing
                  ? trByLang(
                      langCode,
                      ar: 'تعديل بيانات وجدول الحلقة',
                      he: 'עריכת פרטי וזמני קבוצה',
                      en: 'Edit Study Group & Schedule',
                    )
                  : trByLang(
                      langCode,
                      ar: 'إنشاء حلقة جديدة',
                      he: 'יצירת קבוצה חדשה',
                      en: 'Create New Study Group',
                    ),
            ),
                    if (errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                        ),
                      ),
                    ],
                    if (successMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          successMessage!,
                          style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                        ),
                      ),
                    ],
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: trByLang(
                          langCode,
                          ar: 'اسم الحلقة *',
                          he: 'שם קבוצה *',
                          en: 'Group Name *',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<CenterTrack>(
                      initialValue: selectedTrack,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: trByLang(
                          langCode,
                          ar: 'المسار التعليمي',
                          he: 'מסלול לימוד',
                          en: 'Educational Track',
                        ),
                      ),
                      items: CenterTrack.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.localizedName(langCode)),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedTrack = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    if (activeTeachers.isNotEmpty)
                      DropdownButtonFormField<String>(
                        initialValue: selectedTeacherId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: trByLang(
                            langCode,
                            ar: 'المعلم المشرف *',
                            he: 'מורה אחראי *',
                            en: 'Assigned Teacher *',
                          ),
                        ),
                        items: activeTeachers
                            .map(
                              (t) => DropdownMenuItem<String>(
                                value: t.uid,
                                child: Text(
                                  t.email.isNotEmpty ? '${t.fullName} (${t.email})' : t.fullName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: isSaving
                            ? null
                            : (val) {
                                setDialogState(() => selectedTeacherId = val);
                              },
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 18, color: Colors.amber.shade900),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                trByLang(
                                  langCode,
                                  ar: 'لا يوجد معلمون نشطون بعد. يرجى إنشاء حساب معلم من قائمة المستخدمين أولاً.',
                                  he: 'אין מורים פעילים עדיין. יש ליצור חשבון מורה תחילה.',
                                  en: 'No active teacher accounts found. Please create a teacher user first.',
                                ),
                                style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      trByLang(
                        langCode,
                        ar: 'أيام الحلقة:',
                        he: 'ימי הקבוצה:',
                        en: 'Schedule Days:',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3D4947),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: adminWeekDaysAr.map((day) {
                        final isSelected = selectedDays.contains(day);
                        final wd = ScheduleDayHelper.parseWeekday(day);
                        final label = wd != null ? ScheduleDayHelper.localizedDayName(wd, langCode) : day;
                        return FilterChip(
                          label: Text(label, style: const TextStyle(fontSize: 11.5)),
                          selected: isSelected,
                          onSelected: (checked) {
                            setDialogState(() {
                              if (checked) {
                                selectedDays.add(day);
                                if (perDayStartCtrls[day]!.text.trim().isEmpty) {
                                  perDayStartCtrls[day]!.text = startTimeController.text.trim();
                                }
                                if (perDayEndCtrls[day]!.text.trim().isEmpty) {
                                  perDayEndCtrls[day]!.text = endTimeController.text.trim();
                                }
                              } else if (selectedDays.length > 1) {
                                selectedDays.remove(day);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: customPerDayTimes,
                      title: Text(
                        trByLang(
                          langCode,
                          ar: 'تخصيص وقت مختلف لكل يوم',
                          he: 'שעה שונה לכל יום',
                          en: 'Custom start/end time per day',
                        ),
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          customPerDayTimes = val;
                          if (val) {
                            for (final d in orderedSelectedDays) {
                              if (perDayStartCtrls[d]!.text.trim().isEmpty) {
                                perDayStartCtrls[d]!.text = startTimeController.text.trim();
                              }
                              if (perDayEndCtrls[d]!.text.trim().isEmpty) {
                                perDayEndCtrls[d]!.text = endTimeController.text.trim();
                              }
                            }
                          }
                        });
                      },
                    ),
                    if (!customPerDayTimes)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: startTimeController,
                              decoration: InputDecoration(
                                labelText: trByLang(
                                  langCode,
                                  ar: 'وقت البدء',
                                  he: 'שעת התחלה',
                                  en: 'Start Time',
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.access_time_rounded, size: 18),
                                  onPressed: () => _pickAdminTime(dialogContext, startTimeController),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: endTimeController,
                              decoration: InputDecoration(
                                labelText: trByLang(
                                  langCode,
                                  ar: 'وقت الانتهاء',
                                  he: 'שעת סיום',
                                  en: 'End Time',
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.access_time_rounded, size: 18),
                                  onPressed: () => _pickAdminTime(dialogContext, endTimeController),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 96,
                            child: TextField(
                              controller: capacityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: trByLang(
                                  langCode,
                                  ar: 'السعة',
                                  he: 'קיבולת',
                                  en: 'Capacity',
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      ...orderedSelectedDays.map((day) {
                        final wd = ScheduleDayHelper.parseWeekday(day);
                        final dayLabel = wd != null ? ScheduleDayHelper.localizedDayName(wd, langCode) : day;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 84,
                                child: Text(
                                  dayLabel,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: perDayStartCtrls[day],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: trByLang(langCode, ar: 'البدء', he: 'התחלה', en: 'Start'),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.access_time_rounded, size: 16),
                                      onPressed: () => _pickAdminTime(dialogContext, perDayStartCtrls[day]!),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: perDayEndCtrls[day],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: trByLang(langCode, ar: 'الانتهاء', he: 'סיום', en: 'End'),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.access_time_rounded, size: 16),
                                      onPressed: () => _pickAdminTime(dialogContext, perDayEndCtrls[day]!),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                      TextField(
                        controller: capacityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: trByLang(
                            langCode,
                            ar: 'السعة القصوى للحلقة',
                            he: 'קיבולת קבוצה',
                            en: 'Group Capacity',
                          ),
                        ),
                      ),
                    ],
                    if (isEditing) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: isSaving
                            ? null
                            : () => showAdminGroupRosterModal(
                                  dialogContext,
                                  existingGroup,
                                  langCode,
                                ),
                        icon: const Icon(Icons.groups_rounded, size: 18),
                        label: Text(
                          trByLang(
                            langCode,
                            ar: 'إدارة طلاب الحلقة ($groupRosterCount / ${existingGroup.capacity})',
                            he: 'ניהול תלמידי הקבוצה ($groupRosterCount / ${existingGroup.capacity})',
                            en: 'Manage Student Roster ($groupRosterCount / ${existingGroup.capacity})',
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: DarAlFajrTheme.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (!isEditing) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSaving ? null : () => submitGroup(keepOpen: true),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                trByLang(langCode, ar: 'حفظ وإضافة أخرى', he: 'שמור והוסף עוד', en: 'Save & Add Another'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSaving ? null : () => submitGroup(keepOpen: false),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    trByLang(langCode, ar: 'حفظ الحلقة', he: 'שמור', en: 'Save Group'),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
        },
      );
    },
  );
}

void showAdminGroupRosterModal(
  BuildContext context,
  StudyGroup group,
  String langCode,
) {
  String? selectedStudentId;
  bool isAdding = false;
  String? deletingEnrollmentId;
  String? errorMessage;

  _showAdminFormSheet(
    context: context,
    builder: (sheetContext, setSheetState) {
      return Consumer(
        builder: (consumerContext, ref, _) {
          final allStudents = ref.watch(adminStudentsProvider).value ?? const <StudentProfile>[];
          final allEnrollments = ref.watch(adminEnrollmentsProvider).value ?? const <Enrollment>[];
          final groupEnrollments =
              allEnrollments.where((e) => e.groupId == group.id).toList();
          final enrolledStudentIds = groupEnrollments.map((e) => e.studentId).toSet();
          final availableStudents =
              allStudents.where((s) => !enrolledStudentIds.contains(s.id)).toList();

          if (availableStudents.isEmpty) {
            selectedStudentId = null;
          } else if (selectedStudentId == null ||
              !availableStudents.any((s) => s.id == selectedStudentId)) {
            selectedStudentId = availableStudents.first.id;
          }

          Future<void> addStudent() async {
            final student = availableStudents
                .where((s) => s.id == selectedStudentId)
                .firstOrNull;
            if (student == null) return;

            setSheetState(() {
              isAdding = true;
              errorMessage = null;
            });

            await ref.read(adminControllerProvider.notifier).assignStudentToGroup(
                  studentId: student.id,
                  studentName: student.fullName,
                  groupId: group.id,
                  groupName: group.name,
                  track: group.track,
                );

            if (!sheetContext.mounted) return;
            final ctrlState = ref.read(adminControllerProvider);
            setSheetState(() {
              isAdding = false;
              if (ctrlState.hasError) {
                errorMessage = ctrlState.error.toString();
              }
            });
          }

          Future<void> removeEnrollment(Enrollment enrollment) async {
            final confirmed = await showDialog<bool>(
              context: sheetContext,
              builder: (confirmCtx) => AlertDialog(
                title: Text(
                  trByLang(langCode, ar: 'إزالة الطالب من الحلقة', he: 'הסרת תלמיד מהקבוצה', en: 'Remove Student from Group'),
                ),
                content: Text(
                  trByLang(
                    langCode,
                    ar: 'هل تريد إزالة "${enrollment.studentName}" من "${group.name}"؟',
                    he: 'להסיר את "${enrollment.studentName}" מהקבוצה "${group.name}"?',
                    en: 'Remove "${enrollment.studentName}" from "${group.name}"?',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(confirmCtx).pop(false),
                    child: Text(trByLang(langCode, ar: 'إلغاء', he: 'ביטול', en: 'Cancel')),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                    onPressed: () => Navigator.of(confirmCtx).pop(true),
                    child: Text(trByLang(langCode, ar: 'إزالة', he: 'הסר', en: 'Remove')),
                  ),
                ],
              ),
            );
            if (confirmed != true || !sheetContext.mounted) return;

            setSheetState(() {
              deletingEnrollmentId = enrollment.id;
              errorMessage = null;
            });
            try {
              await ref.read(adminRepositoryProvider).deleteEnrollment(enrollment.id);
            } catch (e) {
              if (sheetContext.mounted) {
                setSheetState(() => errorMessage = e.toString());
              }
            } finally {
              if (sheetContext.mounted) {
                setSheetState(() => deletingEnrollmentId = null);
              }
            }
          }

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.78,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSheetHeader(
                  sheetContext,
                  '${group.name} (${groupEnrollments.length}/${group.capacity})',
                ),
                if (errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                    ),
                  ),
                ],
                // Add Student to Roster Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        trByLang(
                          langCode,
                          ar: 'إضافة طالب إلى الحلقة',
                          he: 'הוספת תלמיד לקבוצה',
                          en: 'Add Student to Group',
                        ),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: DarAlFajrTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (availableStudents.isNotEmpty)
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: selectedStudentId,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: trByLang(langCode, ar: 'اختر الطالب', he: 'בחר תלמיד', en: 'Select Student'),
                                ),
                                items: availableStudents
                                    .map(
                                      (s) => DropdownMenuItem<String>(
                                        value: s.id,
                                        child: Text(s.fullName, overflow: TextOverflow.ellipsis),
                                      ),
                                    )
                                    .toList(),
                                onChanged: isAdding
                                    ? null
                                    : (val) => setSheetState(() => selectedStudentId = val),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: isAdding ? null : addStudent,
                              icon: isAdding
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.person_add_alt_1_rounded, size: 16),
                              label: Text(trByLang(langCode, ar: 'إضافة', he: 'הוסף', en: 'Add')),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          trByLang(
                            langCode,
                            ar: 'جميع الطلاب المسجلين في المركز مضافون بالفعل إلى هذه الحلقة.',
                            he: 'כל התלמידים כבר רשומים לקבוצה זו.',
                            en: 'All students are already enrolled in this group.',
                          ),
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A77)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  trByLang(
                    langCode,
                    ar: 'الطلاب المسجلون حالياً (${groupEnrollments.length})',
                    he: 'תלמידים רשומים (${groupEnrollments.length})',
                    en: 'Enrolled Students (${groupEnrollments.length})',
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D4947),
                  ),
                ),
                const SizedBox(height: 8),
                if (groupEnrollments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        trByLang(
                          langCode,
                          ar: 'لا يوجد طلاب في هذه الحلقة بعد',
                          he: 'אין תלמידים בקבוצה זו עדיין',
                          en: 'No students enrolled in this group yet',
                        ),
                        style: const TextStyle(color: Color(0xFF6D7A77), fontSize: 13),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: groupEnrollments.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final e = groupEnrollments[index];
                        final isDeleting = deletingEnrollmentId == e.id;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: DarAlFajrTheme.primary.withValues(alpha: 0.12),
                            child: Text(
                              e.studentName.isNotEmpty ? e.studentName[0] : '?',
                              style: const TextStyle(
                                color: DarAlFajrTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            e.studentName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: e.oneOnOneSlotTime != null && e.oneOnOneSlotTime!.isNotEmpty
                              ? Text(
                                  e.oneOnOneSlotTime!,
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF6D7A77)),
                                )
                              : null,
                          trailing: isDeleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : IconButton(
                                  icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600, size: 20),
                                  tooltip: trByLang(langCode, ar: 'إزالة من الحلقة', he: 'הסר מהקבוצה', en: 'Remove from group'),
                                  onPressed: () => removeEnrollment(e),
                                ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}
