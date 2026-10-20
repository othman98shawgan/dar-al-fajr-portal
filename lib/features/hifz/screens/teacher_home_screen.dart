import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/services/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../admin/models/admin_models.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/teacher_models.dart';
import '../providers/teacher_providers.dart';

class _OneOnOneSlotData {
  final String studentId;
  final String groupId;
  final String timeLabel;
  final String studentName;
  final String taskTitle;
  final String rangeSubtitle;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final IconData topIcon;
  final Color topIconColor;
  final IconData taskIcon;
  final Color taskIconColor;
  final IconData actionIcon;
  final bool isPrimaryAction;
  final bool hasTopBarAccent;

  const _OneOnOneSlotData({
    required this.studentId,
    required this.groupId,
    required this.timeLabel,
    required this.studentName,
    required this.taskTitle,
    required this.rangeSubtitle,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.topIcon,
    required this.topIconColor,
    required this.taskIcon,
    required this.taskIconColor,
    required this.actionIcon,
    this.isPrimaryAction = false,
    this.hasTopBarAccent = false,
  });
}

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  int _selectedBottomTab = 0;

  // Color tokens mapped from Stitch & DarAlFajrTheme
  static const Color _surface = Color(0xFFF7F9FB);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color _surfaceContainer = Color(0xFFECEEF0);
  static const Color _surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color _surfaceContainerHighest = Color(0xFFE0E3E5);
  static const Color _onSurface = Color(0xFF191C1E);
  static const Color _onSurfaceVariant = Color(0xFF3D4947);
  static const Color _primary = Color(0xFF00685F);
  static const Color _primaryContainer = Color(0xFF008378);
  static const Color _primaryFixed = Color(0xFF89F5E7);
  static const Color _onPrimaryFixed = Color(0xFF00201D);
  static const Color _secondary = Color(0xFF904D00);
  static const Color _secondaryFixed = Color(0xFFFFDCC3);
  static const Color _secondaryFixedDim = Color(0xFFFFB77D);
  static const Color _onSecondaryFixed = Color(0xFF2F1500);
  static const Color _tertiary = Color(0xFF1E6661);
  static const Color _tertiaryFixed = Color(0xFFABEFE8);
  static const Color _tertiaryFixedDim = Color(0xFF8FD3CC);
  static const Color _onTertiaryFixed = Color(0xFF00201E);

  static const List<_OneOnOneSlotData> _todaySlots = [
    _OneOnOneSlotData(
      studentId: 'st-1042',
      groupId: 'grp-hifz-1',
      timeLabel: '١٦:٣٠',
      studentName: 'إبراهيم طه',
      taskTitle: 'حفظ سورة النحل',
      rangeSubtitle: 'الآيات: ١ - ٣٠',
      badgeBgColor: Color(0x8089F5E7),
      badgeTextColor: _primary,
      topIcon: Icons.verified_rounded,
      topIconColor: _primary,
      taskIcon: Icons.bookmark_rounded,
      taskIconColor: _primary,
      actionIcon: Icons.play_arrow_rounded,
      isPrimaryAction: true,
      hasTopBarAccent: true,
    ),
    _OneOnOneSlotData(
      studentId: 'st-1088',
      groupId: 'grp-hifz-1',
      timeLabel: '١٧:٠٠',
      studentName: 'عبد الرحمن يوسف',
      taskTitle: 'مراجعة سورة الكهف',
      rangeSubtitle: 'كامل السورة',
      badgeBgColor: Color(0x80FFDCC3),
      badgeTextColor: _secondary,
      topIcon: Icons.schedule_rounded,
      topIconColor: _onSurfaceVariant,
      taskIcon: Icons.cached_rounded,
      taskIconColor: _secondary,
      actionIcon: Icons.check_rounded,
    ),
    _OneOnOneSlotData(
      studentId: 'st-1102',
      groupId: 'grp-tajweed-1',
      timeLabel: '١٧:٣٠',
      studentName: 'زياد المنصور',
      taskTitle: 'اختبار تجويد',
      rangeSubtitle: 'أحكام المدود',
      badgeBgColor: Color(0x80ABEFE8),
      badgeTextColor: _tertiary,
      topIcon: Icons.fact_check_outlined,
      topIconColor: _onSurfaceVariant,
      taskIcon: Icons.assignment_turned_in_outlined,
      taskIconColor: _tertiary,
      actionIcon: Icons.description_outlined,
    ),
    _OneOnOneSlotData(
      studentId: 'st-1115',
      groupId: 'grp-hifz-1',
      timeLabel: '١٨:٠٠',
      studentName: 'أحمد العلي',
      taskTitle: 'سرد الربع الأخير',
      rangeSubtitle: 'من الجزء الثلاثين',
      badgeBgColor: _surfaceContainer,
      badgeTextColor: _onSurfaceVariant,
      topIcon: Icons.mic_none_rounded,
      topIconColor: _onSurfaceVariant,
      taskIcon: Icons.record_voice_over_outlined,
      taskIconColor: _primary,
      actionIcon: Icons.arrow_forward_rounded,
    ),
  ];

  String _tr(
    String langCode, {
    required String ar,
    required String he,
    required String en,
  }) {
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

  void _cycleLanguage(String currentLangCode) {
    final nextCode = switch (currentLangCode) {
      'ar' => 'he',
      'he' => 'en',
      _ => 'ar',
    };
    ref.read(localeProvider.notifier).setLocale(Locale(nextCode));
  }

  String _nextLangBadge(String currentLangCode) {
    return switch (currentLangCode) {
      'ar' => 'EN',
      'he' => 'AR',
      _ => 'عربي',
    };
  }

  void _openGroupDetail(String groupId) {
    ref.read(selectedGroupIdProvider.notifier).setGroupId(groupId);
    context.push('${AppRoutes.teacherGroupDetail}/$groupId');
  }

  void _openAttendanceLogging(String groupId) {
    ref.read(selectedGroupIdProvider.notifier).setGroupId(groupId);
    context.push('${AppRoutes.teacherAttendance}/$groupId');
  }

  void _showGroupOptionsSheet({
    required String groupId,
    required String groupTitle,
    required String langCode,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  groupTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _onSurface,
                      ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _primaryFixed.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.groups_rounded, color: _primary),
                  ),
                  title: Text(
                    _tr(
                      langCode,
                      ar: 'فتح تفاصيل الحلقة والطلاب',
                      he: 'פתח פרטי קבוצה وتלמידים',
                      en: 'Open Group Details & Roster',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openGroupDetail(groupId);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _secondaryFixed.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.how_to_reg_rounded,
                      color: _secondary,
                    ),
                  ),
                  title: Text(
                    _tr(
                      langCode,
                      ar: 'رصد الحضور السريع للحلقة',
                      he: 'רישום נוכחות מהיר לקבוצה',
                      en: 'Quick Group Attendance Logging',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openAttendanceLogging(groupId);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleOneOnOneSlotTap(
    _OneOnOneSlotData slot,
    String langCode,
  ) async {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${slot.studentName} • ${slot.timeLabel}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: slot.badgeBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        slot.taskTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: slot.badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  slot.rangeSubtitle,
                  style: const TextStyle(color: _onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(sheetContext).pop();
                          await ref
                              .read(teacherControllerProvider.notifier)
                              .logAttendance(
                                groupId: slot.groupId,
                                studentId: slot.studentId,
                                studentName: slot.studentName,
                                status: AttendanceStatus.present,
                                sessionMode: SessionMode.oneOnOne,
                              );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _tr(
                                  langCode,
                                  ar: 'تم تسجيل حضور جلسة التسميع الفردي للطالب ${slot.studentName}',
                                  he: 'נרשמה נוכחות למפגש פרטני עבור ${slot.studentName}',
                                  en: '1-on-1 attendance logged for ${slot.studentName}',
                                ),
                              ),
                              backgroundColor: _primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded,
                            size: 18),
                        label: Text(
                          _tr(
                            langCode,
                            ar: 'تسجيل حاضر (فردي)',
                            he: 'סמן נוכח (פרטני)',
                            en: 'Mark Present (1-on-1)',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          _openGroupDetail(slot.groupId);
                        },
                        icon: const Icon(Icons.menu_book_rounded, size: 18),
                        label: Text(
                          _tr(
                            langCode,
                            ar: 'فتح الحلقة والتقييم',
                            he: 'פתח קבוצה והערכה',
                            en: 'Open Group & Grade',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final langCode = currentLocale.languageCode;
    final isRtl = isRtlLocale(currentLocale);

    final appUser = ref.watch(currentAppUserProvider).asData?.value;
    final teacherGroups =
        ref.watch(teacherGroupsProvider).asData?.value ?? const [];

    final rawName = appUser?.fullName.trim() ?? '';
    final displayTeacherName = rawName.isNotEmpty
        ? rawName
        : _tr(
            langCode,
            ar: 'أستاذ طارق',
            he: 'אוסתאז טארק',
            en: 'Ustadh Tariq',
          );

    final activeGroupsCount =
        teacherGroups.isNotEmpty ? teacherGroups.length : 4;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _surface,
        body: Stack(
          children: [
            // Main Scrollable Area
            Positioned.fill(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: _buildSelectedTabBody(
                    context: context,
                    langCode: langCode,
                    displayTeacherName: displayTeacherName,
                    teacherEmail: appUser?.email ?? 'teacher@daralfajr.org',
                    activeGroupsCount: activeGroupsCount,
                    firestoreGroups: teacherGroups,
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
                      color: _surface.withValues(alpha: 0.85),
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
                                // Start: Avatar + Title + Subtitle
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: _primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _tr(
                                            langCode,
                                            ar: 'Teacher Home Screen',
                                            he: 'מסך הבית למורה',
                                            en: 'Teacher Home Screen',
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: _onSurface,
                                                fontWeight: FontWeight.w600,
                                                height: 1.2,
                                              ),
                                        ),
                                        Text(
                                          _tr(
                                            langCode,
                                            ar: 'دار الفجر لتعليم القرآن',
                                            he: 'דאר אל-פג׳ר ללימוד הקוראן',
                                            en: 'Dar al-Fajr Quran Center',
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: _onSurfaceVariant,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // End: Language Switcher + Notifications + Logout
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Material(
                                      color: _surfaceContainer,
                                      borderRadius: BorderRadius.circular(8),
                                      child: InkWell(
                                        onTap: () => _cycleLanguage(langCode),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            minWidth: 44,
                                            minHeight: 44,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.translate_rounded,
                                                size: 18,
                                                color: _onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _nextLangBadge(langCode),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium
                                                    ?.copyWith(
                                                      color: _onSurfaceVariant,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              _tr(
                                                langCode,
                                                ar: 'لديك ٤ جلسات تسميع فردية مجدولة اليوم',
                                                he: 'יש לך 4 מפגשים פרטניים מתוכננים להיום',
                                                en: 'You have 4 individual 1-on-1 slots scheduled today',
                                              ),
                                            ),
                                            backgroundColor: _primary,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      tooltip: _tr(
                                        langCode,
                                        ar: 'التنبيهات',
                                        he: 'התראות',
                                        en: 'Notifications',
                                      ),
                                      icon: const Icon(
                                        Icons.notifications_none_rounded,
                                        color: _onSurfaceVariant,
                                        size: 22,
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
                      color: _surface.withValues(alpha: 0.90),
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
                                _BottomNavButton(
                                  icon: Icons.school_rounded,
                                  label: _tr(
                                    langCode,
                                    ar: 'حلقاتي',
                                    he: 'הקבוצות שלי',
                                    en: 'My Groups',
                                  ),
                                  isSelected: _selectedBottomTab == 0,
                                  onTap: () =>
                                      setState(() => _selectedBottomTab = 0),
                                ),
                                _BottomNavButton(
                                  icon: Icons.calendar_today_rounded,
                                  label: _tr(
                                    langCode,
                                    ar: 'الجدول اليومي',
                                    he: 'לו״ז יומי',
                                    en: 'Daily Schedule',
                                  ),
                                  isSelected: _selectedBottomTab == 1,
                                  onTap: () =>
                                      setState(() => _selectedBottomTab = 1),
                                ),
                                _BottomNavButton(
                                  icon: Icons.account_circle_outlined,
                                  label: _tr(
                                    langCode,
                                    ar: 'حسابي',
                                    he: 'החשבון שלי',
                                    en: 'My Profile',
                                  ),
                                  isSelected: _selectedBottomTab == 2,
                                  onTap: () =>
                                      setState(() => _selectedBottomTab = 2),
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
    required String teacherEmail,
    required int activeGroupsCount,
    required List<StudyGroup> firestoreGroups,
  }) {
    if (_selectedBottomTab == 1) {
      return _buildDailyScheduleTab(context, langCode);
    }
    if (_selectedBottomTab == 2) {
      return _buildProfileTab(
        context,
        langCode,
        displayTeacherName,
        teacherEmail,
      );
    }

    final topPadding = MediaQuery.paddingOf(context).top + 64 + 16;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 64 + 24;

    return ListView(
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: bottomPadding,
        left: 16,
        right: 16,
      ),
      children: [
        // 1. Teacher Welcome & Ambient Stat Strip
        _buildWelcomeStatCard(
          context: context,
          langCode: langCode,
          displayTeacherName: displayTeacherName,
          activeGroupsCount: activeGroupsCount,
        ),
        const SizedBox(height: 24),

        // 2. Section 1: My Groups (حلقاتي التعليمية)
        _buildMyGroupsSection(
          context: context,
          langCode: langCode,
          firestoreGroups: firestoreGroups,
        ),
        const SizedBox(height: 24),

        // 3. Section 2: Today's 1-on-1 Slots (جلسات فردية اليوم)
        _buildTodayOneOnOneSection(
          context: context,
          langCode: langCode,
        ),
        const SizedBox(height: 24),

        // 4. Motivational Hadith / Inspirational Card
        _buildMotivationalHadithCard(
          context: context,
          langCode: langCode,
        ),
      ],
    );
  }

  Widget _buildWelcomeStatCard({
    required BuildContext context,
    required String langCode,
    required String displayTeacherName,
    required int activeGroupsCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Avatar + Greeting + Streak Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Teacher Portrait Avatar with Online Indicator Dot
                    Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [_primary, _primaryContainer],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: _primaryContainer,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _surfaceContainerLowest,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _tr(
                                    langCode,
                                    ar: 'مرحباً، $displayTeacherName',
                                    he: 'שלום, $displayTeacherName',
                                    en: 'Welcome, $displayTeacherName',
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: _onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified_rounded,
                                color: _secondary,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _tr(
                              langCode,
                              ar: 'الأحد، ١٨ ربيع الأول ١٤٤٦ هـ • ٢٠ أكتوبر',
                              he: 'יום ראשון, 18 ברביע אל-אוול 1446 • 20 באוקטובר',
                              en: 'Sunday, 18 Rabi al-Awwal 1446 • Oct 20',
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: _onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Streak Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _secondaryFixed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 16,
                      color: _onSecondaryFixed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _tr(
                        langCode,
                        ar: '١٤ يوماً التزام',
                        he: '14 ימי התמדה',
                        en: '14d Streak',
                      ),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _onSecondaryFixed,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Vital Glance (3-column grid)
          Row(
            children: [
              Expanded(
                child: _VitalStatBox(
                  value: langCode == 'ar' ? '٤' : '$activeGroupsCount',
                  label: _tr(
                    langCode,
                    ar: 'حلقات نشطة',
                    he: 'קבוצות פעילות',
                    en: 'Active Groups',
                  ),
                  valueColor: _primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _VitalStatBox(
                  value: langCode == 'ar' ? '٤٥' : '45',
                  label: _tr(
                    langCode,
                    ar: 'طالباً مسجلاً',
                    he: 'תלמידים רשומים',
                    en: 'Enrolled Students',
                  ),
                  valueColor: _primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _VitalStatBox(
                  value: langCode == 'ar' ? '٩٦٪' : '96%',
                  label: _tr(
                    langCode,
                    ar: 'نسبة الإتقان',
                    he: 'אחוז שליטה',
                    en: 'Mastery Rate',
                  ),
                  valueColor: _secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyGroupsSection({
    required BuildContext context,
    required String langCode,
    required List<StudyGroup> firestoreGroups,
  }) {
    // Resolve real group IDs if seeded in Firestore, otherwise fallback IDs
    final hifzGroupId = firestoreGroups
            .where((g) => g.track == CenterTrack.hifz)
            .firstOrNull
            ?.id ??
        'grp-hifz-1';
    final tajweedGroupId = firestoreGroups
            .where((g) => g.track == CenterTrack.readingTajweed)
            .firstOrNull
            ?.id ??
        'grp-tajweed-1';
    final nouraniahGroupId = firestoreGroups
            .where((g) => g.track == CenterTrack.qaidahNouraniah)
            .firstOrNull
            ?.id ??
        'grp-nouraniah-1';
    final tarbawiGroupId = firestoreGroups
            .where((g) => g.track == CenterTrack.tarbawi)
            .firstOrNull
            ?.id ??
        'grp-tarbawi-1';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    color: _primary,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _tr(
                      langCode,
                      ar: 'حلقاتي التعليمية',
                      he: 'הקבוצות החינוכיות שלי',
                      en: 'My Study Groups',
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => setState(() => _selectedBottomTab = 1),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _tr(
                          langCode,
                          ar: 'الجدول الأسبوعي',
                          he: 'מערכת שעות שבועית',
                          en: 'Weekly Schedule',
                        ),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: _primary,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: _primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Group Card 1: Hifz (Active Now Highlight)
        _buildHifzPrimaryGroupCard(
          context: context,
          langCode: langCode,
          groupId: hifzGroupId,
        ),
        const SizedBox(height: 16),

        // Group Card 2: Tajweed
        _buildTajweedGroupCard(
          context: context,
          langCode: langCode,
          groupId: tajweedGroupId,
        ),
        const SizedBox(height: 16),

        // Group Card 3: Nouraniah
        _buildNouraniahGroupCard(
          context: context,
          langCode: langCode,
          groupId: nouraniahGroupId,
        ),
        const SizedBox(height: 16),

        // Group Card 4: Tarbawi
        _buildTarbawiGroupCard(
          context: context,
          langCode: langCode,
          groupId: tarbawiGroupId,
        ),
      ],
    );
  }

  Widget _buildHifzPrimaryGroupCard({
    required BuildContext context,
    required String langCode,
    required String groupId,
  }) {
    final groupTitle = _tr(
      langCode,
      ar: 'حلقة أبي بكر الصديق',
      he: 'קבוצת אבו בכר אל-סידיק',
      en: 'Abu Bakr As-Siddiq Circle',
    );

    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Start edge accent strip (Right in RTL)
          PositionedDirectional(
            top: 0,
            bottom: 0,
            start: 0,
            width: 6,
            child: Container(color: _primary),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                groupTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: _onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _primaryFixed,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: _primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _tr(
                                        langCode,
                                        ar: 'مسار الحفظ المكثف',
                                        he: 'מסלול שינון מואץ',
                                        en: 'Intensive Hifz Track',
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: _onPrimaryFixed,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tr(
                              langCode,
                              ar: '١٢ طالباً مسجلاً • مرحلة الحفظ النهائي',
                              he: '12 תלמידים רשומים • שלב שינון מתקדם',
                              en: '12 enrolled students • Final Hifz stage',
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: _onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: _surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: _primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                // Schedule Pill
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: _primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _tr(
                            langCode,
                            ar: 'الأحد والثلاثاء والخميس • بعد العصر (٤:٣٠ م - ٦:٠٠ م)',
                            he: 'א׳, ג׳, ה׳ • אחר הצהריים (16:30 - 18:00)',
                            en: 'Sun, Tue & Thu • Afternoon (4:30 PM - 6:00 PM)',
                          ),
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: _onSurfaceVariant,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress Matrix
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _tr(
                            langCode,
                            ar: 'إنجاز الخطة الشهرية (الجزء ٢٧ - الذاريات)',
                            he: 'התקדמות תוכנית חודשית (ג׳וז 27 - א-ד׳אריאת)',
                            en: 'Monthly Plan Progress (Juz 27 - Adh-Dhariyat)',
                          ),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          langCode == 'ar' ? '٧٨٪' : '78%',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: const LinearProgressIndicator(
                        value: 0.78,
                        minHeight: 8,
                        backgroundColor: _surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation<Color>(_primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Primary Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () => _openGroupDetail(groupId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.how_to_reg_rounded, size: 18),
                          label: Text(
                            _tr(
                              langCode,
                              ar: 'فتح الحلقة ورصد الحضور',
                              he: 'פתח קבוצה ורשום נוכחות',
                              en: 'Open Group & Log Attendance',
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: _surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _showGroupOptionsSheet(
                          groupId: groupId,
                          groupTitle: groupTitle,
                          langCode: langCode,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.more_vert_rounded,
                            color: _onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTajweedGroupCard({
    required BuildContext context,
    required String langCode,
    required String groupId,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _tr(
                            langCode,
                            ar: 'حلقة الإتقان والتجويد',
                            he: 'קבוצת דיוק וטג׳וויד',
                            en: 'Mastery & Tajweed Circle',
                          ),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _secondaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _tr(
                              langCode,
                              ar: 'تجويد متقدم',
                              he: 'טג׳וויד מתקדם',
                              en: 'Advanced Tajweed',
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: _onSecondaryFixed,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _tr(
                        langCode,
                        ar: '٨ طلاب • متن الجزرية ومخارج الحروف',
                        he: '8 תלמידים • מתן אל-ג׳זריה ומוצאי האותיות',
                        en: '8 students • Al-Jazariyyah & Articulation',
                      ),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: _onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _secondaryFixedDim.withValues(alpha: 0.30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.record_voice_over_rounded,
                  color: _secondary,
                  size: 20,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: _secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _tr(
                      langCode,
                      ar: 'السبت والاثنين والأربعاء • بعد المغرب (٦:٤٥ م)',
                      he: 'שבת, ב׳, ד׳ • אחרי מעריב (18:45)',
                      en: 'Sat, Mon & Wed • After Maghrib (6:45 PM)',
                    ),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: _onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.task_alt_rounded,
                      size: 16,
                      color: _secondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _tr(
                          langCode,
                          ar: 'تم تصحيح تلاوة ٥ طلاب أمس',
                          he: 'תוקנה קריאה של 5 תלמידים אתמול',
                          en: '5 students graded yesterday',
                        ),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _onSurfaceVariant,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: _surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _openGroupDetail(groupId),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.history_edu_rounded,
                          size: 18,
                          color: _onSurface,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _tr(
                            langCode,
                            ar: 'سجل المتابعة',
                            he: 'יומן מעקב',
                            en: 'Follow-up Log',
                          ),
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: _onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNouraniahGroupCard({
    required BuildContext context,
    required String langCode,
    required String groupId,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _tr(
                            langCode,
                            ar: 'حلقة البراعم النورانية',
                            he: 'קבוצת ניצני אל-נוראניה',
                            en: 'Nouraniah Sprouts Circle',
                          ),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _tertiaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _tr(
                              langCode,
                              ar: 'القاعدة النورانية',
                              he: 'קאעידה נוראניה',
                              en: "Qa'idah Nouraniah",
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: _onTertiaryFixed,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _tr(
                        langCode,
                        ar: '١٠ طلاب • الدرس الحادي عشر: السكون',
                        he: '10 תלמידים • שיעור 11: סוכון',
                        en: '10 students • Lesson 11: Sukoon',
                      ),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: _onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _tertiaryFixedDim.withValues(alpha: 0.30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.child_care_rounded,
                  color: _tertiary,
                  size: 20,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_repeat_rounded,
                  size: 18,
                  color: _tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _tr(
                      langCode,
                      ar: 'يومياً عدا الجمعة • ٤:٠٠ م',
                      he: 'כל يوم פרט לשישי • 16:00',
                      en: 'Daily except Friday • 4:00 PM',
                    ),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: _onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _tr(
                    langCode,
                    ar: 'المقر الحالي: القاعة التعليمية ٢',
                    he: 'מיקום נוכחי: חדר לימוד 2',
                    en: 'Location: Classroom 2',
                  ),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: _surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _openGroupDetail(groupId),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _tr(
                            langCode,
                            ar: 'عرض الحلقة',
                            he: 'הצג קבוצה',
                            en: 'View Group',
                          ),
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: _onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: _onSurface,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTarbawiGroupCard({
    required BuildContext context,
    required String langCode,
    required String groupId,
  }) {
    return InkWell(
      onTap: () => _openGroupDetail(groupId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            _tr(
                              langCode,
                              ar: 'حلقة التربية والتدبر',
                              he: 'קבוצת חינוך והתבוננות',
                              en: 'Tarbawi & Reflection Circle',
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: _onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _tr(
                                langCode,
                                ar: 'مسار تربوي',
                                he: 'מסלול חינוכי',
                                en: 'Tarbawi Track',
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: _onSurfaceVariant,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _tr(
                          langCode,
                          ar: '١٥ طالباً • مدارسة قصص الأنبياء وأخلاق القرآن',
                          he: '15 תלמידים • סיפורי הנביאים ומידות הקוראן',
                          en: '15 students • Stories of the Prophets & Ethics',
                        ),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: _onSurfaceVariant,
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: _surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    color: _onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.date_range_rounded,
                        size: 18,
                        color: _primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _tr(
                          langCode,
                          ar: 'الجمعة • ٨:٠٠ ص',
                          he: 'יום שישי • 8:00 בבוקר',
                          en: 'Friday • 8:00 AM',
                        ),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: _onSurfaceVariant,
                                ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _tr(
                        langCode,
                        ar: 'أسبوعي',
                        he: 'שבועי',
                        en: 'Weekly',
                      ),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _onSurfaceVariant,
                            fontSize: 11,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayOneOnOneSection({
    required BuildContext context,
    required String langCode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person_pin_circle_rounded,
                    color: _secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _tr(
                      langCode,
                      ar: 'جلسات فردية اليوم',
                      he: 'מפגשים פרטניים להיום',
                      en: "Today's 1-on-1 Slots",
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _tr(
                    langCode,
                    ar: '٤ جلسات متبقية',
                    he: '4 מפגשים נותרו',
                    en: '4 slots remaining',
                  ),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _todaySlots.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final slot = _todaySlots[index];
              return InkWell(
                onTap: () => _handleOneOnOneSlotTap(slot, langCode),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 210,
                  decoration: BoxDecoration(
                    color: _surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      if (slot.hasTopBarAccent)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 4,
                          child: Container(color: _primary),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: slot.badgeBgColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        slot.timeLabel,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: slot.badgeTextColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    Icon(
                                      slot.topIcon,
                                      size: 18,
                                      color: slot.topIconColor,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  slot.studentName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: _onSurface,
                                        fontWeight: FontWeight.w600,
                                        height: 1.25,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      slot.taskIcon,
                                      size: 16,
                                      color: slot.taskIconColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        slot.taskTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: _onSurfaceVariant,
                                              fontWeight: FontWeight.w500,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      slot.rangeSubtitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: _onSurfaceVariant,
                                            fontSize: 11,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: slot.isPrimaryAction
                                          ? _primary
                                          : _surfaceContainerHigh,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      slot.actionIcon,
                                      size: 16,
                                      color: slot.isPrimaryAction
                                          ? Colors.white
                                          : _onSurface,
                                    ),
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalHadithCard({
    required BuildContext context,
    required String langCode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primary.withValues(alpha: 0.10),
            _primary.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: _primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr(
                    langCode,
                    ar: 'تذكير نبوي شريف',
                    he: 'תזכורת נבואית מבורכת',
                    en: 'Prophetic Reminder',
                  ),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: _primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _tr(
                    langCode,
                    ar: '"خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ" — بارك الله في أوقاتكم وسعيكم.',
                    he: '"הטובים שבכם הם אלה שלומדים את הקוראן ומלמדים אותו" — יברך אללה את זמנכם.',
                    en: '"The best among you are those who learn the Quran and teach it."',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyScheduleTab(BuildContext context, String langCode) {
    final topPadding = MediaQuery.paddingOf(context).top + 64 + 16;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 64 + 24;

    return ListView(
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: bottomPadding,
        left: 16,
        right: 16,
      ),
      children: [
        Text(
          _tr(
            langCode,
            ar: 'الجدول اليومي وجلسات التسميع',
            he: 'לוח זמנים יומי ומפגשי שינון',
            en: 'Daily Schedule & Recitation Slots',
          ),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _onSurface,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          _tr(
            langCode,
            ar: 'مواعيد الحلقات الجماعية والجلسات الفردية المجدولة لهذا اليوم',
            he: 'זמני השיעורים הקבוצתיים והמפגשים הפרטניים להיום',
            en: 'Group classes and individual 1-on-1 slots scheduled for today',
          ),
          style: const TextStyle(color: _onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        ..._todaySlots.map((slot) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _handleOneOnOneSlotTap(slot, langCode),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: slot.badgeBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        slot.timeLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: slot.badgeTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.studentName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${slot.taskTitle} • ${slot.rangeSubtitle}',
                            style: const TextStyle(
                              color: _onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: _onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildProfileTab(
    BuildContext context,
    String langCode,
    String displayTeacherName,
    String teacherEmail,
  ) {
    final topPadding = MediaQuery.paddingOf(context).top + 64 + 16;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 64 + 24;

    return ListView(
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: bottomPadding,
        left: 16,
        right: 16,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: _primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                displayTeacherName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                teacherEmail,
                style: const TextStyle(color: _onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DarAlFajrTheme.error,
                    side: const BorderSide(color: DarAlFajrTheme.error),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(
                    _tr(
                      langCode,
                      ar: 'تسجيل الخروج من الحساب',
                      he: 'התנתק מהחשבון',
                      en: 'Sign Out',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VitalStatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _VitalStatBox({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF3D4947),
                  fontSize: 11,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF00685F);
    const inactiveColor = Color(0xFF3D4947);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minWidth: 64, minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ? activeColor : inactiveColor,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
