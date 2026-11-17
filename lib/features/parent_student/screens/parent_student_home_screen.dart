import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/services/locale_provider.dart';
import '../../../core/services/quran_metadata_service.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/parent_student_providers.dart';
import '../widgets/parent_child_profile_builder.dart';
import '../widgets/parent_progress_summary_tab.dart';
import '../widgets/parent_schedule_homework_tab.dart';
import '../widgets/parent_student_tokens.dart';

/// Screen 8: Parent & Student Consolidated Experience (`ParentStudentHomeScreen`)
/// - Tab 0: الجدول والواجبات (Arrival Schedule & Weekly Homework)
/// - Tab 1: ملخص التقدم (Automated Quran Memorization Progress Dashboard)
class ParentStudentHomeScreen extends ConsumerWidget {
  const ParentStudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final langCode = currentLocale.languageCode;
    final isRtl = isRtlLocale(currentLocale);

    final appUser = ref.watch(currentAppUserProvider).asData?.value;
    final isStudentRole = appUser?.role == UserRole.student;

    final selectedChildId = ref.watch(selectedChildIdProvider);
    final selectedTab = ref.watch(parentStudentTabProvider);
    final acknowledgedSet = ref.watch(acknowledgedHomeworkProvider);
    final quranService = ref.watch(quranMetadataServiceProvider);

    final firestoreChildrenAsync = ref.watch(parentChildrenStreamProvider);
    final firestoreChildren = firestoreChildrenAsync.asData?.value ?? const [];
    final isDemoMode = Firebase.apps.isEmpty &&
        !firestoreChildrenAsync.isLoading &&
        firestoreChildren.isEmpty;

    final effectiveChildId = !isDemoMode
        ? (firestoreChildren.any((s) => s.id == selectedChildId)
            ? selectedChildId
            : (firestoreChildren.isNotEmpty ? firestoreChildren.first.id : ''))
        : selectedChildId;

    final activeEnrollments = ref
            .watch(childEnrollmentsStreamProvider(effectiveChildId))
            .asData
            ?.value ??
        const [];
    final activeAttendance = ref
            .watch(childAttendanceStreamProvider(effectiveChildId))
            .asData
            ?.value ??
        const [];
    final activeAssignments = ref
            .watch(childAssignmentsStreamProvider(effectiveChildId))
            .asData
            ?.value ??
        const [];

    final childrenProfiles = buildParentChildProfiles(
      firestoreChildren: firestoreChildren,
      activeChildId: effectiveChildId,
      activeEnrollments: activeEnrollments,
      activeAttendance: activeAttendance,
      activeAssignments: activeAssignments,
      quranService: quranService,
      langCode: langCode,
      isDemoMode: isDemoMode,
    );

    if (childrenProfiles.isEmpty) {
      return Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: ParentStudentTokens.surface,
          appBar: AppBar(
            backgroundColor: ParentStudentTokens.surface,
            elevation: 0,
            title: Text(
              isStudentRole
                  ? trByLang(
                      langCode,
                      ar: 'بوابة الطالب',
                      he: 'פורטל תלמיד',
                      en: 'Student Portal',
                    )
                  : trByLang(
                      langCode,
                      ar: 'بوابة ولي الأمر',
                      he: 'פורטל הורים',
                      en: 'Parent Portal',
                    ),
              style: const TextStyle(
                color: ParentStudentTokens.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.go(AppRoutes.account),
                icon: const Icon(
                  Icons.person_rounded,
                  color: ParentStudentTokens.primary,
                ),
              ),
            ],
          ),
          body: Center(
            child: firestoreChildrenAsync.isLoading &&
                    firestoreChildrenAsync.asData == null
                ? const CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      isStudentRole
                          ? trByLang(
                              langCode,
                              ar: 'لم يتم ربط ملف الطالب بهذا الحساب بعد.',
                              he: 'פרופיל התלמיד טרם קושר לחשבון זה.',
                              en: 'No student profile is linked to this account yet.',
                            )
                          : trByLang(
                              langCode,
                              ar: 'لا يوجد أبناء مرتبطون بهذا الحساب بعد.',
                              he: 'אין ילדים משויכים לחשבון זה עדיין.',
                              en: 'No students are linked to this account yet.',
                            ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: ParentStudentTokens.onSurfaceVariant,
                      ),
                    ),
                  ),
          ),
        ),
      );
    }

    final activeChild = childrenProfiles
            .where((c) => c.id == effectiveChildId)
            .firstOrNull ??
        childrenProfiles.first;

    final isHomeworkSigned = acknowledgedSet.contains(activeChild.id);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: ParentStudentTokens.surface,
        body: Stack(
          children: [
            // Main Scrollable Tab Body
            Positioned.fill(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: IndexedStack(
                    index: selectedTab,
                    children: [
                      // TAB 0: الجدول والواجبات
                      ParentScheduleHomeworkTab(
                        langCode: langCode,
                        child: activeChild,
                        isHomeworkSigned: isHomeworkSigned,
                      ),

                      // TAB 1: ملخص التقدم
                      ParentProgressSummaryTab(
                        langCode: langCode,
                        child: activeChild,
                        isDemoMode: isDemoMode,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed Translucent Top Header (Title + Child-Switcher Carousel)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          ParentStudentTokens.surface.withValues(alpha: 0.90),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: SizedBox(
                            height: 112,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Row 1: Brand Title + Notifications + Account Avatar
                                  SizedBox(
                                    height: 48,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: ParentStudentTokens
                                                        .primary
                                                        .withValues(alpha: 0.15),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(4),
                                                child: Image.asset(
                                                  'assets/logo.png',
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      isStudentRole
                                                          ? trByLang(
                                                              langCode,
                                                              ar: 'بوابة الطالب',
                                                              he: 'פורטל תלמיד',
                                                              en: 'Student Portal',
                                                            )
                                                          : trByLang(
                                                              langCode,
                                                              ar: 'بوابة ولي الأمر',
                                                              he: 'פורטל הורים',
                                                              en: 'Parent Portal',
                                                            ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                            color:
                                                                ParentStudentTokens
                                                                    .primary,
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color:
                                                            ParentStudentTokens
                                                                .outline,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Right Actions: Notifications + Account Avatar
                                        Row(
                                          children: [
                                            Material(
                                              color: ParentStudentTokens
                                                  .surfaceContainer,
                                              shape: const CircleBorder(),
                                              child: InkWell(
                                                customBorder:
                                                    const CircleBorder(),
                                                onTap: () {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        trByLang(
                                                          langCode,
                                                          ar: 'تم تحديث تقييم الواجب الأسبوعي لـ ${activeChild.shortName}',
                                                          he: 'הערכת המטלה השבועית עודכנה',
                                                          en: 'Weekly evaluation updated for ${activeChild.shortName}',
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          ParentStudentTokens
                                                              .primary,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  );
                                                },
                                                child: const SizedBox(
                                                  width: 36,
                                                  height: 36,
                                                  child: Icon(
                                                    Icons
                                                        .notifications_none_rounded,
                                                    color: ParentStudentTokens
                                                        .onSurface,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            InkWell(
                                              onTap: () => context
                                                  .go(AppRoutes.account),
                                              customBorder:
                                                  const CircleBorder(),
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
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: ParentStudentTokens
                                                        .primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.person_rounded,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Row 2: Horizontal Child-Switcher Carousel
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: childrenProfiles.map((child) {
                                        final isSelected =
                                            child.id == activeChild.id;
                                        return Padding(
                                          padding: const EdgeInsetsDirectional
                                              .only(end: 6),
                                          child: Material(
                                            color: isSelected
                                                ? ParentStudentTokens.primary
                                                : ParentStudentTokens
                                                    .surfaceContainerLowest,
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            elevation: isSelected ? 1 : 0,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              onTap: () {
                                                ref
                                                    .read(
                                                        selectedChildIdProvider
                                                            .notifier)
                                                    .selectChild(child.id);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 6,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      isSelected
                                                          ? Icons.face_rounded
                                                          : Icons
                                                              .person_outline_rounded,
                                                      size: 16,
                                                      color: isSelected
                                                          ? Colors.white
                                                          : ParentStudentTokens
                                                              .outline,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      child.shortName,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.w500,
                                                        color: isSelected
                                                            ? Colors.white
                                                            : ParentStudentTokens
                                                                .onSurfaceVariant,
                                                      ),
                                                    ),
                                                    if (isSelected) ...[
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        width: 8,
                                                        height: 8,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: ParentStudentTokens
                                                              .secondaryContainer,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
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
            ),

            // Fixed Translucent Bottom Navigation Bar (2 Tabs)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          ParentStudentTokens.surface.withValues(alpha: 0.92),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: SizedBox(
                            height: 80,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ParentBottomNavTab(
                                    icon: Icons.menu_book_rounded,
                                    label: trByLang(
                                      langCode,
                                      ar: 'الجدول والواجبات',
                                      he: 'מערכת שעות ומטלות',
                                      en: 'Schedule & Homework',
                                    ),
                                    isSelected: selectedTab == 0,
                                    onTap: () => ref
                                        .read(parentStudentTabProvider.notifier)
                                        .setTab(0),
                                  ),
                                  ParentBottomNavTab(
                                    icon: Icons.analytics_outlined,
                                    label: trByLang(
                                      langCode,
                                      ar: 'ملخص التقدم',
                                      he: 'סיכום התקדמות',
                                      en: 'Progress Summary',
                                    ),
                                    isSelected: selectedTab == 1,
                                    onTap: () => ref
                                        .read(parentStudentTabProvider.notifier)
                                        .setTab(1),
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
            ),
          ],
        ),
      ),
    );
  }
}
