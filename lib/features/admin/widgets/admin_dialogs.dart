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

void showAdminAddStudentOrUserDialog(
  BuildContext context,
  WidgetRef ref,
  String langCode,
) {
  final nameController = TextEditingController();
  final parentNameController = TextEditingController();
  final emailController = TextEditingController();
  final tempPasswordController = TextEditingController(text: 'Fajr@2026');
  final phoneController = TextEditingController();
  UserRole selectedRole = UserRole.student;
  final messenger = ScaffoldMessenger.maybeOf(context);

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
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
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<UserRole>(
                      initialValue: selectedRole,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: trByLang(langCode, ar: 'نوع الحساب', he: 'סוג חשבון', en: 'Account Role'),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: UserRole.student,
                          child: Text(trByLang(langCode, ar: 'طالب (Student)', he: 'תלמיד', en: 'Student')),
                        ),
                        DropdownMenuItem(
                          value: UserRole.parent,
                          child: Text(trByLang(langCode, ar: 'ولي أمر (Parent)', he: 'הורה', en: 'Parent')),
                        ),
                        DropdownMenuItem(
                          value: UserRole.teacher,
                          child: Text(trByLang(langCode, ar: 'معلم / شيخ (Teacher)', he: 'מורה', en: 'Teacher')),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedRole = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: trByLang(langCode, ar: 'الاسم الكامل *', he: 'שם מלא *', en: 'Full Name *'),
                      ),
                    ),
                    if (selectedRole == UserRole.student) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: parentNameController,
                        decoration: InputDecoration(
                          labelText: trByLang(langCode, ar: 'اسم ولي الأمر *', he: 'שם ההורה *', en: 'Parent Name *'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: trByLang(langCode, ar: 'البريد الإلكتروني', he: 'דוא״ל', en: 'Email Address'),
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
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(trByLang(langCode, ar: 'إلغاء', he: 'ביטול', en: 'Cancel')),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
                  Navigator.of(dialogContext).pop();

                  if (selectedRole == UserRole.student) {
                    await ref.read(adminControllerProvider.notifier).createStudent(
                          fullName: nameController.text.trim(),
                          parentId: 'parent-default',
                          parentName: parentNameController.text.trim().isEmpty
                              ? 'ولي الأمر'
                              : parentNameController.text.trim(),
                          email: emailController.text.trim(),
                          temporaryPassword: tempPasswordController.text.trim(),
                          phoneNumber: phoneController.text.trim(),
                        );
                  } else {
                    await ref.read(adminControllerProvider.notifier).createTeacherOrParent(
                          email: emailController.text.trim(),
                          temporaryPassword: tempPasswordController.text.trim(),
                          fullName: nameController.text.trim(),
                          role: selectedRole,
                          phoneNumber: phoneController.text.trim(),
                        );
                  }

                  messenger?.showSnackBar(
                    SnackBar(
                      content: Text(
                        trByLang(langCode, ar: 'تمت الإضافة بنجاح!', he: 'נוסף בהצלחה!', en: 'Created successfully!'),
                      ),
                      backgroundColor: DarAlFajrTheme.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(trByLang(langCode, ar: 'حفظ وإضافة', he: 'שמור', en: 'Save')),
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
  final teachers = ref.read(adminTeachersProvider).value ?? [];
  final nameController = TextEditingController();
  CenterTrack selectedTrack = CenterTrack.hifz;
  final startTimeController = TextEditingController(text: '17:00');
  final endTimeController = TextEditingController(text: '18:30');
  final capacityController = TextEditingController(text: '15');
  final selectedDays = <String>{'السبت', 'الاثنين'};
  String? selectedTeacherId = teachers.isNotEmpty ? teachers.first.uid : null;
  final teacherController = TextEditingController(
    text: teachers.isNotEmpty
        ? teachers.first.fullName
        : (isDemoFallback ? 'الشيخ عبد الرحمن' : ''),
  );
  final messenger = ScaffoldMessenger.maybeOf(context);

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              trByLang(
                langCode,
                ar: 'إنشاء حلقة جديدة',
                he: 'יצירת קבוצה חדשה',
                en: 'Create New Study Group',
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
                        return FilterChip(
                          label: Text(day, style: const TextStyle(fontSize: 11.5)),
                          selected: isSelected,
                          onSelected: (checked) {
                            setDialogState(() {
                              if (checked) {
                                selectedDays.add(day);
                              } else if (selectedDays.length > 1) {
                                selectedDays.remove(day);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
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
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  trByLang(langCode, ar: 'إلغاء', he: 'ביטול', en: 'Cancel'),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
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
                  Navigator.of(dialogContext).pop();
                  await ref.read(adminControllerProvider.notifier).createGroup(
                        name: nameController.text.trim(),
                        track: selectedTrack,
                        teacherId: matchedTeacher?.uid ??
                            (isDemoFallback ? 'teacher-1' : ''),
                        teacherName: matchedTeacher?.fullName ?? enteredTeacher,
                        scheduleDays: selectedDays.toList(),
                        startTime: startTimeController.text.trim(),
                        endTime: endTimeController.text.trim(),
                        capacity: parsedCapacity,
                      );
                  messenger?.showSnackBar(
                    SnackBar(
                      content: Text(
                        trByLang(
                          langCode,
                          ar: 'تم إنشاء الحلقة بنجاح!',
                          he: 'הקבוצה נוצרה בהצלחה!',
                          en: 'Study group created successfully!',
                        ),
                      ),
                      backgroundColor: DarAlFajrTheme.primary,
                    ),
                  );
                },
                child: Text(
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
