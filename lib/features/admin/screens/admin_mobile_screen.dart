import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/services/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_dialogs.dart';
import '../widgets/admin_mobile_dialogs.dart';
import '../widgets/admin_mobile_models.dart';
import '../widgets/admin_mobile_tabs.dart';

/// Stitch-Accurate Mobile Admin Screen for Dar al-Fajr Portal (إدارة دار الفجر)
class AdminMobileScreen extends ConsumerStatefulWidget {
  const AdminMobileScreen({super.key});

  @override
  ConsumerState<AdminMobileScreen> createState() => _AdminMobileScreenState();
}

class _AdminMobileScreenState extends ConsumerState<AdminMobileScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isAscendingOrder = true;

  @override
  void dispose() {
    _searchController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final langCode = currentLocale.languageCode;
    final isRtl = isRtlLocale(currentLocale);

    final selectedTab = ref.watch(adminSelectedTabProvider);
    final selectedTrackFilter = ref.watch(adminTrackFilterProvider);

    final firestoreStudents = ref.watch(adminStudentsProvider).asData?.value ?? const [];
    final firestoreGroups = ref.watch(adminGroupsProvider).asData?.value ?? const [];
    final firestoreEnrollments = ref.watch(adminEnrollmentsProvider).asData?.value ?? const [];
    final allUsers = ref.watch(adminAllUsersProvider).asData?.value ?? const [];
    final showArchived = ref.watch(adminShowArchivedProvider);

    final visibleStudents = firestoreStudents.where((s) => s.isArchived == showArchived).toList();
    final visibleGroups = firestoreGroups.where((g) => g.isArchived == showArchived).toList();
    final activeStudentsCount = firestoreStudents.where((s) => !s.isArchived).length;
    final activeGroupsCount = firestoreGroups.where((g) => !g.isArchived).length;

    final isDemoMode = _isDemoFallback;
    final studentCards = buildMobileStudentCards(
      firestoreStudents: visibleStudents,
      firestoreEnrollments: firestoreEnrollments,
      trackFilter: selectedTrackFilter,
      query: _searchQuery,
      isDemoMode: isDemoMode && !showArchived,
      isAscendingOrder: _isAscendingOrder,
    );

    final totalStudentsCount = firestoreStudents.isNotEmpty ? activeStudentsCount : (isDemoMode ? 142 : 0);
    final totalGroupsCount = firestoreGroups.isNotEmpty ? activeGroupsCount : (isDemoMode ? 12 : 0);
    final totalOneOnOneCount = firestoreEnrollments.isNotEmpty
        ? firestoreEnrollments.where((e) => e.oneOnOneSlotTime != null && e.oneOnOneSlotTime!.isNotEmpty).length
        : (isDemoMode ? 68 : 0);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: DarAlFajrTheme.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: DarAlFajrTheme.primary.withValues(alpha: 0.15),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  trByLang(langCode, ar: 'إدارة دار الفجر', he: 'הנהלת דאר אל-פג׳ר', en: 'Dar al-Fajr Admin'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: DarAlFajrTheme.primary,
                                      ),
                                ),
                                Text(
                                  selectedTab == 1
                                      ? 'Students • الطلاب'
                                      : selectedTab == 2
                                          ? 'Groups • الحلقات'
                                          : selectedTab == 0
                                              ? 'Users • المستخدمين'
                                              : 'Reports • التقارير',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: const Color(0xFF6D7A77),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => showAdminGradingSettingsDialog(context, ref, langCode),
                          tooltip: trByLang(langCode, ar: 'إعدادات خصم الدرجات', he: 'הגדרות ציונים', en: 'Grading Penalty Settings'),
                          icon: const Icon(Icons.tune_rounded, color: Color(0xFF3D4947), size: 20),
                          visualDensity: VisualDensity.compact,
                        ),
                        Stack(
                          children: [
                            IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(trByLang(langCode, ar: 'لا توجد تنبيهات عاجلة', he: 'אין התראות דחופות', en: 'No urgent alerts')),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF3D4947)),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: Color(0xFFFE932C), shape: BoxShape.circle),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => context.go(AppRoutes.account),
                          borderRadius: BorderRadius.circular(20),
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: DarAlFajrTheme.primary,
                            child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: IndexedStack(
          index: selectedTab == 1
              ? 0
              : selectedTab == 2
                  ? 1
                  : selectedTab == 0
                      ? 2
                      : 3,
          children: [
            AdminMobileStudentsTab(
              langCode: langCode,
              searchController: _searchController,
              studentCards: studentCards,
              totalStudents: totalStudentsCount,
              totalGroups: totalGroupsCount,
              totalOneOnOne: totalOneOnOneCount,
              trackFilter: selectedTrackFilter,
              firestoreGroups: firestoreGroups,
              firestoreStudents: firestoreStudents,
              firestoreEnrollments: firestoreEnrollments,
              isDemoMode: isDemoMode,
              onSearchChanged: (val) => setState(() => _searchQuery = val),
              onToggleSortOrder: () => setState(() => _isAscendingOrder = !_isAscendingOrder),
            ),
            AdminMobileGroupsTab(
              langCode: langCode,
              firestoreGroups: visibleGroups,
              firestoreEnrollments: firestoreEnrollments,
              isDemoMode: isDemoMode && !showArchived,
            ),
            AdminMobileUsersTab(
              langCode: langCode,
              allUsers: allUsers,
              isDemoMode: isDemoMode,
            ),
            AdminMobileReportsTab(
              langCode: langCode,
              students: firestoreStudents,
              groups: firestoreGroups,
              enrollments: firestoreEnrollments,
              isDemoMode: isDemoMode,
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FloatingActionButton.extended(
            heroTag: 'adminMobileQuickAddFab',
            onPressed: () => showMobileAdminActionModal(context, ref, langCode, isDemoMode: isDemoMode),
            backgroundColor: DarAlFajrTheme.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.person_add_rounded, size: 22),
            label: Text(
              trByLang(langCode, ar: 'إضافة طالب / حلقة', he: 'הוספת תלמיד / קבוצה', en: 'Add Student / Group'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildBottomNavItem(
                      icon: Icons.school_rounded,
                      label: trByLang(langCode, ar: 'الطلاب', he: 'תלמידים', en: 'Students'),
                      isSelected: selectedTab == 1,
                      onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(1),
                    ),
                  ),
                  Expanded(
                    child: _buildBottomNavItem(
                      icon: Icons.groups_rounded,
                      label: trByLang(langCode, ar: 'الحلقات', he: 'קבוצות', en: 'Groups'),
                      isSelected: selectedTab == 2,
                      onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(2),
                    ),
                  ),
                  Expanded(
                    child: _buildBottomNavItem(
                      icon: Icons.manage_accounts_rounded,
                      label: trByLang(langCode, ar: 'المستخدمين', he: 'משתמשים', en: 'Users'),
                      isSelected: selectedTab == 0,
                      onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(0),
                    ),
                  ),
                  Expanded(
                    child: _buildBottomNavItem(
                      icon: Icons.query_stats_rounded,
                      label: trByLang(langCode, ar: 'التقارير', he: 'דוחות', en: 'Reports'),
                      isSelected: selectedTab == 3,
                      onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(3),
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

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? DarAlFajrTheme.primary : const Color(0xFF6D7A77),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? DarAlFajrTheme.primary : const Color(0xFF6D7A77),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
