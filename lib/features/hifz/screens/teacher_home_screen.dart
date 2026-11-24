import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/services/locale_provider.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../../account/screens/account_screen.dart';
import '../../admin/models/admin_models.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/teacher_providers.dart';
import '../widgets/teacher_group_cards.dart';
import '../widgets/teacher_home_models.dart';
import '../widgets/teacher_one_on_one_section.dart';
import '../widgets/teacher_schedule_tab.dart';
import '../widgets/teacher_welcome_card.dart';
import 'teacher_student_profile_screen.dart';

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  int _selectedBottomTab = 0;

  void _openGroupDetail(String groupId) {
    ref.read(selectedGroupIdProvider.notifier).setGroupId(groupId);
    context.push('${AppRoutes.teacherGroupDetail}/$groupId');
  }

  void _openAttendanceLogging(String groupId) {
    ref.read(selectedGroupIdProvider.notifier).setGroupId(groupId);
    context.push('${AppRoutes.teacherAttendance}/$groupId');
  }

  void _openStudentProfile(String groupId, String studentId) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push('${AppRoutes.teacherStudentProfile}/$groupId/$studentId');
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TeacherStudentProfileScreen(
            groupId: groupId,
            studentId: studentId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final langCode = currentLocale.languageCode;
    final isRtl = isRtlLocale(currentLocale);

    final appUser = ref.watch(currentAppUserProvider).asData?.value;
    final teacherGroups = ref.watch(teacherGroupsProvider).asData?.value ?? const [];
    final allEnrollments = ref.watch(allEnrollmentsStreamProvider).asData?.value ?? const [];

    final isDemoFallback =
        Firebase.apps.isEmpty && appUser == null && teacherGroups.isEmpty && allEnrollments.isEmpty;
    final rawName = appUser?.fullName.trim() ?? '';
    final displayTeacherName = rawName.isNotEmpty
        ? rawName
        : (!isDemoFallback
            ? (appUser?.email ?? '')
            : trByLang(langCode, ar: 'أستاذ طارق', he: 'אוסתאז טארק', en: 'Ustadh Tariq'));

    final activeGroupsCount = teacherGroups.isNotEmpty ? teacherGroups.length : (isDemoFallback ? 4 : 0);
    final teacherGroupIds = teacherGroups.map((g) => g.id).toSet();
    final teacherEnrollments =
        allEnrollments.where((e) => teacherGroupIds.isEmpty || teacherGroupIds.contains(e.groupId)).toList();
    final uniqueStudentIds = teacherEnrollments.map((e) => e.studentId).toSet();
    final totalStudentsCount = uniqueStudentIds.isNotEmpty ? uniqueStudentIds.length : (isDemoFallback ? 45 : 0);

    final groupStudentCounts = <String, int>{};
    final groupSeenStudents = <String, Set<String>>{};
    for (final enr in teacherEnrollments) {
      final seen = groupSeenStudents.putIfAbsent(enr.groupId, () => <String>{});
      if (seen.add(enr.studentId)) {
        groupStudentCounts[enr.groupId] = seen.length;
      }
    }

    final todayWeekday = DateTime.now().weekday;
    final parsedSlots = buildOneOnOneSlotsFromEnrollments(
      enrollments: teacherEnrollments,
      langCode: langCode,
    );
    final realTodaySlots = parsedSlots
        .where((s) => s.weekday == todayWeekday || s.weekday == null)
        .toList();

    final activeTodaySlots =
        !isDemoFallback ? realTodaySlots : (realTodaySlots.isNotEmpty ? realTodaySlots : teacherDemoTodaySlots);

    final todayScheduleEntries = buildTeacherScheduleForWeekday(
      weekday: todayWeekday,
      groups: teacherGroups,
      enrollments: teacherEnrollments,
      langCode: langCode,
      isDemoFallback: isDemoFallback,
    );
    final todaySessionsCount = todayScheduleEntries.length;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: TeacherHomeTokens.surface,
        body: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: _buildSelectedTabBody(
                    context: context,
                    langCode: langCode,
                    displayTeacherName: displayTeacherName,
                    activeGroupsCount: activeGroupsCount,
                    totalStudentsCount: totalStudentsCount,
                    todaySessionsCount: todaySessionsCount,
                    isDemoFallback: isDemoFallback,
                    firestoreGroups: teacherGroups,
                    teacherEnrollments: teacherEnrollments,
                    groupStudentCounts: groupStudentCounts,
                    todaySlots: activeTodaySlots,
                  ),
                ),
              ),
            ),

            // Fixed Translucent Top Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: TeacherHomeTokens.surface.withValues(alpha: 0.85),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: Container(
                            height: 64,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: TeacherHomeTokens.primary.withValues(alpha: 0.15),
                                          width: 1.5,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trByLang(langCode, ar: 'بوابة المعلم', he: 'פורטל מורה', en: 'Teacher Portal'),
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: TeacherHomeTokens.primary,
                                                fontWeight: FontWeight.w600,
                                                height: 1.2,
                                              ),
                                        ),
                                        Text(
                                          trByLang(
                                            langCode,
                                            ar: 'دار الفجر لتعليم القرآن',
                                            he: 'דאר אל-פג׳ר ללימוד הקוראן',
                                            en: 'Dar al-Fajr Quran Center',
                                          ),
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                color: TeacherHomeTokens.onSurfaceVariant,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Material(
                                      color: TeacherHomeTokens.surfaceContainer,
                                      shape: const CircleBorder(),
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                trByLang(
                                                  langCode,
                                                  ar: 'لديك ${formatTeacherNum(activeTodaySlots.length, langCode)} جلسات تسميع فردية مجدولة اليوم',
                                                  he: 'יש לך ${activeTodaySlots.length} מפגשים פרטניים מתוכננים להיום',
                                                  en: 'You have ${activeTodaySlots.length} individual 1-on-1 slots scheduled today',
                                                ),
                                              ),
                                              backgroundColor: TeacherHomeTokens.primary,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        child: const SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: Icon(
                                            Icons.notifications_none_rounded,
                                            color: TeacherHomeTokens.onSurface,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => context.go(AppRoutes.account),
                                      customBorder: const CircleBorder(),
                                      child: Tooltip(
                                        message: trByLang(
                                          langCode,
                                          ar: 'حسابي الشخصي واللغة',
                                          he: 'החשבון שלי ושפה',
                                          en: 'My Account & Language',
                                        ),
                                        child: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: const BoxDecoration(
                                            color: TeacherHomeTokens.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
                                        ),
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
                  ),
                ),
              ),
            ),

            // Fixed Translucent Bottom Navigation Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: TeacherHomeTokens.surface.withValues(alpha: 0.90),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: SizedBox(
                            height: 64,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TeacherBottomNavButton(
                                  icon: Icons.school_rounded,
                                  label: trByLang(langCode, ar: 'حلقاتي', he: 'הקבוצות שלי', en: 'My Groups'),
                                  isSelected: _selectedBottomTab == 0,
                                  onTap: () => setState(() => _selectedBottomTab = 0),
                                ),
                                TeacherBottomNavButton(
                                  icon: Icons.calendar_today_rounded,
                                  label: trByLang(langCode, ar: 'الجدول', he: 'לו״ז', en: 'Schedule'),
                                  isSelected: _selectedBottomTab == 1,
                                  onTap: () => setState(() => _selectedBottomTab = 1),
                                ),
                                TeacherBottomNavButton(
                                  icon: Icons.account_circle_outlined,
                                  label: trByLang(langCode, ar: 'حسابي', he: 'החשבון שלי', en: 'My Profile'),
                                  isSelected: _selectedBottomTab == 2,
                                  onTap: () => context.go(AppRoutes.account),
                                ),
                              ],
                            ),
                          ),
                        ),
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
  }

  Widget _buildSelectedTabBody({
    required BuildContext context,
    required String langCode,
    required String displayTeacherName,
    required int activeGroupsCount,
    required int totalStudentsCount,
    required int todaySessionsCount,
    required bool isDemoFallback,
    required List<StudyGroup> firestoreGroups,
    required List<Enrollment> teacherEnrollments,
    required Map<String, int> groupStudentCounts,
    required List<OneOnOneSlotData> todaySlots,
  }) {
    if (_selectedBottomTab == 1) {
      return TeacherScheduleTab(
        langCode: langCode,
        groups: firestoreGroups,
        enrollments: teacherEnrollments,
        isDemoFallback: isDemoFallback,
        onOpenGroupDetail: _openGroupDetail,
        onOpenAttendanceLogging: _openAttendanceLogging,
        onOneOnOneTap: (slot) => handleTeacherOneOnOneSlotTap(
          context: context,
          ref: ref,
          slot: slot,
          langCode: langCode,
          onOpenGroupDetail: _openGroupDetail,
          onOpenStudentProfile: _openStudentProfile,
        ),
      );
    }
    if (_selectedBottomTab == 2) {
      return const AccountScreen();
    }

    final topPadding = MediaQuery.paddingOf(context).top + 64 + 16;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 64 + 24;

    return ListView(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding, left: 16, right: 16),
      children: [
        TeacherWelcomeStatCard(
          langCode: langCode,
          displayTeacherName: displayTeacherName,
          activeGroupsCount: activeGroupsCount,
          totalStudentsCount: totalStudentsCount,
          todaySessionsCount: todaySessionsCount,
          isDemoFallback: isDemoFallback,
        ),
        const SizedBox(height: 24),
        TeacherMyGroupsSection(
          langCode: langCode,
          firestoreGroups: firestoreGroups,
          groupStudentCounts: groupStudentCounts,
          isDemoFallback: isDemoFallback,
          onSwitchToScheduleTab: () => setState(() => _selectedBottomTab = 1),
          onOpenGroupDetail: _openGroupDetail,
          onOpenAttendanceLogging: _openAttendanceLogging,
          onShowGroupOptions: (groupId, groupTitle) => showTeacherGroupOptionsSheet(
            context: context,
            groupId: groupId,
            groupTitle: groupTitle,
            langCode: langCode,
            onOpenGroupDetail: _openGroupDetail,
            onOpenAttendanceLogging: _openAttendanceLogging,
          ),
        ),
        const SizedBox(height: 24),
        TeacherTodayOneOnOneSection(
          langCode: langCode,
          slots: todaySlots,
          onSlotTap: (slot) => handleTeacherOneOnOneSlotTap(
            context: context,
            ref: ref,
            slot: slot,
            langCode: langCode,
            onOpenGroupDetail: _openGroupDetail,
            onOpenStudentProfile: _openStudentProfile,
          ),
        ),
        const SizedBox(height: 24),
        TeacherMotivationalHadithCard(langCode: langCode),
      ],
    );
  }
}
