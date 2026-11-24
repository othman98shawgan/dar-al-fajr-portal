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

void showAdminAddStudentOrUserDialog(
  BuildContext context,
  WidgetRef ref,
  String langCode, {
  UserRole initialRole = UserRole.student,
}) {
  final parents = ref.read(adminParentsProvider).value ?? const <AppUser>[];
  final nameController = TextEditingController();
  final parentNameController = TextEditingController();
  final emailController = TextEditingController();
  final tempPasswordController = TextEditingController(text: 'Fajr@2026');
  final phoneController = TextEditingController();
  UserRole selectedRole = initialRole == UserRole.admin ? UserRole.teacher : initialRole;
  const manualParentKey = '__manual__';
  String selectedParentId = parents.isNotEmpty ? parents.first.uid : manualParentKey;
  bool isSaving = false;
  String? errorMessage;
  String? successMessage;
  final messenger = ScaffoldMessenger.maybeOf(context);

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> submit({required bool keepOpen}) async {
            final fullName = nameController.text.trim();
            final email = emailController.text.trim();
            final tempPass = tempPasswordController.text.trim();
            final phone = phoneController.text.trim();

            if (fullName.isEmpty) {
              setDialogState(() {
                errorMessage = trByLang(
                  langCode,
                  ar: 'يرجى إدخال الاسم الكامل.',
                  he: 'נא להזין שם מלא.',
                  en: 'Please enter the full name.',
                );
              });
              return;
            }

            if (selectedRole != UserRole.student && (email.isEmpty || !email.contains('@'))) {
              setDialogState(() {
                errorMessage = trByLang(
                  langCode,
                  ar: 'البريد الإلكتروني مطلوب لحسابات المعلمين وأولياء الأمور.',
                  he: 'נדרש אימייל תקין לחשבונות מורים והורים.',
                  en: 'A valid email is required for Teacher and Parent accounts.',
                );
              });
              return;
            }

            if ((selectedRole != UserRole.student || email.isNotEmpty) && tempPass.length < 6) {
              setDialogState(() {
                errorMessage = trByLang(
                  langCode,
                  ar: 'كلمة المرور المؤقتة يجب أن تكون 6 أحرف على الأقل.',
                  he: 'הסיסמה הזמנית חייבת להכיל לפחות 6 תווים.',
                  en: 'Temporary password must be at least 6 characters.',
                );
              });
              return;
            }

            setDialogState(() {
              isSaving = true;
              errorMessage = null;
              successMessage = null;
            });

            if (selectedRole == UserRole.student) {
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

            if (!dialogContext.mounted) return;

            final ctrlState = ref.read(adminControllerProvider);
            if (ctrlState.hasError) {
              setDialogState(() {
                isSaving = false;
                errorMessage = ctrlState.error.toString();
              });
              return;
            }

            if (keepOpen) {
              nameController.clear();
              emailController.clear();
              phoneController.clear();
              parentNameController.clear();
              setDialogState(() {
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

            Navigator.of(dialogContext).pop();
            messenger?.showSnackBar(
              SnackBar(
                content: Text(
                  trByLang(langCode, ar: 'تمت الإضافة بنجاح!', he: 'נוסף בהצלחה!', en: 'Created successfully!'),
                ),
                backgroundColor: DarAlFajrTheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          return AlertDialog(
            title: Text(
              trByLang(
                langCode,
                ar: 'إضافة طالب أو مستخدم جديد',
                he: 'הוספת תלמיד או משתמש חדש',
                en: 'Add New Student or User',
              ),
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                              : (_) => setDialogState(() {
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
                              : (_) => setDialogState(() {
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
                              : (_) => setDialogState(() {
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
                                    setDialogState(() => selectedParentId = val);
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: trByLang(langCode, ar: 'رقم الهاتف', he: 'מספר טלפון', en: 'Phone Number'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.of(dialogContext).pop(),
                child: Text(trByLang(langCode, ar: 'إلغاء', he: 'ביטול', en: 'Cancel')),
              ),
              OutlinedButton(
                onPressed: isSaving ? null : () => submit(keepOpen: true),
                child: Text(
                  trByLang(langCode, ar: 'حفظ وإضافة آخر', he: 'שמור והוסף עוד', en: 'Save & Add Another'),
                ),
              ),
              ElevatedButton(
                onPressed: isSaving ? null : () => submit(keepOpen: false),
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(trByLang(langCode, ar: 'حفظ وإضافة', he: 'שמור', en: 'Save')),
              ),
            ],
          );
        },
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
  final teachers = ref.read(adminTeachersProvider).value ?? [];
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

  String? selectedTeacherId = existingGroup?.teacherId.isNotEmpty == true
      ? existingGroup!.teacherId
      : (teachers.isNotEmpty ? teachers.first.uid : null);
  if (teachers.isNotEmpty && !teachers.any((t) => t.uid == selectedTeacherId)) {
    selectedTeacherId = teachers.first.uid;
  }
  final teacherController = TextEditingController(
    text: existingGroup?.teacherName.isNotEmpty == true
        ? existingGroup!.teacherName
        : (teachers.isNotEmpty
            ? teachers.first.fullName
            : (isDemoFallback ? 'الشيخ عبد الرحمن' : '')),
  );
  final messenger = ScaffoldMessenger.maybeOf(context);
  bool isSaving = false;
  String? errorMessage;
  String? successMessage;

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
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

            setDialogState(() {
              isSaving = true;
              errorMessage = null;
              successMessage = null;
            });

            final enteredTeacher = teacherController.text.trim();
            final matchedTeacher = teachers
                .where(
                  (t) =>
                      t.uid == selectedTeacherId ||
                      t.fullName == enteredTeacher,
                )
                .firstOrNull;
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
            final resolvedTeacherName = matchedTeacher?.fullName ?? enteredTeacher;

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

          return AlertDialog(
            title: Text(
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
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    if (teachers.isNotEmpty)
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
                        items: teachers
                            .map(
                              (t) => DropdownMenuItem<String>(
                                value: t.uid,
                                child: Text(t.fullName),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedTeacherId = val;
                            final picked = teachers.where((t) => t.uid == val).firstOrNull;
                            if (picked != null) {
                              teacherController.text = picked.fullName;
                            }
                          });
                        },
                      )
                    else
                      TextField(
                        controller: teacherController,
                        decoration: InputDecoration(
                          labelText: trByLang(
                            langCode,
                            ar: 'اسم الشيخ / المعلم',
                            he: 'שם המורה',
                            en: 'Teacher Name',
                          ),
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
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.of(dialogContext).pop(),
                child: Text(
                  trByLang(langCode, ar: 'إلغاء', he: 'ביטול', en: 'Cancel'),
                ),
              ),
              if (!isEditing)
                OutlinedButton(
                  onPressed: isSaving ? null : () => submitGroup(keepOpen: true),
                  child: Text(
                    trByLang(langCode, ar: 'حفظ وإضافة أخرى', he: 'שמור והוסף עוד', en: 'Save & Add Another'),
                  ),
                ),
              ElevatedButton(
                onPressed: isSaving ? null : () => submitGroup(keepOpen: false),
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
            ],
          );
        },
      );
    },
  );
}
