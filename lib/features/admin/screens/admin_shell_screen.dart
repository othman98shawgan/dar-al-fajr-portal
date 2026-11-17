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
import '../widgets/admin_attendance_audit_tab.dart';
import '../widgets/admin_dialogs.dart';
import '../widgets/admin_enrollment_drawer.dart';
import '../widgets/admin_groups_users_tabs.dart';
import '../widgets/admin_reports_analytics_tab.dart';
import '../widgets/admin_shell_models.dart';
import '../widgets/admin_students_tab.dart';
import 'admin_mobile_screen.dart';

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

  bool _hasQaidahTajweedConflict(List<AdminRosterRowData> rows) {
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

    final enrollments = ref.read(adminEnrollmentsProvider).asData?.value ?? const [];
    final isDuplicate = enrollments.any(
      (e) => e.studentId == _selectedStudentId && e.groupId == _selectedGroupId,
    );
    if (isDuplicate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            trByLang(
              langCode,
              ar: 'الطالب مسجل بالفعل في هذه الحلقة',
              he: 'התלמיד כבר רשום לקבוצה זו',
              en: 'Student is already enrolled in this group',
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
        ? matchedGroup.formatScheduleSummary(langCode)
        : (_isDemoFallback ? 'الأحد والثلاثاء والخميس 16:30' : '');

    final created = await ref.read(adminControllerProvider.notifier).assignStudentToGroup(
          studentId: _selectedStudentId,
          studentName: _selectedStudentName,
          groupId: _selectedGroupId,
          groupName: _selectedGroupLabel,
          track: _selectedTargetTrack,
          oneOnOneSlotTime: slotString,
          groupArrivalTime: arrivalTime,
        );

    if (!mounted) return;
    if (created == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            trByLang(
              langCode,
              ar: 'تعذر حفظ التسجيل — قد يكون الطالب مسجلاً بالفعل في هذه الحلقة',
              he: 'לא ניתן לשמור רישום — ייתכן שהתלמיד כבר רשום לקבוצה',
              en: 'Could not save enrollment — student may already be enrolled',
            ),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
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

  List<AdminRosterRowData> _buildRosterRows(
    List<StudentProfile> firestoreStudents,
    List<Enrollment> firestoreEnrollments,
  ) {
    final isDemoMode = _isDemoFallback;
    final mappedFirestore = firestoreStudents.map((student) {
      final studentEnrollments = firestoreEnrollments.where((e) => e.studentId == student.id).toList();
      final primaryEnrollment = studentEnrollments.firstOrNull;
      final track = primaryEnrollment?.track ?? CenterTrack.hifz;
      final trimmedName = student.fullName.trim();
      final initial = trimmedName.isNotEmpty ? trimmedName.characters.first : 'ط';

      return AdminRosterRowData(
        id: student.id,
        code: formatAdminStudentCode(student.id),
        fullName: student.fullName,
        initial: initial,
        parentName: student.parentName ?? 'ولي الأمر',
        parentEmail: student.email ?? student.phoneNumber ?? '—',
        primaryTrack: track,
        trackBadges: [
          TrackBadgeData(
            label: track.localizedName('ar'),
            backgroundColor: const Color(0xFF89F5E7),
            textColor: const Color(0xFF00201D),
          ),
        ],
        groupSchedule: primaryEnrollment?.groupArrivalTime ?? (isDemoMode ? 'الأحد والثلاثاء والخميس 16:30' : ''),
        oneOnOneSchedule: primaryEnrollment?.oneOnOneSlotTime,
        isFromFirestore: true,
      );
    }).toList();

    final combined = isDemoMode ? [...mappedFirestore, ...adminSeedRosterRows] : mappedFirestore;

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
      if (firestoreStudents.isNotEmpty &&
          !firestoreStudents.any((s) => s.id == _selectedStudentId)) {
        final first = firestoreStudents.first;
        _selectedStudentId = first.id;
        _selectedStudentName = first.fullName;
        _selectedStudentCode = formatAdminStudentCode(first.id);
      }
      if (firestoreGroups.isNotEmpty &&
          !firestoreGroups.any((g) => g.id == _selectedGroupId)) {
        final firstGroup = firestoreGroups.first;
        _selectedGroupId = firstGroup.id;
        _selectedGroupLabel = firstGroup.name;
        _selectedTargetTrack = firstGroup.track;
      }
    }
    final totalStudentsCount = firestoreStudents.isNotEmpty ? firestoreStudents.length : (isDemoMode ? 6 : 0);
    final totalGroupsCount = firestoreGroups.isNotEmpty ? firestoreGroups.length : (isDemoMode ? 3 : 0);
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
                                        child: Image.asset('assets/logo.png', fit: BoxFit.contain),
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
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(color: const Color(0xFF89F5E7)),
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    children: [
                                      AdminSidebarNavItem(
                                        icon: Icons.group_rounded,
                                        label: trByLang(langCode, ar: 'المستخدمين', he: 'משתמשים', en: 'Users'),
                                        isSelected: selectedTab == 0,
                                        onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(0),
                                      ),
                                      const SizedBox(height: 4),
                                      AdminSidebarNavItem(
                                        icon: Icons.school_rounded,
                                        label: trByLang(langCode, ar: 'الطلاب', he: 'תלמידים', en: 'Students'),
                                        isSelected: selectedTab == 1,
                                        onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(1),
                                      ),
                                      const SizedBox(height: 4),
                                      AdminSidebarNavItem(
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
                                      AdminSidebarNavItem(
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
                                      AdminSidebarNavItem(
                                        icon: Icons.fact_check_rounded,
                                        label: trByLang(
                                          langCode,
                                          ar: 'سجل الحضور',
                                          he: 'יומן נוכחות',
                                          en: 'Attendance Logs',
                                        ),
                                        isSelected: selectedTab == 4,
                                        onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(4),
                                      ),
                                      const SizedBox(height: 4),
                                      AdminSidebarNavItem(
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
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(color: const Color(0xFF89F5E7)),
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
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => showAdminGradingSettingsDialog(context, ref, langCode),
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
                                        onPressed: () => showAdminAddStudentOrUserDialog(context, ref, langCode),
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
                                langCode: langCode,
                                selectedTab: selectedTab,
                                rosterRows: rosterRows,
                                totalStudentsCount: totalStudentsCount,
                                totalGroupsCount: totalGroupsCount,
                                totalOneOnOneCount: totalOneOnOneCount,
                                selectedTrackFilter: selectedTrackFilter,
                                allUsers: allUsers,
                                firestoreStudents: firestoreStudents,
                                firestoreGroups: firestoreGroups,
                                firestoreEnrollments: firestoreEnrollments,
                                isDemoMode: isDemoMode,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isEnrollDrawerOpen)
                  AdminEnrollmentDrawer(
                    langCode: langCode,
                    rosterRows: rosterRows,
                    selectedStudentId: _selectedStudentId,
                    selectedStudentName: _selectedStudentName,
                    selectedStudentCode: _selectedStudentCode,
                    selectedTargetTrack: _selectedTargetTrack,
                    selectedGroupId: _selectedGroupId,
                    selectedGroupLabel: _selectedGroupLabel,
                    hasOneOnOneSlot: _hasOneOnOneSlot,
                    selectedOneOnOneDay: _selectedOneOnOneDay,
                    selectedOneOnOneTime: _selectedOneOnOneTime,
                    isDemoFallback: isDemoMode,
                    hasQaidahTajweedConflict: _hasQaidahTajweedConflict(rosterRows),
                    isAlreadyEnrolledInGroup: firestoreEnrollments.any(
                      (e) => e.studentId == _selectedStudentId && e.groupId == _selectedGroupId,
                    ),
                    onClose: () => setState(() => _isEnrollDrawerOpen = false),
                    onStudentSelected: (selected) {
                      setState(() {
                        _selectedStudentId = selected.id;
                        _selectedStudentName = selected.fullName;
                        _selectedStudentCode = selected.code;
                      });
                    },
                    onGroupSelected: (track, id, name) {
                      setState(() {
                        _selectedTargetTrack = track;
                        _selectedGroupId = id;
                        _selectedGroupLabel = name;
                      });
                    },
                    onOneOnOneToggled: (val) => setState(() => _hasOneOnOneSlot = val),
                    onOneOnOneDaySelected: (day) => setState(() => _selectedOneOnOneDay = day),
                    onPickOneOnOneTime: _pickOneOnOneTime,
                    onSaveEnrollment: () => _handleSaveEnrollment(langCode),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedTabContent({
    required String langCode,
    required int selectedTab,
    required List<AdminRosterRowData> rosterRows,
    required int totalStudentsCount,
    required int totalGroupsCount,
    required int totalOneOnOneCount,
    required CenterTrack? selectedTrackFilter,
    required List<AppUser> allUsers,
    required List<StudentProfile> firestoreStudents,
    required List<StudyGroup> firestoreGroups,
    required List<Enrollment> firestoreEnrollments,
    required bool isDemoMode,
  }) {
    switch (selectedTab) {
      case 0:
        return AdminUsersTab(
          langCode: langCode,
          users: allUsers,
          onAddUserPressed: () => showAdminAddStudentOrUserDialog(context, ref, langCode),
        );
      case 2:
        return AdminGroupsTab(
          langCode: langCode,
          groups: firestoreGroups,
          enrollments: firestoreEnrollments,
          isDemoFallback: isDemoMode,
          onCreateGroupPressed: () =>
              showAdminCreateGroupDialog(context, ref, langCode, isDemoFallback: isDemoMode),
        );
      case 3:
        return AdminEnrollmentsTab(
          langCode: langCode,
          enrollments: firestoreEnrollments,
          onOpenEnrollDrawer: () => setState(() => _isEnrollDrawerOpen = true),
        );
      case 4:
        return AdminAttendanceAuditTab(
          langCode: langCode,
          groups: firestoreGroups,
          isDemoFallback: isDemoMode,
        );
      case 5:
        return AdminReportsAnalyticsTab(
          langCode: langCode,
          students: firestoreStudents,
          groups: firestoreGroups,
          enrollments: firestoreEnrollments,
          isDemoFallback: isDemoMode,
        );
      case 1:
      default:
        return AdminStudentsTab(
          langCode: langCode,
          subSearchController: _subSearchController,
          rosterRows: rosterRows,
          totalStudentsCount: totalStudentsCount,
          totalGroupsCount: totalGroupsCount,
          totalOneOnOneCount: totalOneOnOneCount,
          selectedTrackFilter: selectedTrackFilter,
          selectedStudentId: _selectedStudentId,
          isDemoFallback: isDemoMode,
          onSearchChanged: (val) => setState(() => _searchQuery = val),
          onAddStudentPressed: () => showAdminAddStudentOrUserDialog(context, ref, langCode),
          onOpenEnrollDrawer: () => setState(() => _isEnrollDrawerOpen = true),
          onSelectStudentRow: (row) {
            setState(() {
              _selectedStudentId = row.id;
              _selectedStudentName = row.fullName;
              _selectedStudentCode = row.code;
              _isEnrollDrawerOpen = true;
            });
          },
        );
    }
  }
}
