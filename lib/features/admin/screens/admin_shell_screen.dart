import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';

import '../../../core/services/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/admin_models.dart';
import '../providers/admin_providers.dart';
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
  String _selectedStudentName = 'إبراهيم طه عثمان';
  String _selectedStudentCode = '#ST-1042';
  String _selectedStudentId = 'st-1042';
  CenterTrack _selectedTargetTrack = CenterTrack.readingTajweed;
  String _selectedGroupLabel = 'حلقة الإتقان والتجويد (مسار التجويد المتقدم)';
  String _selectedGroupId = 'grp-tajweed-1';
  bool _hasOneOnOneSlot = true;
  String _selectedOneOnOneDay = 'الخميس';
  String _selectedOneOnOneTime = '17:15';

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

  String _tr(String langCode, {required String ar, required String he, required String en}) {
    switch (langCode) {
      case 'he':
        return he;
      case 'en':
        return en;
      case 'ar':
      default:
        return ar;
    }
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
    final slotString = _hasOneOnOneSlot ? '$_selectedOneOnOneDay $_selectedOneOnOneTime (فردي)' : null;

    await ref
        .read(adminControllerProvider.notifier)
        .assignStudentToGroup(
          studentId: _selectedStudentId,
          studentName: _selectedStudentName,
          groupId: _selectedGroupId,
          groupName: _selectedGroupLabel,
          track: _selectedTargetTrack,
          oneOnOneSlotTime: slotString,
          groupArrivalTime: 'الأحد والثلاثاء والخميس 16:30',
        );

    if (!mounted) return;
    setState(() {
      _isEnrollDrawerOpen = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _tr(
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
                _tr(
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
                          labelText: _tr(langCode, ar: 'نوع الحساب', he: 'סוג חשבון', en: 'Account Role'),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: UserRole.student,
                            child: Text(_tr(langCode, ar: 'طالب (Student)', he: 'תלמיד', en: 'Student')),
                          ),
                          DropdownMenuItem(
                            value: UserRole.parent,
                            child: Text(_tr(langCode, ar: 'ولي أمر (Parent)', he: 'הורה', en: 'Parent')),
                          ),
                          DropdownMenuItem(
                            value: UserRole.teacher,
                            child: Text(_tr(langCode, ar: 'معلم / شيخ (Teacher)', he: 'מורה', en: 'Teacher')),
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
                          labelText: _tr(langCode, ar: 'الاسم الكامل *', he: 'שם מלא *', en: 'Full Name *'),
                        ),
                      ),
                      if (selectedRole == UserRole.student) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: parentNameController,
                          decoration: InputDecoration(
                            labelText: _tr(langCode, ar: 'اسم ولي الأمر *', he: 'שם ההורה *', en: 'Parent Name *'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: _tr(langCode, ar: 'البريد الإلكتروني', he: 'דוא״ל', en: 'Email Address'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: tempPasswordController,
                        decoration: InputDecoration(
                          labelText: _tr(
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
                          labelText: _tr(langCode, ar: 'رقم الهاتف', he: 'מספר טלפון', en: 'Phone Number'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(_tr(langCode, ar: 'إلغاء', he: 'ביטול', en: 'Cancel')),
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
                          _tr(langCode, ar: 'تمت الإضافة بنجاح!', he: 'נוסף בהצלחה!', en: 'Created successfully!'),
                        ),
                        backgroundColor: DarAlFajrTheme.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(_tr(langCode, ar: 'حفظ وإضافة', he: 'שמור', en: 'Save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateGroupDialog(String langCode) {
    final nameController = TextEditingController();
    CenterTrack selectedTrack = CenterTrack.hifz;
    final timeController = TextEditingController(text: '17:00');
    final teacherController = TextEditingController(text: 'الشيخ عبد الرحمن');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('إنشاء حلقة جديدة'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'اسم الحلقة *'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<CenterTrack>(
                      initialValue: selectedTrack,
                      decoration: const InputDecoration(labelText: 'المسار التعليمي'),
                      items: CenterTrack.values
                          .map((t) => DropdownMenuItem(value: t, child: Text(t.localizedName(langCode))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedTrack = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: teacherController,
                      decoration: const InputDecoration(labelText: 'اسم الشيخ / المعلم'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(labelText: 'وقت البدء (مثال: 17:00)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    Navigator.of(dialogContext).pop();
                    await ref
                        .read(adminControllerProvider.notifier)
                        .createGroup(
                          name: nameController.text.trim(),
                          track: selectedTrack,
                          teacherId: 'teacher-1',
                          teacherName: teacherController.text.trim(),
                          scheduleDays: ['السبت', 'الاثنين'],
                          startTime: timeController.text.trim(),
                          endTime: '18:30',
                        );
                    if (!mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('تم إنشاء الحلقة بنجاح!'), backgroundColor: DarAlFajrTheme.primary),
                    );
                  },
                  child: const Text('حفظ الحلقة'),
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
        groupSchedule: primaryEnrollment?.groupArrivalTime ?? 'الأحد والثلاثاء والخميس 16:30',
        oneOnOneSchedule: primaryEnrollment?.oneOnOneSlotTime,
        isFromFirestore: true,
      );
    }).toList();

    final combined = [...mappedFirestore, ..._seedRosterRows];

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

    final totalStudentsCount = firestoreStudents.isNotEmpty ? firestoreStudents.length : 6;
    final totalGroupsCount = firestoreGroups.isNotEmpty ? firestoreGroups.length : 3;
    final totalOneOnOneCount = firestoreEnrollments.isNotEmpty
        ? firestoreEnrollments.where((e) => e.oneOnOneSlotTime != null && e.oneOnOneSlotTime!.isNotEmpty).length
        : 3;

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
                                          _tr(langCode, ar: 'دار الفجر', he: 'דאר אל-פג׳ר', en: 'Dar al-Fajr'),
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          _tr(
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
                                    label: _tr(langCode, ar: 'المستخدمين', he: 'משתמשים', en: 'Users'),
                                    isSelected: selectedTab == 0,
                                    onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(0),
                                  ),
                                  const SizedBox(height: 4),
                                  _SidebarNavItem(
                                    icon: Icons.school_rounded,
                                    label: _tr(langCode, ar: 'الطلاب', he: 'תלמידים', en: 'Students'),
                                    isSelected: selectedTab == 1,
                                    onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(1),
                                  ),
                                  const SizedBox(height: 4),
                                  _SidebarNavItem(
                                    icon: Icons.diversity_3_rounded,
                                    label: _tr(
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
                                    label: _tr(
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
                                    label: _tr(langCode, ar: 'سجل الحضور', he: 'יומן נוכחות', en: 'Attendance Logs'),
                                    isSelected: selectedTab == 4,
                                    onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(4),
                                  ),
                                  const SizedBox(height: 4),
                                  _SidebarNavItem(
                                    icon: Icons.monitor_rounded,
                                    label: _tr(
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
                                                  : _tr(
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
                                  tooltip: _tr(langCode, ar: 'تسجيل الخروج', he: 'התנתק', en: 'Logout'),
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
                                        hintText: _tr(
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
                                      _tr(
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
                                      _tr(langCode, ar: '+ إضافة طالب', he: '+ הוסף תלמיד', en: '+ Add Student'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: () => context.push(AppRoutes.account),
                                    borderRadius: BorderRadius.circular(18),
                                    child: Tooltip(
                                      message: _tr(langCode, ar: 'حسابي', he: 'החשבון שלי', en: 'My Account'),
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
                                              _tr(
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
                                          _tr(
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
                                        _tr(langCode, ar: 'اختيار الطالب', he: 'בחירת תלמיד', en: 'Select Student'),
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
                                        _tr(
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
                                    itemBuilder: (context) => const [
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
                                    ],
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
                                                    _tr(
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
                                                    _tr(
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
                                                      _tr(
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
                                                      _tr(
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
                                                  child: Text(
                                                    _tr(
                                                      langCode,
                                                      ar: 'المدة: 30 دقيقة - مع الشيخ عبد الرحمن',
                                                      he: 'משך: 30 דקות - עם השייח׳ עבד א-רחמן',
                                                      en: 'Duration: 30 mins - with Sheikh Abdul Rahman',
                                                    ),
                                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                      color: const Color(0xFF904D00),
                                                      fontWeight: FontWeight.w600,
                                                    ),
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
                                      _tr(
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
                                      _tr(langCode, ar: 'إلغاء الأمر', he: 'ביטול', en: 'Cancel'),
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
        return _buildGroupsTab(context, langCode, firestoreGroups);
      case 3:
        return _buildEnrollmentsTab(context, langCode, firestoreEnrollments);
      case 4:
        return _buildAttendanceTab(context, langCode);
      case 5:
        return _buildReportsTab(context, langCode);
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
                        hintText: _tr(
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
                    label: Text(_tr(langCode, ar: '+ إضافة طالب', he: '+ הוסף תלמיד', en: '+ Add Student')),
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
                    label: Text(_tr(langCode, ar: '+ تسجيل في حلقة', he: '+ רישום לקבוצה', en: '+ Enroll in Group')),
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
                        title: _tr(
                          langCode,
                          ar: 'إجمالي الطلاب المسجلين',
                          he: 'סה״כ תלמידים רשומים',
                          en: 'Total Enrolled Students',
                        ),
                        value: '$totalStudentsCount',
                        unit: _tr(langCode, ar: 'طالب نشط', he: 'תלמיד פעיל', en: 'Active students'),
                        icon: Icons.school_rounded,
                        accentColor: DarAlFajrTheme.primary,
                      ),
                      _StatSummaryCard(
                        width: (constraints.maxWidth - 48) / 4,
                        title: _tr(langCode, ar: 'الحلقات الفعالة', he: 'קבוצות פעילות', en: 'Active Groups'),
                        value: '$totalGroupsCount',
                        unit: _tr(langCode, ar: 'حلقة ومقرأة', he: 'קבוצות לימוד', en: 'Study circles'),
                        icon: Icons.groups_rounded,
                        accentColor: DarAlFajrTheme.primary,
                      ),
                      _StatSummaryCard(
                        width: (constraints.maxWidth - 48) / 4,
                        title: _tr(
                          langCode,
                          ar: 'الجلسات الفردية المجدولة',
                          he: 'מפגשים אישיים מתוזמנים',
                          en: 'Scheduled 1-on-1 Slots',
                        ),
                        value: '$totalOneOnOneCount',
                        unit: _tr(langCode, ar: 'موعد أسبوعي', he: 'מפגש שבועי', en: 'Weekly slots'),
                        icon: Icons.record_voice_over_rounded,
                        accentColor: DarAlFajrTheme.accent,
                      ),
                      _StatSummaryCard(
                        width: (constraints.maxWidth - 48) / 4,
                        title: _tr(langCode, ar: 'المقاعد المتاحة', he: 'מקומות פנויים', en: 'Available Seats'),
                        value: '18',
                        unit: _tr(langCode, ar: 'مقعد متاح', he: 'מקום פנוי', en: 'Open seats'),
                        icon: Icons.event_seat_rounded,
                        accentColor: const Color(0xFF3D4947),
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
                                    _tr(
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
                                    _tr(
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
                                label: _tr(
                                  langCode,
                                  ar: 'الكل ($totalStudentsCount)',
                                  he: 'הכל ($totalStudentsCount)',
                                  en: 'All ($totalStudentsCount)',
                                ),
                                isSelected: selectedTrackFilter == null,
                                onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(null),
                              ),
                              _FilterChipButton(
                                label: _tr(langCode, ar: 'مسار الحفظ', he: 'מסלול חיפז', en: 'Hifz'),
                                isSelected: selectedTrackFilter == CenterTrack.hifz,
                                onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.hifz),
                              ),
                              _FilterChipButton(
                                label: _tr(langCode, ar: 'النورانية', he: 'נוראניה', en: 'Nouraniah'),
                                isSelected: selectedTrackFilter == CenterTrack.qaidahNouraniah,
                                onTap: () =>
                                    ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.qaidahNouraniah),
                              ),
                              _FilterChipButton(
                                label: _tr(langCode, ar: 'التجويد', he: 'טג׳וויד', en: 'Tajweed'),
                                isSelected: selectedTrackFilter == CenterTrack.readingTajweed,
                                onTap: () =>
                                    ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.readingTajweed),
                              ),
                              _FilterChipButton(
                                label: _tr(langCode, ar: 'التربوي', he: 'חינוכי', en: 'Tarbawi'),
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
                                label: Text(_tr(langCode, ar: 'تصدير Excel', he: 'ייצוא Excel', en: 'Export Excel')),
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
                                      _tr(
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
                                      _tr(
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
                                      _tr(langCode, ar: 'المسار المعتمد', he: 'מסלול לימוד', en: 'Assigned Track'),
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: const Color(0xFF6D7A77),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _tr(
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
                                      _tr(
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
                                      _tr(langCode, ar: 'الإجراءات', he: 'פעולות', en: 'Actions'),
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
                                  text: _tr(langCode, ar: 'عرض ', he: 'מציג ', en: 'Showing '),
                                ),
                                TextSpan(
                                  text: '1 - ${rosterRows.length}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF191C1E)),
                                ),
                                TextSpan(
                                  text: _tr(langCode, ar: ' من أصل ', he: ' מתוך ', en: ' of '),
                                ),
                                TextSpan(
                                  text: '$totalStudentsCount',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF191C1E)),
                                ),
                                TextSpan(
                                  text: _tr(langCode, ar: ' طالب', he: ' תלמידים', en: ' students'),
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

  Widget _buildGroupsTab(BuildContext context, String langCode, List<StudyGroup> groups) {
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
                  'الحلقات والمجموعات التعليمية',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'إدارة الحلقات عبر المسارات الأربعة وتعيين الشيوخ والمعلمين',
                  style: TextStyle(color: Color(0xFF6D7A77)),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showCreateGroupDialog(langCode),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text('+ إنشاء حلقة جديدة'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (groups.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: DarAlFajrTheme.surface, borderRadius: BorderRadius.circular(12)),
            child: const Center(
              child: Text(
                'لا توجد حلقات حالياً. اضغط على "+ إنشاء حلقة جديدة" أو استخدم Dev Seed.',
                style: TextStyle(color: Color(0xFF6D7A77)),
              ),
            ),
          )
        else
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: groups.map((g) {
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
                        Text(g.teacherName.isNotEmpty ? g.teacherName : 'الشيخ عبد الرحمن'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF6D7A77)),
                        const SizedBox(width: 4),
                        Text('${g.scheduleDays.join("، ")} • ${g.startTime} - ${g.endTime}'),
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

  Widget _buildAttendanceTab(BuildContext context, String langCode) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fact_check_rounded, size: 56, color: DarAlFajrTheme.primary),
          const SizedBox(height: 12),
          Text(
            'سجل الحضور والغياب (Attendance Audit)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'يتم تسجيل الحضور مباشرة من قبل المعلمين في المرحلة 4.',
            style: TextStyle(color: Color(0xFF6D7A77)),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab(BuildContext context, String langCode) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monitor_rounded, size: 56, color: DarAlFajrTheme.accent),
          const SizedBox(height: 12),
          Text(
            'التقارير والإحصائيات الأكاديمية',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('لوحة مؤشرات الإنجاز، الصفحات المحفوظة، ونسب الحضور.', style: TextStyle(color: Color(0xFF6D7A77))),
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
