import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';

import '../../../core/services/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/admin_models.dart';
import '../providers/admin_providers.dart';
import '../../hifz/models/teacher_models.dart';
import '../../hifz/providers/teacher_providers.dart';
import 'admin_mobile_screen.dart';

class _AdminRosterRowData {
  final String id;
  final String code;
  final String fullName;
  final String initial;
  final String parentName;
  final String parentEmail;
  final List<_TrackBadgeData> trackBadges;
  final CenterTrack primaryTrack;
  final String groupSchedule;
  final String? oneOnOneSchedule;
  final bool isHighlighted;
  final bool isFromFirestore;

  const _AdminRosterRowData({
    required this.id,
    required this.code,
    required this.fullName,
    required this.initial,
    required this.parentName,
    required this.parentEmail,
    required this.trackBadges,
    required this.primaryTrack,
    required this.groupSchedule,
    this.oneOnOneSchedule,
    this.isHighlighted = false,
    this.isFromFirestore = false,
  });
}

class _TrackBadgeData {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _TrackBadgeData({required this.label, required this.backgroundColor, required this.textColor});
}

class AdminShellScreen extends ConsumerStatefulWidget {
  const AdminShellScreen({super.key});

  @override
  ConsumerState<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends ConsumerState<AdminShellScreen> {
  final _searchController = TextEditingController();
  final _subSearchController = TextEditingController();

  bool _isEnrollDrawerOpen = false;
  String _searchQuery = '';

  // Enrollment Drawer State
  late String _selectedStudentName = Firebase.apps.isEmpty ? 'إبراهيم طه عثمان' : '';
  late String _selectedStudentCode = Firebase.apps.isEmpty ? '#ST-1042' : '';
  late String _selectedStudentId = Firebase.apps.isEmpty ? 'st-1042' : '';
  CenterTrack _selectedTargetTrack = CenterTrack.readingTajweed;
  late String _selectedGroupLabel = Firebase.apps.isEmpty ? 'حلقة الإتقان والتجويد (مسار التجويد المتقدم)' : '';
  late String _selectedGroupId = Firebase.apps.isEmpty ? 'grp-tajweed-1' : '';
  bool _hasOneOnOneSlot = true;
  String _selectedOneOnOneDay = 'الخميس';
  String _selectedOneOnOneTime = '17:15';

  // Attendance Audit Tab Filters
  String? _auditGroupFilter;
  AttendanceStatus? _auditStatusFilter;

  static const List<String> _weekDaysAr = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

  static const List<_AdminRosterRowData> _seedRosterRows = [
    _AdminRosterRowData(
      id: 'st-1042',
      code: '#ST-1042',
      fullName: 'إبراهيم طه عثمان',
      initial: 'إ',
      parentName: 'طه عثمان',
      parentEmail: 'taha.osman@email.com',
      primaryTrack: CenterTrack.qaidahNouraniah,
      trackBadges: [
        _TrackBadgeData(label: 'قاعدة نورانية', backgroundColor: Color(0xFFABEFE8), textColor: Color(0xFF00201E)),
        _TrackBadgeData(label: 'تجويد (معلق)', backgroundColor: Color(0xFFFFDCC3), textColor: Color(0xFF2F1500)),
      ],
      groupSchedule: 'الأحد والثلاثاء والخميس 16:30',
      oneOnOneSchedule: 'الخميس 17:15 (فردي)',
      isHighlighted: true,
    ),
    _AdminRosterRowData(
      id: 'st-1088',
      code: '#ST-1088',
      fullName: 'عبد الرحمن يوسف الشريف',
      initial: 'ع',
      parentName: 'يوسف الشريف',
      parentEmail: 'y.shareef@domain.org',
      primaryTrack: CenterTrack.hifz,
      trackBadges: [
        _TrackBadgeData(label: 'حفظ مكثف', backgroundColor: Color(0xFF89F5E7), textColor: Color(0xFF00201D)),
      ],
      groupSchedule: 'السبت والاثنين 17:00',
      oneOnOneSchedule: 'الاثنين 18:00 (فردي)',
    ),
    _AdminRosterRowData(
      id: 'st-1102',
      code: '#ST-1102',
      fullName: 'زياد المنصور',
      initial: 'ز',
      parentName: 'سليمان المنصور',
      parentEmail: 'mansour.s@gmail.com',
      primaryTrack: CenterTrack.readingTajweed,
      trackBadges: [
        _TrackBadgeData(label: 'تجويد وإتقان', backgroundColor: Color(0xFFFFDCC3), textColor: Color(0xFF2F1500)),
      ],
      groupSchedule: 'الأحد والأربعاء 16:00',
      oneOnOneSchedule: null,
    ),
    _AdminRosterRowData(
      id: 'st-1115',
      code: '#ST-1115',
      fullName: 'حمزة كمال الدين',
      initial: 'ح',
      parentName: 'كمال الدين فؤاد',
      parentEmail: 'kamal.din@outlook.com',
      primaryTrack: CenterTrack.qaidahNouraniah,
      trackBadges: [
        _TrackBadgeData(label: 'قاعدة نورانية', backgroundColor: Color(0xFFABEFE8), textColor: Color(0xFF00201E)),
      ],
      groupSchedule: 'السبت والخميس 15:30',
      oneOnOneSchedule: null,
    ),
    _AdminRosterRowData(
      id: 'st-1130',
      code: '#ST-1130',
      fullName: 'عمر فاروق البغدادي',
      initial: 'ع',
      parentName: 'فاروق البغدادي',
      parentEmail: 'baghdadi.f@edu.org',
      primaryTrack: CenterTrack.tarbawi,
      trackBadges: [
        _TrackBadgeData(label: 'تربوي وتدبر', backgroundColor: Color(0xFFE0E3E5), textColor: Color(0xFF3D4947)),
      ],
      groupSchedule: 'الجمعة 17:30',
      oneOnOneSchedule: 'الجمعة 19:00 (فردي)',
    ),
    _AdminRosterRowData(
      id: 'st-1144',
      code: '#ST-1144',
      fullName: 'بلال سعد السبيعي',
      initial: 'ب',
      parentName: 'سعد السبيعي',
      parentEmail: 'saad.subaie@live.com',
      primaryTrack: CenterTrack.hifz,
      trackBadges: [
        _TrackBadgeData(label: 'حفظ مكثف', backgroundColor: Color(0xFF89F5E7), textColor: Color(0xFF00201D)),
      ],
      groupSchedule: 'الأحد والثلاثاء والخميس 17:00',
      oneOnOneSchedule: null,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _subSearchController.dispose();
    super.dispose();
  }

  bool get _isDemoFallback {
    if (Firebase.apps.isNotEmpty) return false;
    final studentsState = ref.read(adminStudentsProvider);
    final groupsState = ref.read(adminGroupsProvider);
    final enrollmentsState = ref.read(adminEnrollmentsProvider);
    final usersState = ref.read(adminAllUsersProvider);
    final logsState = ref.read(adminAttendanceLogsProvider);
    final assignmentsState = ref.read(adminHifzAssignmentsProvider);
    if (studentsState.isLoading ||
        groupsState.isLoading ||
        enrollmentsState.isLoading ||
        usersState.isLoading ||
        logsState.isLoading ||
        assignmentsState.isLoading) {
      return false;
    }
    final students = studentsState.asData?.value ?? const [];
    final groups = groupsState.asData?.value ?? const [];
    final enrollments = enrollmentsState.asData?.value ?? const [];
    final users = usersState.asData?.value ?? const [];
    final logs = logsState.asData?.value ?? const [];
    final assignments = assignmentsState.asData?.value ?? const [];
    return students.isEmpty &&
        groups.isEmpty &&
        enrollments.isEmpty &&
        users.isEmpty &&
        logs.isEmpty &&
        assignments.isEmpty;
  }

  bool _hasQaidahTajweedConflict(List<_AdminRosterRowData> rows) {
    final row = rows.where((r) => r.id == _selectedStudentId).firstOrNull;
    if (row == null) {
      return _selectedTargetTrack == CenterTrack.readingTajweed;
    }
    final isCurrentlyQaidah = row.primaryTrack == CenterTrack.qaidahNouraniah;
    final isCurrentlyTajweed = row.primaryTrack == CenterTrack.readingTajweed;

    return (isCurrentlyQaidah && _selectedTargetTrack == CenterTrack.readingTajweed) ||
        (isCurrentlyTajweed && _selectedTargetTrack == CenterTrack.qaidahNouraniah);
  }

  Future<void> _pickOneOnOneTime() async {
    final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 17, minute: 15));
    if (picked != null && mounted) {
      final hh = picked.hour.toString().padLeft(2, '0');
      final mm = picked.minute.toString().padLeft(2, '0');
      setState(() {
        _selectedOneOnOneTime = '$hh:$mm';
      });
    }
  }

  Future<void> _handleSaveEnrollment(String langCode) async {
    if (_selectedStudentId.isEmpty || _selectedGroupId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            trByLang(
              langCode,
              ar: 'يرجى اختيار الطالب والحلقة أولاً',
              he: 'אנא בחר תלמיד וקבוצה תחילה',
              en: 'Please select a student and study group first',
            ),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final slotString = _hasOneOnOneSlot ? '$_selectedOneOnOneDay $_selectedOneOnOneTime (فردي)' : null;
    final groups = ref.read(adminGroupsProvider).value ?? [];
    final matchedGroup = groups.where((g) => g.id == _selectedGroupId).firstOrNull;
    final arrivalTime = matchedGroup != null
        ? '${matchedGroup.scheduleDays.join('، ')} ${matchedGroup.startTime}'.trim()
        : (_isDemoFallback ? 'الأحد والثلاثاء والخميس 16:30' : '');

    await ref
        .read(adminControllerProvider.notifier)
        .assignStudentToGroup(
          studentId: _selectedStudentId,
          studentName: _selectedStudentName,
          groupId: _selectedGroupId,
          groupName: _selectedGroupLabel,
          track: _selectedTargetTrack,
          oneOnOneSlotTime: slotString,
          groupArrivalTime: arrivalTime,
        );

    if (!mounted) return;
    setState(() {
      _isEnrollDrawerOpen = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          trByLang(
            langCode,
            ar: 'تم حفظ التسجيل وتثبيت الموعد بنجاح.',
            he: 'ההרשמה נשמרה בהצלחה.',
            en: 'Enrollment and schedule saved successfully.',
          ),
        ),
        backgroundColor: DarAlFajrTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showGradingSettingsDialog(String langCode) async {
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

  void _showAddStudentOrUserDialog(String langCode) {
    final nameController = TextEditingController();
    final parentNameController = TextEditingController();
    final emailController = TextEditingController();
    final tempPasswordController = TextEditingController(text: 'Fajr@2026');
    final phoneController = TextEditingController();
    UserRole selectedRole = UserRole.student;

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
                      await ref
                          .read(adminControllerProvider.notifier)
                          .createStudent(
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
                      await ref
                          .read(adminControllerProvider.notifier)
                          .createTeacherOrParent(
                            email: emailController.text.trim(),
                            temporaryPassword: tempPasswordController.text.trim(),
                            fullName: nameController.text.trim(),
                            role: selectedRole,
                            phoneNumber: phoneController.text.trim(),
                          );
                    }

                    if (!mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
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

  void _showCreateGroupDialog(String langCode) {
    final teachers = ref.read(adminTeachersProvider).value ?? [];
    final nameController = TextEditingController();
    CenterTrack selectedTrack = CenterTrack.hifz;
    final startTimeController = TextEditingController(text: '17:00');
    final endTimeController = TextEditingController(text: '18:30');
    final capacityController = TextEditingController(text: '15');
    final selectedDays = <String>{'السبت', 'الاثنين'};
    String? selectedTeacherId =
        teachers.isNotEmpty ? teachers.first.uid : null;
    final teacherController = TextEditingController(
      text: teachers.isNotEmpty
          ? teachers.first.fullName
          : (_isDemoFallback ? 'الشيخ عبد الرحمن' : ''),
    );

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
                              final picked = teachers
                                  .where((t) => t.uid == val)
                                  .firstOrNull;
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
                        children: _weekDaysAr.map((day) {
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
                              (_isDemoFallback ? 'teacher-1' : ''),
                          teacherName: matchedTeacher?.fullName ?? enteredTeacher,
                          scheduleDays: selectedDays.toList(),
                          startTime: startTimeController.text.trim(),
                          endTime: endTimeController.text.trim(),
                          capacity: parsedCapacity,
                        );
                    if (!mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
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

  List<_AdminRosterRowData> _buildRosterRows(
    List<StudentProfile> firestoreStudents,
    List<Enrollment> firestoreEnrollments,
  ) {
    final mappedFirestore = firestoreStudents.map((student) {
      final studentEnrollments = firestoreEnrollments.where((e) => e.studentId == student.id).toList();
      final primaryEnrollment = studentEnrollments.firstOrNull;
      final track = primaryEnrollment?.track ?? CenterTrack.hifz;
      final trimmedName = student.fullName.trim();
      final initial = trimmedName.isNotEmpty ? trimmedName.characters.first : 'ط';
      final shortId = student.id.length >= 4 ? student.id.substring(0, 4).toUpperCase() : student.id.toUpperCase();

      return _AdminRosterRowData(
        id: student.id,
        code: '#ST-$shortId',
        fullName: student.fullName,
        initial: initial,
        parentName: student.parentName ?? 'ولي الأمر',
        parentEmail: student.email ?? student.phoneNumber ?? '—',
        primaryTrack: track,
        trackBadges: [
          _TrackBadgeData(
            label: track.localizedName('ar'),
            backgroundColor: const Color(0xFF89F5E7),
            textColor: const Color(0xFF00201D),
          ),
        ],
        groupSchedule: primaryEnrollment?.groupArrivalTime ?? (_isDemoFallback ? 'الأحد والثلاثاء والخميس 16:30' : ''),
        oneOnOneSchedule: primaryEnrollment?.oneOnOneSlotTime,
        isFromFirestore: true,
      );
    }).toList();

    final combined = _isDemoFallback
        ? [...mappedFirestore, ..._seedRosterRows]
        : mappedFirestore;

    final trackFilter = ref.watch(adminTrackFilterProvider);
    return combined.where((row) {
      if (trackFilter != null && row.primaryTrack != trackFilter) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        return row.fullName.toLowerCase().contains(q) ||
            row.parentName.toLowerCase().contains(q) ||
            row.parentEmail.toLowerCase().contains(q) ||
            row.code.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final langCode = currentLocale.languageCode;
    final isRtl = isRtlLocale(currentLocale);
    final selectedTab = ref.watch(adminSelectedTabProvider);
    final selectedTrackFilter = ref.watch(adminTrackFilterProvider);
    final appUser = ref.watch(currentAppUserProvider).asData?.value;

    final firestoreStudents = ref.watch(adminStudentsProvider).asData?.value ?? const [];
    final firestoreGroups = ref.watch(adminGroupsProvider).asData?.value ?? const [];
    final firestoreEnrollments = ref.watch(adminEnrollmentsProvider).asData?.value ?? const [];
    final allUsers = ref.watch(adminAllUsersProvider).asData?.value ?? const [];

    final rosterRows = _buildRosterRows(firestoreStudents, firestoreEnrollments);

    final isDemoMode = _isDemoFallback;
    if (!isDemoMode) {
      if (_selectedStudentId.isEmpty && firestoreStudents.isNotEmpty) {
        final first = firestoreStudents.first;
        _selectedStudentId = first.id;
        _selectedStudentName = first.fullName;
        final shortCode = first.id.length >= 4 ? first.id.substring(0, 4).toUpperCase() : first.id.toUpperCase();
        _selectedStudentCode = '#ST-$shortCode';
      }
      if (_selectedGroupId.isEmpty && firestoreGroups.isNotEmpty) {
        final firstGroup = firestoreGroups.first;
        _selectedGroupId = firstGroup.id;
        _selectedGroupLabel = firstGroup.name;
        _selectedTargetTrack = firstGroup.track;
      }
    }
    final totalStudentsCount = firestoreStudents.isNotEmpty
        ? firestoreStudents.length
        : (isDemoMode ? 6 : 0);
    final totalGroupsCount = firestoreGroups.isNotEmpty
        ? firestoreGroups.length
        : (isDemoMode ? 3 : 0);
    final totalOneOnOneCount = firestoreEnrollments.isNotEmpty
        ? firestoreEnrollments.where((e) => e.oneOnOneSlotTime != null && e.oneOnOneSlotTime!.isNotEmpty).length
        : (isDemoMode ? 3 : 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return const AdminMobileScreen();
        }

        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
        backgroundColor: DarAlFajrTheme.background,
        body: Stack(
          children: [
            // Main Desktop Shell (Sidebar + Content Area)
            Positioned.fill(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Fixed-Width Navigation Sidebar (260px)
                  Container(
                    width: 260,
                    decoration: BoxDecoration(
                      color: DarAlFajrTheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Brand Header + Nav Links
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(
                                      'assets/logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trByLang(langCode, ar: 'دار الفجر', he: 'דאר אל-פג׳ר', en: 'Dar al-Fajr'),
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          trByLang(
                                            langCode,
                                            ar: 'الإدارة الأكاديمية',
                                            he: 'הנהלה אקדמית',
                                            en: 'Academic Administration',
                                          ),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelSmall?.copyWith(color: const Color(0xFF89F5E7)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Sidebar Navigation Items
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  _SidebarNavItem(
                                    icon: Icons.group_rounded,
                                    label: trByLang(langCode, ar: 'المستخدمين', he: 'משתמשים', en: 'Users'),
                                    isSelected: selectedTab == 0,
                                    onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(0),
                                  ),
                                  const SizedBox(height: 4),
                                  _SidebarNavItem(
                                    icon: Icons.school_rounded,
                                    label: trByLang(langCode, ar: 'الطلاب', he: 'תלמידים', en: 'Students'),
                                    isSelected: selectedTab == 1,
                                    onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(1),
                                  ),
                                  const SizedBox(height: 4),
                                  _SidebarNavItem(
                                    icon: Icons.diversity_3_rounded,
                                    label: trByLang(
                                      langCode,
                                      ar: 'الحلقات والمجموعات',
                                      he: 'קבוצות ושיעורים',
                                      en: 'Groups & Classes',
                                    ),
                                    isSelected: selectedTab == 2,
                                    onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(2),
                                  ),
                                  const SizedBox(height: 4),
                                  _SidebarNavItem(
                                    icon: Icons.event_available_rounded,
                                    label: trByLang(
                                      langCode,
                                      ar: 'التسجيل والمواعيد',
                                      he: 'רישום ולו״ז',
                                      en: 'Enrollments & Slots',
                                    ),
                                    isSelected: selectedTab == 3,
                                    onTap: () {
                                      ref.read(adminSelectedTabProvider.notifier).setTab(3);
                                      setState(() {
                                        _isEnrollDrawerOpen = true;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  _SidebarNavItem(
                                    icon: Icons.fact_check_rounded,
                                    label: trByLang(langCode, ar: 'سجل الحضور', he: 'יומן נוכחות', en: 'Attendance Logs'),
                                    isSelected: selectedTab == 4,
                                    onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(4),
                                  ),
                                  const SizedBox(height: 4),
                                  _SidebarNavItem(
                                    icon: Icons.monitor_rounded,
                                    label: trByLang(
                                      langCode,
                                      ar: 'التقارير والإحصائيات',
                                      he: 'דוחות וסטטיסטיקה',
                                      en: 'Reports & Analytics',
                                    ),
                                    isSelected: selectedTab == 5,
                                    onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Sidebar Bottom Admin Profile & Logout
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: DarAlFajrTheme.primaryDark,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          color: DarAlFajrTheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              appUser?.fullName.isNotEmpty == true
                                                  ? appUser!.fullName
                                                  : trByLang(
                                                      langCode,
                                                      ar: 'مدير النظام',
                                                      he: 'מנהל מערכת',
                                                      en: 'System Admin',
                                                    ),
                                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              appUser?.email.isNotEmpty == true
                                                  ? appUser!.email
                                                  : 'admin@daralfajr.org',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelSmall?.copyWith(color: const Color(0xFF89F5E7)),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                                  tooltip: trByLang(langCode, ar: 'تسجيل الخروج', he: 'התנתק', en: 'Logout'),
                                  icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content Area
                  Expanded(
                    child: Column(
                      children: [
                        // Top Header Bar (64px)
                        Container(
                          height: 64,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: DarAlFajrTheme.surface.withValues(alpha: 0.9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Global Search Input
                              Expanded(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 480),
                                  child: SizedBox(
                                    height: 40,
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (val) {
                                        setState(() {
                                          _searchQuery = val;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: trByLang(
                                          langCode,
                                          ar: 'بحث شامل عن طالب، حلقة، أو ولي أمر...',
                                          he: 'חיפוש תלמיד, קבוצה או הורה...',
                                          en: 'Search student, group, or parent...',
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.search_rounded,
                                          size: 20,
                                          color: Color(0xFF6D7A77),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Language Switcher + Action CTAs + Avatar
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _showGradingSettingsDialog(langCode),
                                    tooltip: trByLang(
                                      langCode,
                                      ar: 'إعدادات التقييم والرصيد السابق',
                                      he: 'הגדרות ציונים ויתרה קודמת',
                                      en: 'Grading Thresholds & Prior Balance',
                                    ),
                                    icon: const Icon(Icons.tune_rounded, color: DarAlFajrTheme.primary),
                                  ),
                                  const SizedBox(width: 6),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _isEnrollDrawerOpen = true;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE6E8EA),
                                      foregroundColor: const Color(0xFF191C1E),
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    ),
                                    icon: const Icon(Icons.group_add_rounded, size: 18),
                                    label: Text(
                                      trByLang(
                                        langCode,
                                        ar: '+ تسجيل في حلقة',
                                        he: '+ רישום לקבוצה',
                                        en: '+ Enroll in Group',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _showAddStudentOrUserDialog(langCode),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: DarAlFajrTheme.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    ),
                                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                                    label: Text(
                                      trByLang(langCode, ar: '+ إضافة طالب', he: '+ הוסף תלמיד', en: '+ Add Student'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: () => context.go(AppRoutes.account),
                                    borderRadius: BorderRadius.circular(18),
                                    child: Tooltip(
                                      message: trByLang(langCode, ar: 'حسابي', he: 'החשבון שלי', en: 'My Account'),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          color: DarAlFajrTheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.person_rounded, size: 20, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Dynamic Tab Body
                        Expanded(
                          child: _buildSelectedTabContent(
                            context: context,
                            langCode: langCode,
                            selectedTab: selectedTab,
                            rosterRows: rosterRows,
                            totalStudentsCount: totalStudentsCount,
                            totalGroupsCount: totalGroupsCount,
                            totalOneOnOneCount: totalOneOnOneCount,
                            selectedTrackFilter: selectedTrackFilter,
                            allUsers: allUsers,
                            firestoreGroups: firestoreGroups,
                            firestoreEnrollments: firestoreEnrollments,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Slide-Over Enrollment Drawer Overlay (End edge / Left side in RTL)
            if (_isEnrollDrawerOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEnrollDrawerOpen = false;
                    });
                  },
                  child: Container(
                    color: const Color(0xFF2D3133).withValues(alpha: 0.4),
                    alignment: AlignmentDirectional.centerEnd,
                    child: GestureDetector(
                      onTap: () {}, // Prevent backdrop tap inside drawer
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
                                            const Icon(
                                              Icons.group_add_rounded,
                                              color: DarAlFajrTheme.primary,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              trByLang(
                                                langCode,
                                                ar: 'تسجيل طالب في حلقة',
                                                he: 'רישום תלמיד לקבוצה',
                                                en: 'Enroll Student in Group',
                                              ),
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6D7A77)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isEnrollDrawerOpen = false;
                                      });
                                    },
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
                                  // Field 1: Student Selection
                                  Row(
                                    children: [
                                      Text(
                                        trByLang(langCode, ar: 'اختيار الطالب', he: 'בחירת תלמיד', en: 'Select Student'),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
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
                                  PopupMenuButton<_AdminRosterRowData>(
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedStudentId = selected.id;
                                        _selectedStudentName = selected.fullName;
                                        _selectedStudentCode = selected.code;
                                      });
                                    },
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
                                                  _selectedStudentName.isNotEmpty
                                                      ? _selectedStudentName.characters.first
                                                      : 'إ',
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
                                                    _selectedStudentName,
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                  Text(
                                                    'رقم القيد: $_selectedStudentCode',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.labelSmall?.copyWith(color: DarAlFajrTheme.primary),
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

                                  // Field 2: Track & Group Selection
                                  Row(
                                    children: [
                                      Text(
                                        trByLang(
                                          langCode,
                                          ar: 'المسار والحلقة المستهدفة',
                                          he: 'מסלול וקבוצת יעד',
                                          en: 'Target Track & Group',
                                        ),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
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
                                    onSelected: (tuple) {
                                      setState(() {
                                        _selectedTargetTrack = tuple.$1;
                                        _selectedGroupId = tuple.$2;
                                        _selectedGroupLabel = tuple.$3;
                                      });
                                    },
                                    itemBuilder: (context) {
                                      final liveGroups = ref.read(adminGroupsProvider).value ?? [];
                                      if (liveGroups.isNotEmpty) {
                                        return liveGroups
                                            .map(
                                              (g) => PopupMenuItem<(CenterTrack, String, String)>(
                                                value: (g.track, g.id, g.name),
                                                child: Text(
                                                  '${g.name} (${g.scheduleDays.join('، ')} ${g.startTime})',
                                                ),
                                              ),
                                            )
                                            .toList();
                                      }
                                      if (_isDemoFallback) {
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
                                                const Icon(
                                                  Icons.menu_book_rounded,
                                                  size: 20,
                                                  color: DarAlFajrTheme.accent,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _selectedGroupLabel,
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
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

                                  // Red Validation Alert Box (Mandated exact text & styling)
                                  if (_hasQaidahTajweedConflict(rosterRows)) ...[
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFDAD6).withValues(alpha: 0.55),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: Theme.of(context).colorScheme.error,
                                            size: 24,
                                          ),
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

                                  // Toggle Switch: 1-on-1 Individual Slot
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.record_voice_over_rounded,
                                              color: DarAlFajrTheme.accent,
                                              size: 20,
                                            ),
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
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                  Text(
                                                    trByLang(
                                                      langCode,
                                                      ar: 'جلسة تسميع فردية خاصة مع الشيخ',
                                                      he: 'מפגש דקלום אישי עם המורה',
                                                      en: 'Private recitation slot with the teacher',
                                                    ),
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.labelSmall?.copyWith(color: const Color(0xFF6D7A77)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: _hasOneOnOneSlot,
                                        activeThumbColor: Colors.white,
                                        activeTrackColor: DarAlFajrTheme.primary,
                                        onChanged: (val) {
                                          setState(() {
                                            _hasOneOnOneSlot = val;
                                          });
                                        },
                                      ),
                                    ],
                                  ),

                                  // Revealed Child Fields for 1-on-1 Slot
                                  if (_hasOneOnOneSlot) ...[
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
                                              // Day Picker
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
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelSmall?.copyWith(color: const Color(0xFF6D7A77)),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    PopupMenuButton<String>(
                                                      onSelected: (day) {
                                                        setState(() {
                                                          _selectedOneOnOneDay = day;
                                                        });
                                                      },
                                                      itemBuilder: (context) => _weekDaysAr
                                                          .map((d) => PopupMenuItem(value: d, child: Text(d)))
                                                          .toList(),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 8,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: DarAlFajrTheme.surface,
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              _selectedOneOnOneDay,
                                                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            const Icon(
                                                              Icons.calendar_today_rounded,
                                                              size: 16,
                                                              color: Color(0xFF6D7A77),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),

                                              // Time Picker
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
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelSmall?.copyWith(color: const Color(0xFF6D7A77)),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    InkWell(
                                                      onTap: _pickOneOnOneTime,
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 8,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: DarAlFajrTheme.surface,
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              _selectedOneOnOneTime,
                                                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            const Icon(
                                                              Icons.schedule_rounded,
                                                              size: 16,
                                                              color: Color(0xFF6D7A77),
                                                            ),
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

                                          // Duration & Teacher pill
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: DarAlFajrTheme.accent.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.info_outline_rounded,
                                                  size: 16,
                                                  color: Color(0xFF904D00),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Builder(
                                                    builder: (context) {
                                                      final liveGroups = ref.watch(adminGroupsProvider).asData?.value ?? const [];
                                                      final matchedGroup = liveGroups
                                                          .where((g) => g.id == _selectedGroupId)
                                                          .firstOrNull;
                                                      final teacherName = matchedGroup != null && matchedGroup.teacherName.trim().isNotEmpty
                                                          ? matchedGroup.teacherName.trim()
                                                          : (_isDemoFallback
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
                                    onPressed: () => _handleSaveEnrollment(langCode),
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
                                    onPressed: () {
                                      setState(() {
                                        _isEnrollDrawerOpen = false;
                                      });
                                    },
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
              ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildSelectedTabContent({
    required BuildContext context,
    required String langCode,
    required int selectedTab,
    required List<_AdminRosterRowData> rosterRows,
    required int totalStudentsCount,
    required int totalGroupsCount,
    required int totalOneOnOneCount,
    required CenterTrack? selectedTrackFilter,
    required List<AppUser> allUsers,
    required List<StudyGroup> firestoreGroups,
    required List<Enrollment> firestoreEnrollments,
  }) {
    switch (selectedTab) {
      case 0:
        return _buildUsersTab(context, langCode, allUsers);
      case 2:
        return _buildGroupsTab(context, langCode, firestoreGroups, firestoreEnrollments);
      case 3:
        return _buildEnrollmentsTab(context, langCode, firestoreEnrollments);
      case 4:
        return _buildAttendanceTab(context, langCode, firestoreGroups);
      case 5:
        return _buildReportsTab(
          context,
          langCode,
          ref.watch(adminStudentsProvider).asData?.value ?? const [],
          firestoreGroups,
          firestoreEnrollments,
        );
      case 1:
      default:
        return _buildStudentsTab(
          context: context,
          langCode: langCode,
          rosterRows: rosterRows,
          totalStudentsCount: totalStudentsCount,
          totalGroupsCount: totalGroupsCount,
          totalOneOnOneCount: totalOneOnOneCount,
          selectedTrackFilter: selectedTrackFilter,
        );
    }
  }

  Widget _buildStudentsTab({
    required BuildContext context,
    required String langCode,
    required List<_AdminRosterRowData> rosterRows,
    required int totalStudentsCount,
    required int totalGroupsCount,
    required int totalOneOnOneCount,
    required CenterTrack? selectedTrackFilter,
  }) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Sub-Header with search & action buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: DarAlFajrTheme.surface,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 3, offset: const Offset(0, 1)),
            ],
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 340,
                    height: 38,
                    child: TextField(
                      controller: _subSearchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF2F4F6),
                        hintText: trByLang(
                          langCode,
                          ar: 'البحث عن طالب، ولي أمر، أو رقم هاتف...',
                          he: 'חפש תלמיד, הורה או טלפון...',
                          en: 'Search student, parent, or phone...',
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF6D7A77)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  ),

                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showAddStudentOrUserDialog(langCode),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFECEEF0),
                      foregroundColor: const Color(0xFF191C1E),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: Text(trByLang(langCode, ar: '+ إضافة طالب', he: '+ הוסף תלמיד', en: '+ Add Student')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isEnrollDrawerOpen = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DarAlFajrTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.group_add_rounded, size: 18),
                    label: Text(trByLang(langCode, ar: '+ تسجيل في حلقة', he: '+ רישום לקבוצה', en: '+ Enroll in Group')),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Main Padded Content
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 4-Card Stats Summary Ribbon
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _StatSummaryCard(
                        width: (constraints.maxWidth - 48) / 4,
                        title: trByLang(
                          langCode,
                          ar: 'إجمالي الطلاب المسجلين',
                          he: 'סה״כ תלמידים רשומים',
                          en: 'Total Enrolled Students',
                        ),
                        value: '$totalStudentsCount',
                        unit: trByLang(langCode, ar: 'طالب نشط', he: 'תלמיד פעיל', en: 'Active students'),
                        icon: Icons.school_rounded,
                        accentColor: DarAlFajrTheme.primary,
                      ),
                      _StatSummaryCard(
                        width: (constraints.maxWidth - 48) / 4,
                        title: trByLang(langCode, ar: 'الحلقات الفعالة', he: 'קבוצות פעילות', en: 'Active Groups'),
                        value: '$totalGroupsCount',
                        unit: trByLang(langCode, ar: 'حلقة ومقرأة', he: 'קבוצות לימוד', en: 'Study circles'),
                        icon: Icons.groups_rounded,
                        accentColor: DarAlFajrTheme.primary,
                      ),
                      _StatSummaryCard(
                        width: (constraints.maxWidth - 48) / 4,
                        title: trByLang(
                          langCode,
                          ar: 'الجلسات الفردية المجدولة',
                          he: 'מפגשים אישיים מתוזמנים',
                          en: 'Scheduled 1-on-1 Slots',
                        ),
                        value: '$totalOneOnOneCount',
                        unit: trByLang(langCode, ar: 'موعد أسبوعي', he: 'מפגש שבועי', en: 'Weekly slots'),
                        icon: Icons.record_voice_over_rounded,
                        accentColor: DarAlFajrTheme.accent,
                      ),
                      Builder(
                        builder: (context) {
                          final groups = ref.watch(adminGroupsProvider).value ?? [];
                          final enrollments = ref.watch(adminEnrollmentsProvider).value ?? [];
                          final totalCapacity = groups.fold<int>(0, (sum, g) => sum + g.capacity);
                          final openSeatsValue = (_isDemoFallback && groups.isEmpty)
                              ? '18'
                              : '${(totalCapacity - enrollments.length).clamp(0, 9999)}';
                          return _StatSummaryCard(
                            width: (constraints.maxWidth - 48) / 4,
                            title: trByLang(langCode, ar: 'المقاعد المتاحة', he: 'מקומות פנויים', en: 'Available Seats'),
                            value: openSeatsValue,
                            unit: trByLang(langCode, ar: 'مقعد متاح', he: 'מקום פנוי', en: 'Open seats'),
                            icon: Icons.event_seat_rounded,
                            accentColor: const Color(0xFF3D4947),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Main Data Table Card
              Container(
                decoration: BoxDecoration(
                  color: DarAlFajrTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table Header Bar & Track Filters
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trByLang(
                                      langCode,
                                      ar: 'قائمة الطلاب المسجلين',
                                      he: 'רשימת תלמידים רשומים',
                                      en: 'Enrolled Students Roster',
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    trByLang(
                                      langCode,
                                      ar: 'إدارة الجلسات الجماعية والفردية وتتبع المقاعد',
                                      he: 'ניהול מפגשים קבוצתיים ואישיים ומעקב מקומות',
                                      en: 'Manage group & 1-on-1 sessions and seat allocation',
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6D7A77)),
                                  ),
                                ],
                              ),
                              Container(height: 24, width: 1, color: const Color(0xFFE6E8EA)),
                              _FilterChipButton(
                                label: trByLang(
                                  langCode,
                                  ar: 'الكل ($totalStudentsCount)',
                                  he: 'הכל ($totalStudentsCount)',
                                  en: 'All ($totalStudentsCount)',
                                ),
                                isSelected: selectedTrackFilter == null,
                                onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(null),
                              ),
                              _FilterChipButton(
                                label: trByLang(langCode, ar: 'مسار الحفظ', he: 'מסלול חיפז', en: 'Hifz'),
                                isSelected: selectedTrackFilter == CenterTrack.hifz,
                                onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.hifz),
                              ),
                              _FilterChipButton(
                                label: trByLang(langCode, ar: 'النورانية', he: 'נוראניה', en: 'Nouraniah'),
                                isSelected: selectedTrackFilter == CenterTrack.qaidahNouraniah,
                                onTap: () =>
                                    ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.qaidahNouraniah),
                              ),
                              _FilterChipButton(
                                label: trByLang(langCode, ar: 'التجويد', he: 'טג׳וויד', en: 'Tajweed'),
                                isSelected: selectedTrackFilter == CenterTrack.readingTajweed,
                                onTap: () =>
                                    ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.readingTajweed),
                              ),
                              _FilterChipButton(
                                label: trByLang(langCode, ar: 'التربوي', he: 'חינוכי', en: 'Tarbawi'),
                                isSelected: selectedTrackFilter == CenterTrack.tarbawi,
                                onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.tarbawi),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم تصدير ملف Excel بنجاح!'),
                                      backgroundColor: DarAlFajrTheme.primary,
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF2F4F6),
                                  foregroundColor: const Color(0xFF191C1E),
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.file_download_outlined, size: 16),
                                label: Text(trByLang(langCode, ar: 'تصدير Excel', he: 'ייצוא Excel', en: 'Export Excel')),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {},
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFF2F4F6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.filter_list_rounded, size: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Horizontal scroll wrapper for table
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final tableWidth = constraints.maxWidth > 860 ? constraints.maxWidth : 860.0;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: tableWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                            // Roster Table Header
                            Container(
                              color: const Color(0xFFF2F4F6),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      trByLang(
                                        langCode,
                                        ar: 'اسم الطالب والرقم',
                                        he: 'שם התלמיד ומספר',
                                        en: 'Student Name & ID',
                                      ),
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: const Color(0xFF6D7A77),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      trByLang(
                                        langCode,
                                        ar: 'ولي الأمر والاتصال',
                                        he: 'הורה ויצירת קשר',
                                        en: 'Parent & Contact',
                                      ),
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: const Color(0xFF6D7A77),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      trByLang(langCode, ar: 'المسار المعتمد', he: 'מסלול לימוד', en: 'Assigned Track'),
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: const Color(0xFF6D7A77),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      trByLang(
                                        langCode,
                                        ar: 'مواعيد الحلقة الجماعية',
                                        he: 'לו״ז קבוצתי',
                                        en: 'Group Schedule',
                                      ),
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: const Color(0xFF6D7A77),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      trByLang(
                                        langCode,
                                        ar: 'الموعد الفردي (1-on-1)',
                                        he: 'מועד אישי (1-on-1)',
                                        en: '1-on-1 Slot',
                                      ),
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: const Color(0xFF6D7A77),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      trByLang(langCode, ar: 'الإجراءات', he: 'פעולות', en: 'Actions'),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: const Color(0xFF6D7A77),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Roster Table Rows
                            ...rosterRows.map((row) {
                              final isSelectedInDrawer = row.id == _selectedStudentId;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedStudentId = row.id;
                                    _selectedStudentName = row.fullName;
                                    _selectedStudentCode = row.code;
                                    _isEnrollDrawerOpen = true;
                                  });
                                },
                                child: Container(
                                  color: (row.isHighlighted || isSelectedInDrawer)
                                      ? DarAlFajrTheme.primary.withValues(alpha: 0.05)
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  child: Row(
                                    children: [
                                      // Column 1: Student Name & ID
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: (row.isHighlighted || isSelectedInDrawer)
                                                    ? DarAlFajrTheme.primary
                                                    : const Color(0xFFE6E8EA),
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                row.initial,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  color: (row.isHighlighted || isSelectedInDrawer)
                                                      ? Colors.white
                                                      : const Color(0xFF191C1E),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    row.fullName,
                                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(0xFF191C1E),
                                                    ),
                                                  ),
                                                  Text(
                                                    row.code,
                                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                      color: (row.isHighlighted || isSelectedInDrawer)
                                                          ? DarAlFajrTheme.primary
                                                          : const Color(0xFF6D7A77),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Column 2: Parent & Contact
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              row.parentName,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF191C1E),
                                              ),
                                            ),
                                            Text(
                                              row.parentEmail,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelSmall?.copyWith(color: const Color(0xFF6D7A77)),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Column 3: Assigned Track Badges
                                      Expanded(
                                        flex: 2,
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: row.trackBadges
                                              .map(
                                                (b) => Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: b.backgroundColor,
                                                    borderRadius: BorderRadius.circular(999),
                                                  ),
                                                  child: Text(
                                                    b.label,
                                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                      color: b.textColor,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),

                                      // Column 4: Group Schedule
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          children: [
                                            const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF6D7A77)),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                row.groupSchedule,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF191C1E)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Column 5: 1-on-1 Individual Slot
                                      Expanded(
                                        flex: 2,
                                        child: row.oneOnOneSchedule != null
                                            ? Align(
                                                alignment: AlignmentDirectional.centerStart,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: DarAlFajrTheme.accent.withValues(alpha: 0.16),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.stars_rounded,
                                                        size: 14,
                                                        color: Color(0xFF904D00),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Flexible(
                                                        child: Text(
                                                          row.oneOnOneSchedule!,
                                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                            color: const Color(0xFF904D00),
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                '—',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.labelMedium?.copyWith(color: const Color(0xFF6D7A77)),
                                              ),
                                      ),

                                      // Column 6: Actions
                                      SizedBox(
                                        width: 100,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              visualDensity: VisualDensity.compact,
                                              padding: const EdgeInsets.all(4),
                                              constraints: const BoxConstraints(),
                                              onPressed: () {
                                                setState(() {
                                                  _selectedStudentId = row.id;
                                                  _selectedStudentName = row.fullName;
                                                  _selectedStudentCode = row.code;
                                                  _isEnrollDrawerOpen = true;
                                                });
                                              },
                                              icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF3D4947)),
                                            ),
                                            const SizedBox(width: 4),
                                            IconButton(
                                              visualDensity: VisualDensity.compact,
                                              padding: const EdgeInsets.all(4),
                                              constraints: const BoxConstraints(),
                                              onPressed: row.isFromFirestore
                                                  ? () => ref.read(adminRepositoryProvider).deleteStudent(row.id)
                                                  : null,
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 18,
                                                color: Color(0xFF3D4947),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                    // Pagination Footer
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6D7A77)),
                              children: [
                                TextSpan(
                                  text: trByLang(langCode, ar: 'عرض ', he: 'מציג ', en: 'Showing '),
                                ),
                                TextSpan(
                                  text: '1 - ${rosterRows.length}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF191C1E)),
                                ),
                                TextSpan(
                                  text: trByLang(langCode, ar: ' من أصل ', he: ' מתוך ', en: ' of '),
                                ),
                                TextSpan(
                                  text: '$totalStudentsCount',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF191C1E)),
                                ),
                                TextSpan(
                                  text: trByLang(langCode, ar: ' طالب', he: ' תלמידים', en: ' students'),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _PaginationButton(label: '', icon: Icons.chevron_left_rounded, onTap: () {}),
                              const SizedBox(width: 4),
                              _PaginationButton(label: '1', isSelected: true, onTap: () {}),
                              const SizedBox(width: 4),
                              _PaginationButton(label: '2', onTap: () {}),
                              const SizedBox(width: 4),
                              _PaginationButton(label: '3', onTap: () {}),
                              const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('...')),
                              _PaginationButton(label: '42', onTap: () {}),
                              const SizedBox(width: 4),
                              _PaginationButton(label: '', icon: Icons.chevron_right_rounded, onTap: () {}),
                            ],
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
      ],
    );
  }

  Widget _buildUsersTab(BuildContext context, String langCode, List<AppUser> users) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إدارة المستخدمين والأدوار',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'عرض حسابات المعلمين وأولياء الأمور والطلاب والمشرفين',
                  style: TextStyle(color: Color(0xFF6D7A77)),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddStudentOrUserDialog(langCode),
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('+ إضافة مستخدم جديد'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (users.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: DarAlFajrTheme.surface, borderRadius: BorderRadius.circular(12)),
            child: const Center(
              child: Text(
                'لا يوجد مستخدمون حالياً في قاعدة البيانات. يمكنك استخدام زر "تهيئة الحسابات (Dev Seed)" في شاشة الدخول لإضافتهم فوراً.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6D7A77)),
              ),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final u = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: DarAlFajrTheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      u.fullName.isNotEmpty ? u.fullName[0] : 'U',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${u.email} • ${u.phoneNumber ?? "بدون هاتف"}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: u.role == UserRole.admin
                          ? Colors.purple.withValues(alpha: 0.15)
                          : (u.role == UserRole.teacher
                                ? DarAlFajrTheme.primary.withValues(alpha: 0.15)
                                : Colors.amber.withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      u.role.name.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: u.role == UserRole.admin
                            ? Colors.purple
                            : (u.role == UserRole.teacher ? DarAlFajrTheme.primary : Colors.amber.shade900),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildGroupsTab(
    BuildContext context,
    String langCode,
    List<StudyGroup> groups,
    List<Enrollment> enrollments,
  ) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trByLang(
                    langCode,
                    ar: 'الحلقات والمجموعات التعليمية',
                    he: 'קבוצות לימוד',
                    en: 'Study Groups & Circles',
                  ),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  trByLang(
                    langCode,
                    ar: 'إدارة الحلقات عبر المسارات الأربعة وتعيين الشيوخ والمعلمين',
                    he: 'ניהול קבוצות בארבעת המסלולים ושיבוץ מורים',
                    en: 'Manage study groups across the four tracks and assign teachers',
                  ),
                  style: const TextStyle(color: Color(0xFF6D7A77)),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showCreateGroupDialog(langCode),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: Text(
                trByLang(
                  langCode,
                  ar: '+ إنشاء حلقة جديدة',
                  he: '+ קבוצה חדשה',
                  en: '+ Create Group',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (groups.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: DarAlFajrTheme.surface, borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                trByLang(
                  langCode,
                  ar: 'لا توجد حلقات حالياً. اضغط على "+ إنشاء حلقة جديدة".',
                  he: 'אין קבוצות כרגע. לחץ על "+ קבוצה חדשה".',
                  en: 'No study groups yet. Click "+ Create Group".',
                ),
                style: const TextStyle(color: Color(0xFF6D7A77)),
              ),
            ),
          )
        else
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: groups.map((g) {
              final enrolledCount = enrollments.where((e) => e.groupId == g.id).length;
              return Container(
                width: 340,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DarAlFajrTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: DarAlFajrTheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                g.track.localizedName(langCode),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: DarAlFajrTheme.primaryDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4F2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '$enrolledCount / ${g.capacity} ${trByLang(langCode, ar: 'مقعد', he: 'מקומות', en: 'seats')}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3D4947),
                                ),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => ref.read(adminRepositoryProvider).deleteGroup(g.id),
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFF6D7A77)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(g.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_rounded, size: 16, color: Color(0xFF6D7A77)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            g.teacherName.isNotEmpty ? g.teacherName : (_isDemoFallback ? 'الشيخ عبد الرحمن' : '—'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF6D7A77)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${g.scheduleDays.join("، ")} • ${g.startTime} - ${g.endTime}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEnrollmentsTab(BuildContext context, String langCode, List<Enrollment> enrollments) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التسجيل والمواعيد الفردية (1-on-1)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'تتبع مواعيد الحضور الفردية وجداول الحلقات لكل طالب',
                  style: TextStyle(color: Color(0xFF6D7A77)),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _isEnrollDrawerOpen = true);
              },
              icon: const Icon(Icons.group_add_rounded, size: 18),
              label: const Text('+ تسجيل جديد في حلقة'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: enrollments.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('لا توجد تسجيلات حالياً.')),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: enrollments.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final e = enrollments[idx];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.how_to_reg_rounded)),
                      title: Text(e.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${e.groupName} • ${e.groupArrivalTime ?? "ميعاد عام"}'),
                      trailing: e.oneOnOneSlotTime != null
                          ? Chip(avatar: const Icon(Icons.stars_rounded, size: 16), label: Text(e.oneOnOneSlotTime!))
                          : const Text('بدون موعد فردي'),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAttendanceTab(BuildContext context, String langCode, List<StudyGroup> groups) {
    final liveLogs = ref.watch(adminAttendanceLogsProvider).asData?.value ?? const <AttendanceLog>[];
    final isDemoMode = _isDemoFallback;
    final now = DateTime.now();
    final logs = liveLogs.isNotEmpty
        ? liveLogs
        : (isDemoMode
            ? [
                AttendanceLog(
                  id: 'demo-log-1',
                  groupId: 'grp-hifz-1',
                  studentId: 'st-1042',
                  studentName: 'إبراهيم طه عثمان',
                  teacherId: 't-1',
                  sessionDate: now,
                  sessionMode: SessionMode.group,
                  status: AttendanceStatus.present,
                ),
                AttendanceLog(
                  id: 'demo-log-2',
                  groupId: 'grp-tajweed-1',
                  studentId: 'st-1049',
                  studentName: 'ياسين أحمد علي',
                  teacherId: 't-1',
                  sessionDate: now,
                  sessionMode: SessionMode.oneOnOne,
                  status: AttendanceStatus.late,
                  notes: trByLang(langCode, ar: 'تأخر 10 دقائق', he: 'איחור של 10 דקות', en: '10 mins late'),
                ),
                AttendanceLog(
                  id: 'demo-log-3',
                  groupId: 'grp-qaidah-1',
                  studentId: 'st-1055',
                  studentName: 'أحمد سامي خالد',
                  teacherId: 't-2',
                  sessionDate: now.subtract(const Duration(days: 1)),
                  sessionMode: SessionMode.group,
                  status: AttendanceStatus.absent,
                ),
              ]
            : const <AttendanceLog>[]);

    final groupNameById = <String, String>{
      for (final g in groups) g.id: g.name,
    };

    final presentCount = logs.where((l) => l.status == AttendanceStatus.present).length;
    final lateCount = logs.where((l) => l.status == AttendanceStatus.late).length;
    final absentCount = logs.where((l) => l.status == AttendanceStatus.absent).length;
    final attendanceRate = logs.isNotEmpty ? (((presentCount + lateCount) / logs.length) * 100).round() : 0;

    final filteredLogs = logs.where((l) {
      if (_auditGroupFilter != null && l.groupId != _auditGroupFilter) return false;
      if (_auditStatusFilter != null && l.status != _auditStatusFilter) return false;
      return true;
    }).toList();

    final uniqueGroupIds = logs.map((l) => l.groupId).toSet().toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trByLang(
                langCode,
                ar: 'سجل الحضور والغياب (Attendance Audit)',
                he: 'ביקורת נוכחות והיעדרויות',
                en: 'Attendance Audit',
              ),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              trByLang(
                langCode,
                ar: 'متابعة سجلات حضور المعلمين للحلقات والجلسات الفردية بشكل مباشر',
                he: 'מעקב בזמן אמת אחר רישומי הנוכחות של המורים',
                en: 'Live audit of teacher attendance records for group and 1-on-1 sessions',
              ),
              style: const TextStyle(color: Color(0xFF6D7A77)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildAuditStatChip(
              label: trByLang(langCode, ar: 'إجمالي السجلات', he: 'סה״כ רשומות', en: 'Total Logs'),
              value: '${logs.length}',
              color: DarAlFajrTheme.primary,
            ),
            _buildAuditStatChip(
              label: trByLang(langCode, ar: 'نسبة الحضور', he: 'אחוז נוכחות', en: 'Attendance Rate'),
              value: '$attendanceRate%',
              color: const Color(0xFF1E6661),
            ),
            _buildAuditStatChip(
              label: AttendanceStatus.present.localizedName(langCode),
              value: '$presentCount',
              color: Colors.green.shade700,
            ),
            _buildAuditStatChip(
              label: AttendanceStatus.late.localizedName(langCode),
              value: '$lateCount',
              color: Colors.orange.shade800,
            ),
            _buildAuditStatChip(
              label: AttendanceStatus.absent.localizedName(langCode),
              value: '$absentCount',
              color: Colors.red.shade700,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 240,
              child: DropdownButtonFormField<String?>(
                initialValue: _auditGroupFilter != null && uniqueGroupIds.contains(_auditGroupFilter)
                    ? _auditGroupFilter
                    : null,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: trByLang(langCode, ar: 'تصفية حسب الحلقة', he: 'סינון לפי קבוצה', en: 'Filter by Group'),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(trByLang(langCode, ar: 'كل الحلقات', he: 'כל הקבוצות', en: 'All Groups')),
                  ),
                  ...uniqueGroupIds.map(
                    (gid) => DropdownMenuItem<String?>(
                      value: gid,
                      child: Text(groupNameById[gid] ?? gid, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (val) => setState(() => _auditGroupFilter = val),
              ),
            ),
            ChoiceChip(
              label: Text(trByLang(langCode, ar: 'الكل', he: 'הכל', en: 'All')),
              selected: _auditStatusFilter == null,
              onSelected: (_) => setState(() => _auditStatusFilter = null),
            ),
            ...AttendanceStatus.values.map(
              (status) => ChoiceChip(
                label: Text(status.localizedName(langCode)),
                selected: _auditStatusFilter == status,
                onSelected: (_) => setState(() {
                  _auditStatusFilter = _auditStatusFilter == status ? null : status;
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: filteredLogs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      trByLang(
                        langCode,
                        ar: 'لا توجد سجلات حضور مطابقة حالياً.',
                        he: 'אין רשומות נוכחות תואמות כרגע.',
                        en: 'No matching attendance logs found.',
                      ),
                      style: const TextStyle(color: Color(0xFF6D7A77)),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredLogs.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final log = filteredLogs[idx];
                    final statusColor = switch (log.status) {
                      AttendanceStatus.present => Colors.green.shade700,
                      AttendanceStatus.late => Colors.orange.shade800,
                      AttendanceStatus.absent => Colors.red.shade700,
                      AttendanceStatus.excused => Colors.blue.shade700,
                    };
                    final statusIcon = switch (log.status) {
                      AttendanceStatus.present => Icons.check_circle_rounded,
                      AttendanceStatus.late => Icons.access_time_filled_rounded,
                      AttendanceStatus.absent => Icons.cancel_rounded,
                      AttendanceStatus.excused => Icons.event_available_rounded,
                    };
                    final groupLabel = groupNameById[log.groupId] ?? log.groupId;
                    final dateStr =
                        '${log.sessionDate.year}-${log.sessionDate.month.toString().padLeft(2, '0')}-${log.sessionDate.day.toString().padLeft(2, '0')}';
                    final modeLabel = log.sessionMode == SessionMode.oneOnOne
                        ? trByLang(langCode, ar: 'فردي', he: 'אישי', en: '1-on-1')
                        : trByLang(langCode, ar: 'جماعي', he: 'קבוצתי', en: 'Group');

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withValues(alpha: 0.12),
                        child: Icon(
                          statusIcon,
                          color: statusColor,
                        ),
                      ),
                      title: Text(
                        log.studentName.isNotEmpty ? log.studentName : log.studentId,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '$groupLabel • $modeLabel • $dateStr${log.notes != null && log.notes!.isNotEmpty ? ' — ${log.notes}' : ''}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          log.status.localizedName(langCode),
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAuditStatChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: DarAlFajrTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF3D4947))),
        ],
      ),
    );
  }

  Widget _buildReportsTab(
    BuildContext context,
    String langCode,
    List<StudentProfile> students,
    List<StudyGroup> groups,
    List<Enrollment> enrollments,
  ) {
    final logs = ref.watch(adminAttendanceLogsProvider).asData?.value ?? const <AttendanceLog>[];
    final assignments = ref.watch(adminHifzAssignmentsProvider).asData?.value ?? const <HifzAssignment>[];
    final isDemoMode = _isDemoFallback;

    final totalPagesMemorized = isDemoMode
        ? 134
        : students.fold<int>(0, (sum, s) => sum + s.memorizedCenterPagesCount);
    final totalCompletedSurahs = isDemoMode
        ? 42
        : students.fold<int>(0, (sum, s) => sum + s.completedSurahs.length);

    final attendancePercent = logs.isNotEmpty
        ? (((logs.where((l) => l.status == AttendanceStatus.present || l.status == AttendanceStatus.late).length) /
                    logs.length) *
                100)
            .round()
        : (isDemoMode ? 94 : 0);

    final gradedAssignments = assignments.where((a) => a.grade != EvaluationGrade.pending).toList();
    final passedAssignments = gradedAssignments
        .where((a) => a.grade == EvaluationGrade.excellent || a.grade == EvaluationGrade.good)
        .length;
    final masteryPercent = gradedAssignments.isNotEmpty
        ? ((passedAssignments / gradedAssignments.length) * 100).round()
        : (isDemoMode ? 88 : 0);

    final trackCounts = <CenterTrack, int>{
      for (final track in CenterTrack.values)
        track: isDemoMode
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
            _buildReportKpiTile(
              title: trByLang(langCode, ar: 'متوسط الحضور العام', he: 'נוכחות כללית', en: 'Overall Attendance'),
              value: '$attendancePercent%',
              subtitle: isDemoMode
                  ? trByLang(langCode, ar: 'بيانات تجريبية', he: 'נתוני הדגמה', en: 'Demo sample')
                  : '${logs.length} ${trByLang(langCode, ar: 'سجل', he: 'רשומות', en: 'logs')}',
              color: Colors.green.shade700,
              icon: Icons.fact_check_rounded,
            ),
            _buildReportKpiTile(
              title: trByLang(langCode, ar: 'إجمالي الصفحات المحفوظة', he: 'עמודים שנלמדו', en: 'Memorized Pages'),
              value: '$totalPagesMemorized',
              subtitle: '$totalCompletedSurahs ${trByLang(langCode, ar: 'سورة مكتملة', he: 'סורות שהושלמו', en: 'completed surahs')}',
              color: DarAlFajrTheme.primary,
              icon: Icons.menu_book_rounded,
            ),
            _buildReportKpiTile(
              title: trByLang(langCode, ar: 'نسبة الإتقان الأسبوعي', he: 'אחוז הצלחה שבועי', en: 'Weekly Mastery Rate'),
              value: '$masteryPercent%',
              subtitle: '${assignments.length} ${trByLang(langCode, ar: 'تكليف', he: 'משימות', en: 'assignments')}',
              color: DarAlFajrTheme.accent,
              icon: Icons.stars_rounded,
            ),
            _buildReportKpiTile(
              title: trByLang(langCode, ar: 'الحلقات والمسارات', he: 'קבוצות ומסלולים', en: 'Active Circles'),
              value: '${isDemoMode ? 3 : groups.length}',
              subtitle: '${isDemoMode ? 6 : enrollments.length} ${trByLang(langCode, ar: 'تسجيل', he: 'רישומים', en: 'enrollments')}',
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

  Widget _buildReportKpiTile({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
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

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarNavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? DarAlFajrTheme.primaryDark : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : const Color(0xFF89F5E7)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected ? Colors.white : const Color(0xFF89F5E7),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

class _StatSummaryCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color accentColor;

  const _StatSummaryCard({
    required this.width,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.clamp(200, 420),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DarAlFajrTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF6D7A77))),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF191C1E)),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        unit,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: accentColor, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 26, color: accentColor),
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? DarAlFajrTheme.primary : const Color(0xFFECEEF0),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF3D4947),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaginationButton({required this.label, this.icon, this.isSelected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? DarAlFajrTheme.primary : const Color(0xFFECEEF0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: icon != null
            ? Icon(icon, size: 18, color: isSelected ? Colors.white : const Color(0xFF191C1E))
            : Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected ? Colors.white : const Color(0xFF191C1E),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
