import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/services/locale_provider.dart';
import '../../../core/services/quran_metadata_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../admin/models/admin_models.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../hifz/models/teacher_models.dart';
import '../../hifz/providers/teacher_providers.dart';
import '../models/parent_student_models.dart';
import '../providers/parent_student_providers.dart';

/// Screen 8: Parent & Student Consolidated Experience (`ParentStudentHomeScreen`)
/// Translates both Google Stitch screens:
/// - Tab 0: الجدول والواجبات (Arrival Schedule & Weekly Homework)
/// - Tab 1: ملخص التقدم (Automated Quran Memorization Progress Dashboard)
class ParentStudentHomeScreen extends ConsumerStatefulWidget {
  const ParentStudentHomeScreen({super.key});

  @override
  ConsumerState<ParentStudentHomeScreen> createState() =>
      _ParentStudentHomeScreenState();
}

class _ParentStudentHomeScreenState
    extends ConsumerState<ParentStudentHomeScreen> {
  // Stitch design tokens mapped to Flutter constants
  static const Color _primary = Color(0xFF00685F);
  static const Color _primaryContainer = Color(0xFF008378);
  static const Color _primaryFixed = Color(0xFF89F5E7);
  static const Color _onPrimaryFixed = Color(0xFF00201D);
  static const Color _primaryFixedDim = Color(0xFF6BD8CB);
  static const Color _secondary = Color(0xFF904D00);
  static const Color _secondaryContainer = Color(0xFFFE932C);
  static const Color _secondaryFixed = Color(0xFFFFDCC3);
  static const Color _onSecondaryFixed = Color(0xFF2F1500);
  static const Color _onSecondaryFixedVariant = Color(0xFF6E3900);
  static const Color _tertiary = Color(0xFF1E6661);
  static const Color _tertiaryContainer = Color(0xFF3B7F7A);
  static const Color _tertiaryFixed = Color(0xFFABEFE8);
  static const Color _onTertiaryFixed = Color(0xFF00201E);
  static const Color _surface = Color(0xFFF7F9FB);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color _surfaceContainer = Color(0xFFECEEF0);
  static const Color _surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color _surfaceContainerHighest = Color(0xFFE0E3E5);
  static const Color _onSurface = Color(0xFF191C1E);
  static const Color _onSurfaceVariant = Color(0xFF3D4947);
  static const Color _outline = Color(0xFF6D7A77);

  bool _isPlayingTeacherVoice = false;
  bool _isPlayingLastRecitation = false;
  bool _showAllCompletedSurahs = false;
  bool _isReminderEnabled = false;
  final Map<int, RevisionTaskStatus> _localRevisionStatusOverrides = {};

  static const List<String> _base38Surahs = [
    'الفاتحة',
    'الناس',
    'الفلق',
    'الإخلاص',
    'المسد',
    'النصر',
    'الكافرون',
    'الكوثر',
    'الماعون',
    'قريش',
    'الفيل',
    'الهمزة',
    'العصر',
    'التكاثر',
    'القارعة',
    'العاديات',
    'الزلزلة',
    'البينة',
    'القدر',
    'العلق',
    'التين',
    'الشرح',
    'الضحى',
    'الليل',
    'الشمس',
    'البلد',
    'الفجر',
    'الغاشية',
    'الأعلى',
    'الطارق',
    'البروج',
    'الانشقاق',
    'المطففين',
    'الانفطار',
    'التكوير',
    'عبس',
    'النازعات',
    'النبأ',
  ];

  static const List<String> _extra10Surahs = [
    'المرسلات',
    'الإنسان',
    'القيامة',
    'المدثر',
    'المزمل',
    'الجن',
    'نوح',
    'المعارج',
    'الحاقة',
    'القلم',
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

  /// Builds the list of ChildPortalProfile items, merging live Firestore student profiles,
  /// enrollments, attendance logs, and Hifz assignments with the 3 Stitch sibling profiles.
  List<ChildPortalProfile> _buildChildProfiles({
    required List<StudentProfile> firestoreChildren,
    required String activeChildId,
    required List<Enrollment> activeEnrollments,
    required List<AttendanceLog> activeAttendance,
    required List<HifzAssignment> activeAssignments,
    required QuranMetadataService quranService,
  }) {
    // 1. Default Stitch Seed Child 1: إبراهيم (st-1042)
    final ibrahimFirestore =
        firestoreChildren.where((s) => s.id == 'st-1042').firstOrNull;
    final ibrahimProfile = _applyFirestoreOverrides(
      base: ChildPortalProfile(
        id: 'st-1042',
        shortName: 'إبراهيم',
        fullName: ibrahimFirestore?.fullName ?? 'إبراهيم طه عثمان',
        groupName: 'حلقة أبي بكر الصديق',
        teacherName: 'المعلم: أ. طارق العمري',
        periodLabel: 'الفترة المسائية (عصرًا)',
        attendancePercent: 98,
        streakBannerTitle: 'إبراهيم متميز هذا الأسبوع!',
        streakDaysLabel: '٥ أيام متتالية ⭐',
        memorizedPagesCount: 68,
        completedSurahsCount: 48,
        completedJuzCount: 1,
        completedJuzSubtitle: 'الجزء ٣٠ كاملًا ومُثبت',
        motivationalBannerHighlight: '48 سورة',
        motivationalBannerBody:
            'يسير بخطى واثقة ومباركة نحو إتمام الجزء الثاني بإذن الله.',
        lastRecitationTitle: 'سورة البقرة • الآيات (77 - 86)',
        lastRecitationNote: 'تقييم الشيخ: إتقان لأحكام المدود والغنة',
        lastRecitationScore: 'ممتاز ٩٨٪',
        lastRecitationDuration: '02:45 د',
        lastRecitationWhen: 'أمس في المسجد',
        inProgressSurahs: const [
          InProgressSurahData(
            surahNumber: 2,
            surahName: 'سورة البقرة',
            fromAyah: 1,
            toAyah: 86,
            totalVerses: 286,
            expectedCompletionLabel: 'منتصف شعبان',
          ),
        ],
        inProgressAjzaa: const [
          InProgressJuzData(
            juzNumber: 1,
            juzTitle: 'الجزء الأول (الم * ذلك الكتاب)',
            completedPages: 12,
            totalPages: 21,
            startedDateLabel: 'بدأ في 1 رجب',
            isActive: true,
          ),
          InProgressJuzData(
            juzNumber: 2,
            juzTitle: 'الجزء الثاني (سيقول السفهاء)',
            completedPages: 0,
            totalPages: 20,
            startedDateLabel: 'قيد التحضير',
            isActive: false,
          ),
        ],
        completedSurahNames: [..._base38Surahs, ..._extra10Surahs],
        weeklySchedule: const [
          ChildScheduleSlot(
            dayAbbrev: 'أح',
            dayName: 'الأحد',
            dateLabel: '١٨ أكتوبر',
            statusLabel: 'تم الحضور',
            isCompleted: true,
            trackBadgeLabel: 'مسار الحفظ المكثف',
            sessionModeLabel: 'جلسة فردية',
            isOneOnOne: true,
            arrivalTime: '16:00',
          ),
          ChildScheduleSlot(
            dayAbbrev: 'ث',
            dayName: 'الثلاثاء',
            dateLabel: '٢٠ أكتوبر',
            statusLabel: 'مجدول',
            isCompleted: false,
            trackBadgeLabel: 'مسار الحفظ المكثف',
            sessionModeLabel: 'حلقة جماعية',
            isOneOnOne: false,
            arrivalTime: '16:30',
          ),
          ChildScheduleSlot(
            dayAbbrev: 'خ',
            dayName: 'الخميس',
            dateLabel: '٢٢ أكتوبر',
            statusLabel: 'مجدول',
            isCompleted: false,
            trackBadgeLabel: 'مسار تربوي وتجويد',
            isTertiaryTrackBadge: true,
            sessionModeLabel: 'جلسة فردية',
            isOneOnOne: true,
            arrivalTime: '17:15',
          ),
        ],
        newHifzSurah: 'سورة النحل',
        newHifzAyahRange: 'الآيات (١ - ٣٥)',
        newHifzPagesLabel: 'الصفحات ٢٦٧ - ٢٧٠',
        newHifzProgress: 0.85,
        newHifzStatusLeft: 'إنجاز ٨٥٪ من المقرر',
        newHifzStatusRight: 'متبقي ٥ آيات للتثبيت',
        revisionSurah: 'سورة الحجر',
        revisionAyahRange: 'من الآية ١ إلى ٤٨',
        revisionHizbLabel: 'الحزب الثامن والعشرون',
        revisionProgress: 1.0,
        revisionStatusLeft: 'مكتمل بنجاح تام',
        revisionStatusRight: '٤٨ آية',
        weeklyGradeLabel: 'ممتاز (٩٨٪)',
        weeklyStarsCount: 5,
        teacherNoteAuthor: 'أستاذ طارق',
        teacherNoteText:
            '"ما شاء الله، إتقان متميز لمخارج الحروف والمدود في سورة النحل. يرجى التركيز في المراجعة المنزلية على ترقيق الراء المكسورة في سورة الحجر."',
        teacherVoiceDuration: '٠:٣٨ دقيقة',
        firestoreStudent: ibrahimFirestore,
      ),
      isSelected: activeChildId == 'st-1042',
      enrollments: activeEnrollments,
      attendance: activeAttendance,
      assignments: activeAssignments,
      quranService: quranService,
    );

    // 2. Stitch Seed Child 2: يوسف (st-1088)
    final yousefFirestore =
        firestoreChildren.where((s) => s.id == 'st-1088').firstOrNull;
    final yousefProfile = _applyFirestoreOverrides(
      base: ChildPortalProfile(
        id: 'st-1088',
        shortName: 'يوسف',
        fullName: yousefFirestore?.fullName ?? 'يوسف طه عثمان',
        groupName: 'حلقة الفجر للحفظ المكثف',
        teacherName: 'المعلم: الشيخ عبد الرحمن',
        periodLabel: 'الفترة المسائية (بعد المغرب)',
        attendancePercent: 95,
        streakBannerTitle: 'يوسف ملتزم بالمراجعة اليومية!',
        streakDaysLabel: '٤ أيام متتالية ⭐',
        memorizedPagesCount: 42,
        completedSurahsCount: 38,
        completedJuzCount: 2,
        completedJuzSubtitle: 'الجزء ٢٩ و ٣٠ كاملين',
        motivationalBannerHighlight: '38 سورة',
        motivationalBannerBody:
            'أتم حفظ جزء عمّ وتبارك بنجاح • يبدأ الآن في حفظ جزء قد سمع.',
        lastRecitationTitle: 'سورة المجادلة • الآيات (1 - 11)',
        lastRecitationNote: 'تقييم الشيخ: أحكام الإخفاء والمد المتصل متقنة',
        lastRecitationScore: 'جيد جدًا ٩٢٪',
        lastRecitationDuration: '03:10 د',
        lastRecitationWhen: 'الأحد الماضي',
        inProgressSurahs: const [
          InProgressSurahData(
            surahNumber: 58,
            surahName: 'سورة المجادلة',
            fromAyah: 1,
            toAyah: 11,
            totalVerses: 22,
            expectedCompletionLabel: 'نهاية الأسبوع',
          ),
        ],
        inProgressAjzaa: const [
          InProgressJuzData(
            juzNumber: 28,
            juzTitle: 'الجزء الثامن والعشرون (قد سمع الله)',
            completedPages: 8,
            totalPages: 20,
            startedDateLabel: 'بدأ في 10 رجب',
            isActive: true,
          ),
        ],
        completedSurahNames: _base38Surahs,
        weeklySchedule: const [
          ChildScheduleSlot(
            dayAbbrev: 'سب',
            dayName: 'السبت',
            dateLabel: '١٧ أكتوبر',
            statusLabel: 'تم الحضور',
            isCompleted: true,
            trackBadgeLabel: 'مسار الحفظ المكثف',
            sessionModeLabel: 'حلقة جماعية',
            isOneOnOne: false,
            arrivalTime: '17:00',
          ),
          ChildScheduleSlot(
            dayAbbrev: 'اث',
            dayName: 'الاثنين',
            dateLabel: '١٩ أكتوبر',
            statusLabel: 'مجدول',
            isCompleted: false,
            trackBadgeLabel: 'مسار الحفظ المكثف',
            sessionModeLabel: 'جلسة فردية',
            isOneOnOne: true,
            arrivalTime: '18:00',
          ),
          ChildScheduleSlot(
            dayAbbrev: 'أر',
            dayName: 'الأربعاء',
            dateLabel: '٢١ أكتوبر',
            statusLabel: 'مجدول',
            isCompleted: false,
            trackBadgeLabel: 'مسار الحفظ المكثف',
            sessionModeLabel: 'حلقة جماعية',
            isOneOnOne: false,
            arrivalTime: '17:00',
          ),
        ],
        newHifzSurah: 'سورة المجادلة',
        newHifzAyahRange: 'الآيات (١ - ١١)',
        newHifzPagesLabel: 'الصفحات ٥٤٢ - ٥٤٣',
        newHifzProgress: 0.70,
        newHifzStatusLeft: 'إنجاز ٧٠٪ من المقرر',
        newHifzStatusRight: 'متبقي ٣ آيات للتثبيت',
        revisionSurah: 'سورة الملك',
        revisionAyahRange: 'من الآية ١ إلى ٣٠',
        revisionHizbLabel: 'الجزء التاسع والعشرون',
        revisionProgress: 1.0,
        revisionStatusLeft: 'مكتمل بنجاح تام',
        revisionStatusRight: '٣٠ آية',
        weeklyGradeLabel: 'جيد جدًا (٩٢٪)',
        weeklyStarsCount: 5,
        teacherNoteAuthor: 'الشيخ عبد الرحمن',
        teacherNoteText:
            '"حفظ طيب ومتقن لسورة المجادلة، نرجو إعادة تلاوة الآية ٩ إلى ١١ ثلاث مرات لتثبيت المتشابهات."',
        teacherVoiceDuration: '٠:٤٥ دقيقة',
        firestoreStudent: yousefFirestore,
      ),
      isSelected: activeChildId == 'st-1088',
      enrollments: activeEnrollments,
      attendance: activeAttendance,
      assignments: activeAssignments,
      quranService: quranService,
    );

    // 3. Stitch Seed Child 3: مريم (st-1102)
    final maryamFirestore =
        firestoreChildren.where((s) => s.id == 'st-1102').firstOrNull;
    final maryamProfile = _applyFirestoreOverrides(
      base: ChildPortalProfile(
        id: 'st-1102',
        shortName: 'مريم',
        fullName: maryamFirestore?.fullName ?? 'مريم طه عثمان',
        groupName: 'حلقة البراعم النورانية',
        teacherName: 'المعلمة: أ. خديجة المنصور',
        periodLabel: 'الفترة المسائية (عصرًا)',
        attendancePercent: 100,
        streakBannerTitle: 'مريم نجمة الحلقة هذا الأسبوع!',
        streakDaysLabel: '٨ أيام متتالية ⭐',
        memorizedPagesCount: 22,
        completedSurahsCount: 37,
        completedJuzCount: 1,
        completedJuzSubtitle: 'جزء عمّ كاملًا ومُثبت',
        motivationalBannerHighlight: '37 سورة',
        motivationalBannerBody:
            'أتقنت جزء عمّ والقاعدة النورانية بتميز • تنتقل إلى تلاوة جزء تبارك.',
        lastRecitationTitle: 'سورة النبأ • الآيات (1 - 40)',
        lastRecitationNote: 'تقييم المعلمة: مخارج الحروف واضحة ومرتلة',
        lastRecitationScore: 'ممتاز ١٠٠٪',
        lastRecitationDuration: '02:15 د',
        lastRecitationWhen: 'اليوم في المركز',
        inProgressSurahs: const [
          InProgressSurahData(
            surahNumber: 67,
            surahName: 'سورة الملك',
            fromAyah: 1,
            toAyah: 15,
            totalVerses: 30,
            expectedCompletionLabel: 'الأسبوع القادم',
          ),
        ],
        inProgressAjzaa: const [
          InProgressJuzData(
            juzNumber: 29,
            juzTitle: 'الجزء التاسع والعشرون (تبارك الذي بيده الملك)',
            completedPages: 4,
            totalPages: 20,
            startedDateLabel: 'بدأ هذا الأسبوع',
            isActive: true,
          ),
        ],
        completedSurahNames: _base38Surahs,
        weeklySchedule: const [
          ChildScheduleSlot(
            dayAbbrev: 'أح',
            dayName: 'الأحد',
            dateLabel: '١٨ أكتوبر',
            statusLabel: 'تم الحضور',
            isCompleted: true,
            trackBadgeLabel: 'القاعدة النورانية',
            sessionModeLabel: 'حلقة جماعية',
            isOneOnOne: false,
            arrivalTime: '15:30',
          ),
          ChildScheduleSlot(
            dayAbbrev: 'خ',
            dayName: 'الخميس',
            dateLabel: '٢٢ أكتوبر',
            statusLabel: 'مجدول',
            isCompleted: false,
            trackBadgeLabel: 'القاعدة النورانية',
            sessionModeLabel: 'جلسة فردية',
            isOneOnOne: true,
            arrivalTime: '16:15',
          ),
        ],
        newHifzSurah: 'سورة الملك',
        newHifzAyahRange: 'الآيات (١ - ١٥)',
        newHifzPagesLabel: 'الصفحات ٥٦٢ - ٥٦٣',
        newHifzProgress: 0.90,
        newHifzStatusLeft: 'إنجاز ٩٠٪ من المقرر',
        newHifzStatusRight: 'متبقي آيتان للتثبيت',
        revisionSurah: 'سورة النبأ',
        revisionAyahRange: 'من الآية ١ إلى ٤٠',
        revisionHizbLabel: 'الجزء الثلاثون (عمّ)',
        revisionProgress: 1.0,
        revisionStatusLeft: 'مكتمل بنجاح تام',
        revisionStatusRight: '٤٠ آية',
        weeklyGradeLabel: 'ممتاز (١٠٠٪)',
        weeklyStarsCount: 5,
        teacherNoteAuthor: 'أستاذة خديجة',
        teacherNoteText:
            '"بارك الله في مريم، تلاوة خاشعة ومتميزة للدرس الحادي عشر في النورانية مع إتقان سورة النبأ."',
        teacherVoiceDuration: '٠:٣٢ دقيقة',
        firestoreStudent: maryamFirestore,
      ),
      isSelected: activeChildId == 'st-1102',
      enrollments: activeEnrollments,
      attendance: activeAttendance,
      assignments: activeAssignments,
      quranService: quranService,
    );

    final list = <ChildPortalProfile>[
      ibrahimProfile,
      yousefProfile,
      maryamProfile,
    ];

    // Also append any additional newly-created Firestore students not in the 3 seed IDs
    for (final s in firestoreChildren) {
      if (s.id != 'st-1042' && s.id != 'st-1088' && s.id != 'st-1102') {
        final firstName = s.fullName.trim().split(' ').first;
        list.add(
          _applyFirestoreOverrides(
            base: ChildPortalProfile(
              id: s.id,
              shortName: firstName.isNotEmpty ? firstName : s.fullName,
              fullName: s.fullName,
              groupName: 'حلقة دار الفجر التعليمية',
              teacherName: 'المعلم: الشيخ عبد الرحمن',
              periodLabel: 'الفترة المسائية (عصرًا)',
              attendancePercent: 96,
              streakBannerTitle: '$firstName متميز هذا الأسبوع!',
              streakDaysLabel: '٥ أيام متتالية ⭐',
              memorizedPagesCount: s.memorizedPages.isNotEmpty
                  ? s.memorizedPages.length
                  : 15,
              completedSurahsCount: s.completedSurahs.isNotEmpty
                  ? s.completedSurahs.length
                  : 12,
              completedJuzCount:
                  s.completedJuz.isNotEmpty ? s.completedJuz.length : 1,
              completedJuzSubtitle: 'الجزء ٣٠ كاملًا ومُثبت',
              motivationalBannerHighlight:
                  '${s.completedSurahs.isNotEmpty ? s.completedSurahs.length : 12} سورة',
              motivationalBannerBody:
                  'يسير بخطى واثقة ومباركة نحو إتمام خطته الشهرية بإذن الله.',
              lastRecitationTitle: 'سورة النبأ • الآيات (1 - 30)',
              lastRecitationNote: 'تقييم الشيخ: التزام ممتاز بأحكام التجويد',
              lastRecitationScore: 'ممتاز ٩٥٪',
              lastRecitationDuration: '02:20 د',
              lastRecitationWhen: 'هذا الأسبوع',
              inProgressSurahs: const [
                InProgressSurahData(
                  surahNumber: 78,
                  surahName: 'سورة النبأ',
                  fromAyah: 1,
                  toAyah: 30,
                  totalVerses: 40,
                  expectedCompletionLabel: 'هذا الأسبوع',
                ),
              ],
              inProgressAjzaa: const [
                InProgressJuzData(
                  juzNumber: 30,
                  juzTitle: 'الجزء الثلاثون (جزء عمّ)',
                  completedPages: 15,
                  totalPages: 20,
                  startedDateLabel: 'بدأ هذا الشهر',
                  isActive: true,
                ),
              ],
              completedSurahNames: _base38Surahs.take(12).toList(),
              weeklySchedule: ibrahimProfile.weeklySchedule,
              newHifzSurah: 'سورة النبأ',
              newHifzAyahRange: 'الآيات (١ - ٣٠)',
              newHifzPagesLabel: 'الصفحات ٥٨٢ - ٥٨٣',
              newHifzProgress: 0.75,
              newHifzStatusLeft: 'إنجاز ٧٥٪ من المقرر',
              newHifzStatusRight: 'متبقي ١٠ آيات للتثبيت',
              revisionSurah: 'سورة النازعات',
              revisionAyahRange: 'من الآية ١ إلى ٤٦',
              revisionHizbLabel: 'الجزء الثلاثون',
              revisionProgress: 1.0,
              revisionStatusLeft: 'مكتمل بنجاح تام',
              revisionStatusRight: '٤٦ آية',
              weeklyGradeLabel: 'ممتاز (٩٥٪)',
              teacherNoteAuthor: 'الشيخ عبد الرحمن',
              teacherNoteText: '"بارك الله في همته وحرصه المستمر على الحضور."',
              teacherVoiceDuration: '٠:٣٠ دقيقة',
              firestoreStudent: s,
            ),
            isSelected: activeChildId == s.id,
            enrollments: activeEnrollments,
            attendance: activeAttendance,
            assignments: activeAssignments,
            quranService: quranService,
          ),
        );
      }
    }

    return list;
  }

  /// Applies live Firestore `HifzAssignment` & `Enrollment` updates onto the child profile
  /// when a teacher assigns or grades new Hifz/Revision in Milestone 4!
  ChildPortalProfile _applyFirestoreOverrides({
    required ChildPortalProfile base,
    required bool isSelected,
    required List<Enrollment> enrollments,
    required List<AttendanceLog> attendance,
    required List<HifzAssignment> assignments,
    required QuranMetadataService quranService,
  }) {
    if (!isSelected) return base;

    final primaryEnr = enrollments.firstOrNull;
    final latestNewHifz = assignments
        .where((a) => a.type == AssignmentType.newHifz)
        .firstOrNull;
    final latestRevision = assignments
        .where((a) => a.type == AssignmentType.revision)
        .firstOrNull;

    String newHifzSurah = base.newHifzSurah;
    String newHifzAyahRange = base.newHifzAyahRange;
    String newHifzPagesLabel = base.newHifzPagesLabel;
    String teacherNoteText = base.teacherNoteText;
    String weeklyGradeLabel = base.weeklyGradeLabel;

    if (latestNewHifz != null) {
      newHifzSurah = latestNewHifz.surahName.isNotEmpty
          ? 'سورة ${latestNewHifz.surahName}'
          : base.newHifzSurah;
      newHifzAyahRange =
          'الآيات (${latestNewHifz.fromAyah} - ${latestNewHifz.toAyah})';
      final pages = latestNewHifz.touchedPages.isNotEmpty
          ? latestNewHifz.touchedPages
          : quranService.calculatePages(
              latestNewHifz.surahId,
              latestNewHifz.fromAyah,
              latestNewHifz.toAyah,
            );
      if (pages.isNotEmpty) {
        newHifzPagesLabel = pages.length == 1
            ? 'الصفحة ${pages.first}'
            : 'الصفحات ${pages.first} - ${pages.last}';
      }
      if (latestNewHifz.teacherNotes.trim().isNotEmpty) {
        teacherNoteText = '"${latestNewHifz.teacherNotes.trim()}"';
      }
      if (latestNewHifz.grade != EvaluationGrade.pending) {
        weeklyGradeLabel = '${latestNewHifz.grade.localizedName("ar")} (٩٨٪)';
      }
    }

    String revisionSurah = base.revisionSurah;
    String revisionAyahRange = base.revisionAyahRange;
    if (latestRevision != null) {
      revisionSurah = latestRevision.surahName.isNotEmpty
          ? 'سورة ${latestRevision.surahName}'
          : base.revisionSurah;
      revisionAyahRange =
          'من الآية ${latestRevision.fromAyah} إلى ${latestRevision.toAyah}';
    }

    // Calculate live memorized pages if Firestore student has more than seed
    final fsPagesCount = base.firestoreStudent?.memorizedPages.length ?? 0;
    final effectivePagesCount = fsPagesCount > base.memorizedPagesCount
        ? fsPagesCount
        : base.memorizedPagesCount;

    final fsSurahsCount = base.firestoreStudent?.completedSurahs.length ?? 0;
    final effectiveSurahsCount = fsSurahsCount > base.completedSurahsCount
        ? fsSurahsCount
        : base.completedSurahsCount;

    final fsJuzCount = base.firestoreStudent?.completedJuz.length ?? 0;
    final effectiveJuzCount =
        fsJuzCount > base.completedJuzCount ? fsJuzCount : base.completedJuzCount;

    return ChildPortalProfile(
      id: base.id,
      shortName: base.shortName,
      fullName: base.fullName,
      groupName: primaryEnr?.groupName.isNotEmpty == true
          ? primaryEnr!.groupName
          : base.groupName,
      teacherName: base.teacherName,
      periodLabel: base.periodLabel,
      attendancePercent: base.attendancePercent,
      streakBannerTitle: base.streakBannerTitle,
      streakDaysLabel: base.streakDaysLabel,
      memorizedPagesCount: effectivePagesCount,
      completedSurahsCount: effectiveSurahsCount,
      completedJuzCount: effectiveJuzCount,
      completedJuzSubtitle: base.completedJuzSubtitle,
      motivationalBannerHighlight: '$effectiveSurahsCount سورة',
      motivationalBannerBody: base.motivationalBannerBody,
      lastRecitationTitle: base.lastRecitationTitle,
      lastRecitationNote: base.lastRecitationNote,
      lastRecitationScore: base.lastRecitationScore,
      lastRecitationDuration: base.lastRecitationDuration,
      lastRecitationWhen: base.lastRecitationWhen,
      inProgressSurahs: base.inProgressSurahs,
      inProgressAjzaa: base.inProgressAjzaa,
      completedSurahNames: base.completedSurahNames,
      weeklySchedule: base.weeklySchedule,
      newHifzSurah: newHifzSurah,
      newHifzAyahRange: newHifzAyahRange,
      newHifzPagesLabel: newHifzPagesLabel,
      newHifzProgress: base.newHifzProgress,
      newHifzStatusLeft: base.newHifzStatusLeft,
      newHifzStatusRight: base.newHifzStatusRight,
      revisionSurah: revisionSurah,
      revisionAyahRange: revisionAyahRange,
      revisionHizbLabel: base.revisionHizbLabel,
      revisionProgress: base.revisionProgress,
      revisionStatusLeft: base.revisionStatusLeft,
      revisionStatusRight: base.revisionStatusRight,
      weeklyGradeLabel: weeklyGradeLabel,
      weeklyStarsCount: base.weeklyStarsCount,
      teacherNoteAuthor: base.teacherNoteAuthor,
      teacherNoteText: teacherNoteText,
      teacherVoiceDuration: base.teacherVoiceDuration,
      firestoreStudent: base.firestoreStudent,
      firestoreEnrollments: enrollments,
      firestoreAttendance: attendance,
      firestoreAssignments: assignments,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final langCode = currentLocale.languageCode;
    final isRtl = isRtlLocale(currentLocale);

    final appUser = ref.watch(currentAppUserProvider).asData?.value;
    final isStudentRole = appUser?.role == UserRole.student;

    final selectedChildId = ref.watch(selectedChildIdProvider);
    final selectedTab = ref.watch(parentStudentTabProvider);
    final acknowledgedSet = ref.watch(acknowledgedHomeworkProvider);
    final quranService = ref.watch(quranMetadataServiceProvider);

    final firestoreChildren =
        ref.watch(parentChildrenStreamProvider).asData?.value ?? const [];
    final activeEnrollments = ref
            .watch(childEnrollmentsStreamProvider(selectedChildId))
            .asData
            ?.value ??
        const [];
    final activeAttendance = ref
            .watch(childAttendanceStreamProvider(selectedChildId))
            .asData
            ?.value ??
        const [];
    final activeAssignments = ref
            .watch(childAssignmentsStreamProvider(selectedChildId))
            .asData
            ?.value ??
        const [];

    final childrenProfiles = _buildChildProfiles(
      firestoreChildren: firestoreChildren,
      activeChildId: selectedChildId,
      activeEnrollments: activeEnrollments,
      activeAttendance: activeAttendance,
      activeAssignments: activeAssignments,
      quranService: quranService,
    );

    final activeChild = childrenProfiles
            .where((c) => c.id == selectedChildId)
            .firstOrNull ??
        childrenProfiles.first;

    final isHomeworkSigned = acknowledgedSet.contains(activeChild.id);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _surface,
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
                      // TAB 0: الجدول والواجبات (Stitch Screen 2)
                      _buildScheduleAndHomeworkTab(
                        context: context,
                        langCode: langCode,
                        child: activeChild,
                        isHomeworkSigned: isHomeworkSigned,
                      ),

                      // TAB 1: ملخص التقدم (Stitch Screen 1)
                      _buildProgressSummaryTab(
                        context: context,
                        langCode: langCode,
                        child: activeChild,
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
                      color: _surface.withValues(alpha: 0.90),
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
                                        Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: _primary.withValues(alpha: 0.15),
                                                  width: 1.5,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: Image.asset(
                                                'assets/logo.png',
                                                fit: BoxFit.contain,
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
                                                  isStudentRole
                                                      ? _tr(
                                                          langCode,
                                                          ar: 'بوابة الطالب',
                                                          he: 'פורטל תלמיד',
                                                          en: 'Student Portal',
                                                        )
                                                      : _tr(
                                                          langCode,
                                                          ar: 'بوابة ولي الأمر',
                                                          he: 'פורטל הורים',
                                                          en: 'Parent Portal',
                                                        ),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        color: _primary,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                                  style: const TextStyle(
                                                    color: _outline,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        // Right Actions: Notifications + Account Avatar
                                        Row(
                                          children: [
                                            Material(
                                              color: _surfaceContainer,
                                              shape: const CircleBorder(),
                                              child: InkWell(
                                                customBorder:
                                                    const CircleBorder(),
                                                onTap: () {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        _tr(
                                                          langCode,
                                                          ar: 'تم تحديث تقييم الواجب الأسبوعي لـ ${activeChild.shortName}',
                                                          he: 'הערכת המטלה השבועית עודכנה',
                                                          en: 'Weekly evaluation updated for ${activeChild.shortName}',
                                                        ),
                                                      ),
                                                      backgroundColor: _primary,
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
                                                    color: _onSurface,
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
                                                message: _tr(
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
                                                    color: _primary,
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
                                                ? _primary
                                                : _surfaceContainerLowest,
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
                                                          : _outline,
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
                                                            : _onSurfaceVariant,
                                                      ),
                                                    ),
                                                    if (isSelected) ...[
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        width: 8,
                                                        height: 8,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color:
                                                              _secondaryContainer,
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

            // Fixed Translucent Bottom Navigation Bar (2 Tabs matching Stitch)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _surface.withValues(alpha: 0.92),
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
                                  _buildBottomNavTab(
                                    icon: Icons.menu_book_rounded,
                                    label: _tr(
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
                                  _buildBottomNavTab(
                                    icon: Icons.analytics_outlined,
                                    label: _tr(
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

  Widget _buildBottomNavTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected
          ? _primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 140,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? _primary : _onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? _primary : _onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 0: الجدول والواجبات (STITCH SCREEN 2)
  // ===========================================================================
  Widget _buildScheduleAndHomeworkTab({
    required BuildContext context,
    required String langCode,
    required ChildPortalProfile child,
    required bool isHomeworkSigned,
  }) {
    final topPadding = MediaQuery.paddingOf(context).top + 112 + 12;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 80 + 24;

    return ListView(
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: bottomPadding,
        left: 16,
        right: 16,
      ),
      children: [
        // 1. Child Quick Status Banner
        Container(
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                top: -24,
                left: -24,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: _primaryFixed.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: _primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  child.groupName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: _primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _primaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: _onPrimaryFixed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'حضور ${child.attendancePercent}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _onPrimaryFixed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.school_rounded,
                                size: 16,
                                color: _primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  child.teacherName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: _onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          child.periodLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _outline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Motivational Micro-Streak Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: _surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.workspace_premium_rounded,
                                  color: _secondary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    child.streakBannerTitle,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            child.streakDaysLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _secondary,
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
        const SizedBox(height: 16),

        // 2. Card 1: Weekly Arrival Schedule (مواعيد الحضور هذا الأسبوع)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _primaryContainer.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: _primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _tr(
                                  langCode,
                                  ar: 'مواعيد الحضور هذا الأسبوع',
                                  he: 'זמני הגעה השבוע',
                                  en: 'Weekly Arrival Schedule',
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: _onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _tr(
                                  langCode,
                                  ar: 'الأسبوع الدراسي الحالي (١٨ - ٢٢ أكتوبر)',
                                  he: 'שבוע הלימודים הנוכחי (18 - 22 באוקטובר)',
                                  en: 'Current Academic Week (Oct 18 - 22)',
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _tr(
                              langCode,
                              ar: 'جميع مواعيد ${child.shortName} محدثة حسب جدول المركز',
                              he: 'כל המועדים מעודכנים',
                              en: 'All schedule slots are synced with center calendar',
                            ),
                          ),
                          backgroundColor: _primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.event_repeat_rounded,
                      color: _primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Schedule List Rows
              ...child.weeklySchedule.map(
                (slot) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildScheduleSlotCard(slot),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Card 2: Current Weekly Assignment (واجب هذا الأسبوع)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Rating Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _primaryContainer.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: _primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _tr(
                                  langCode,
                                  ar: 'واجب هذا الأسبوع',
                                  he: 'מטלת השבוע',
                                  en: 'This Week\'s Assignment',
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: _onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _tr(
                                  langCode,
                                  ar: 'مقرر الإتقان والمراجعة الدورية',
                                  he: 'שינון וחזרה תקופתית',
                                  en: 'Hifz & Periodic Revision Syllabus',
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryFixed,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 15,
                          color: _primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'تم التقييم',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _onPrimaryFixed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Visual Quran Milestone Progress Container
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    // Item 1: New Memorization (الحفظ الجديد)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: _primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'الحفظ الجديد',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                child.newHifzPagesLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                child.newHifzSurah,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: _primary,
                                ),
                              ),
                              Text(
                                child.newHifzAyahRange,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: child.newHifzProgress,
                              minHeight: 8,
                              backgroundColor: _surfaceContainerHigh,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                _primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                child.newHifzStatusLeft,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _outline,
                                ),
                              ),
                              Text(
                                child.newHifzStatusRight,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Item 2: Revision (المراجعة والتثبيت)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: _secondaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'المراجعة والتثبيت',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                child.revisionHizbLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                child.revisionSurah,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: _onSurface,
                                ),
                              ),
                              Text(
                                child.revisionAyahRange,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: child.revisionProgress,
                              minHeight: 8,
                              backgroundColor: _surfaceContainerHigh,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                _secondaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                child.revisionStatusLeft,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _secondary,
                                ),
                              ),
                              Text(
                                child.revisionStatusRight,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Overall Grade Ribbon
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _primaryFixed.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: _primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'درجة الإتقان الأسبوعية',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _primary,
                              ),
                            ),
                            Text(
                              child.weeklyGradeLabel,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(
                        child.weeklyStarsCount,
                        (_) => const Icon(
                          Icons.star_rounded,
                          color: _secondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Highlighted Teacher Note & Voice Note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.format_quote_rounded,
                          color: _primary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ملاحظة المعلم (${child.teacherNoteAuthor}):',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: Text(
                        child.teacherNoteText,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.55,
                          color: _onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Audio Player Pill Micro-interaction
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Material(
                                color: _isPlayingTeacherVoice
                                    ? _secondary
                                    : _primary,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () {
                                    setState(() {
                                      _isPlayingTeacherVoice =
                                          !_isPlayingTeacherVoice;
                                    });
                                  },
                                  child: SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: Icon(
                                      _isPlayingTeacherVoice
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'توجيه صوتي من المعلم',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _onSurface,
                                    ),
                                  ),
                                  Text(
                                    'المدة: ${child.teacherVoiceDuration}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: _outline,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Waveform indicator bars
                          Row(
                            children: [
                              _buildWaveBar(height: 12),
                              const SizedBox(width: 3),
                              _buildWaveBar(height: 20),
                              const SizedBox(width: 3),
                              _buildWaveBar(height: 8),
                              const SizedBox(width: 3),
                              _buildWaveBar(height: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Direct Follow-up Action CTA
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        ref
                            .read(acknowledgedHomeworkProvider.notifier)
                            .markAcknowledged(child.id);
                        try {
                          await ref
                              .read(parentStudentRepositoryProvider)
                              .acknowledgeHomework(
                                studentId: child.id,
                                assignmentId:
                                    child.firestoreAssignments.firstOrNull?.id,
                              );
                        } catch (_) {}

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _tr(
                                langCode,
                                ar: 'تم تأكيد الاطلاع وتوقيع واجب ${child.shortName} بنجاح!',
                                he: 'המטלה אושרה ונחתמה בהצלחה!',
                                en: 'Homework acknowledged and signed!',
                              ),
                            ),
                            backgroundColor: _primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isHomeworkSigned ? _tertiaryContainer : _primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        isHomeworkSigned
                            ? Icons.task_alt_rounded
                            : Icons.verified_rounded,
                        size: 18,
                      ),
                      label: Text(
                        isHomeworkSigned
                            ? _tr(
                                langCode,
                                ar: 'تم توقيع الواجب والاطلاع ✓',
                                he: 'המטלה נחתמה ✓',
                                en: 'Homework Signed ✓',
                              )
                            : _tr(
                                langCode,
                                ar: 'تأكيد الاطلاع وتوقيع الواجب',
                                he: 'אישור וחתימה על המטלה',
                                en: 'Acknowledge & Sign Homework',
                              ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: _surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () =>
                          _showMessageTeacherSheet(context, langCode, child),
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.chat_outlined,
                          color: _onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Card 3: Weekly Revision Plan & Student Self-Check (خطة المراجعة الأسبوعية)
        _buildStudentWeeklyRevisionCard(
          context: context,
          langCode: langCode,
          child: child,
        ),
      ],
    );
  }

  Widget _buildStudentWeeklyRevisionCard({
    required BuildContext context,
    required String langCode,
    required ChildPortalProfile child,
  }) {
    final plans = ref
            .watch(studentWeeklyPlansProvider(child.id))
            .asData
            ?.value ??
        const [];
    final activePlan = plans.firstOrNull;

    final tasks = activePlan?.dailyTasks ??
        List<DailyRevisionTask>.generate(7, (idx) {
          if (idx == 5 || idx == 6) {
            return DailyRevisionTask(dayIndex: idx, isRestDay: true);
          }
          return DailyRevisionTask(
            dayIndex: idx,
            isRestDay: false,
            targetType: RevisionTargetType.juz,
            juzNumber: 30 - (idx % 2),
            status: idx < 2
                ? RevisionTaskStatus.doneOnTime
                : RevisionTaskStatus.pending,
          );
        });

    const dayNamesAr = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    const dayNamesEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const dayNamesHe = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת'];

    String getDayName(int idx) {
      if (langCode == 'he') return dayNamesHe[idx % 7];
      if (langCode == 'en') return dayNamesEn[idx % 7];
      return dayNamesAr[idx % 7];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primaryContainer.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.checklist_rtl_rounded,
                  color: _primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tr(
                        langCode,
                        ar: 'خطة المراجعة الأسبوعية اليومية',
                        he: 'תוכנית חזרה שבועית יומית',
                        en: 'Weekly Daily Revision Plan',
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _onSurface,
                      ),
                    ),
                    Text(
                      _tr(
                        langCode,
                        ar: 'اضغط لتحديد إنجاز ورد المراجعة اليومي (تم بالوقت / تم متأخراً)',
                        he: 'סמן ביצוע משימת חזרה יומית (בזמן / באיחור)',
                        en: 'Mark daily revision tasks as Done on Time or Done Late',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tasks.map((task) {
            final effectiveStatus =
                _localRevisionStatusOverrides[task.dayIndex] ?? task.status;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: task.isRestDay
                    ? _surfaceContainerLow
                    : _surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _surfaceContainerHigh),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: task.isRestDay
                                ? _surfaceContainerHigh
                                : _primaryFixed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            getDayName(task.dayIndex),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: task.isRestDay
                                  ? _onSurfaceVariant
                                  : _onPrimaryFixed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            task.displaySummary(langCode),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: task.isRestDay
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: task.isRestDay
                                  ? _outline
                                  : _onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!task.isRestDay)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _localRevisionStatusOverrides[task.dayIndex] =
                                  RevisionTaskStatus.doneOnTime;
                            });
                            if (activePlan != null) {
                              ref
                                  .read(teacherControllerProvider.notifier)
                                  .updateDailyRevisionTaskStatus(
                                    plan: activePlan,
                                    dayIndex: task.dayIndex,
                                    status: RevisionTaskStatus.doneOnTime,
                                  );
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: effectiveStatus ==
                                      RevisionTaskStatus.doneOnTime
                                  ? _primary
                                  : _surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _tr(
                                langCode,
                                ar: 'تم بالوقت',
                                he: 'בזמן',
                                en: 'Done',
                              ),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: effectiveStatus ==
                                        RevisionTaskStatus.doneOnTime
                                    ? Colors.white
                                    : _onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _localRevisionStatusOverrides[task.dayIndex] =
                                  RevisionTaskStatus.doneLate;
                            });
                            if (activePlan != null) {
                              ref
                                  .read(teacherControllerProvider.notifier)
                                  .updateDailyRevisionTaskStatus(
                                    plan: activePlan,
                                    dayIndex: task.dayIndex,
                                    status: RevisionTaskStatus.doneLate,
                                  );
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: effectiveStatus ==
                                      RevisionTaskStatus.doneLate
                                  ? _secondary
                                  : _surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _tr(
                                langCode,
                                ar: 'تم متأخراً',
                                he: 'באיחור',
                                en: 'Late',
                              ),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: effectiveStatus ==
                                        RevisionTaskStatus.doneLate
                                    ? Colors.white
                                    : _onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWaveBar({required double height}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 4,
      height: _isPlayingTeacherVoice ? height + 4 : height,
      decoration: BoxDecoration(
        color: _isPlayingTeacherVoice ? _secondary : _primary,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _buildScheduleSlotCard(ChildScheduleSlot slot) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: slot.isCompleted
                          ? _primaryFixedDim.withValues(alpha: 0.30)
                          : _surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      slot.dayAbbrev,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color:
                            slot.isCompleted ? _primary : _onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.dayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _onSurface,
                        ),
                      ),
                      Text(
                        slot.dateLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: slot.isCompleted ? _primaryFixed : _surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      slot.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.schedule_rounded,
                      size: 14,
                      color: slot.isCompleted
                          ? _onPrimaryFixed
                          : _onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      slot.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: slot.isCompleted
                            ? _onPrimaryFixed
                            : _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: slot.isTertiaryTrackBadge
                            ? _tertiaryFixed
                            : _surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        slot.trackBadgeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: slot.isTertiaryTrackBadge
                              ? _onTertiaryFixed
                              : _primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: slot.isOneOnOne
                            ? _secondaryFixed
                            : _surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            slot.isOneOnOne
                                ? Icons.person_rounded
                                : Icons.groups_rounded,
                            size: 13,
                            color: slot.isOneOnOne
                                ? _onSecondaryFixed
                                : _onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            slot.sessionModeLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: slot.isOneOnOne
                                  ? _onSecondaryFixed
                                  : _onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: _outline,
                    ),
                    const SizedBox(width: 4),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        slot.arrivalTime,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1: ملخص التقدم (STITCH SCREEN 1)
  // ===========================================================================
  Widget _buildProgressSummaryTab({
    required BuildContext context,
    required String langCode,
    required ChildPortalProfile child,
  }) {
    final topPadding = MediaQuery.paddingOf(context).top + 112 + 12;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 80 + 24;

    final displayedSurahs = _showAllCompletedSurahs
        ? child.completedSurahNames
        : child.completedSurahNames.take(38).toList();

    return ListView(
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: bottomPadding,
        left: 16,
        right: 16,
      ),
      children: [
        // 1. Motivational Banner Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _secondaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: _secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _secondaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: _onSecondaryFixedVariant,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'إنجاز مبارك',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _onSecondaryFixedVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'محدث اليوم',
                          style: TextStyle(
                            fontSize: 11,
                            color: _outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13.5,
                              color: _onSurface,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                        children: [
                          const TextSpan(text: 'ختم '),
                          TextSpan(
                            text: child.motivationalBannerHighlight,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _primary,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' حتى الآن • ${child.motivationalBannerBody}',
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
        const SizedBox(height: 14),

        // 2. Top KPI Grid (2x2 Compact Bento)
        Row(
          children: [
            Expanded(
              child: _buildBentoStatCard(
                title: 'الصفحات المحفوظة',
                icon: Icons.menu_book_rounded,
                iconBg: _surfaceContainer,
                iconColor: _primary,
                mainValue: '${child.memorizedPagesCount}',
                unitLabel: 'صفحة',
                subtitle: 'من أصل 604 صفحة',
                progressFraction: child.memorizedPagesCount / 604.0,
                progressColor: _primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoStatCard(
                title: 'نسبة الإنجاز',
                icon: Icons.pie_chart_rounded,
                iconBg: _primaryFixed,
                iconColor: _primary,
                mainValue:
                    '${child.overallQuranPercentage.toStringAsFixed(1)}%',
                mainValueColor: _primary,
                subtitle: 'من إجمالي المصحف الشريف',
                progressFraction: child.memorizedPagesCount / 604.0,
                progressColor: _primaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBentoStatCard(
                title: 'السور المكتملة',
                icon: Icons.military_tech_rounded,
                iconBg: _secondaryFixed,
                iconColor: _secondary,
                mainValue: '${child.completedSurahsCount}',
                unitLabel: 'سورة',
                subtitle: 'من 114 سورة كريمة',
                progressFraction: child.surahsProgressFraction,
                progressColor: _secondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoStatCard(
                title: 'الأجزاء المكتملة',
                icon: Icons.bookmark_added_rounded,
                iconBg: _surfaceContainer,
                iconColor: _tertiary,
                mainValue: '${child.completedJuzCount}',
                unitLabel: 'جزء تام',
                subtitle: child.completedJuzSubtitle,
                progressFraction: child.juzProgressFraction,
                progressColor: _tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 3. Interactive Visual Progress Meter & Recitation Audio Feature
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primary, _primaryContainer],
              begin: AlignmentDirectional.centerEnd,
              end: AlignmentDirectional.centerStart,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.headphones_rounded,
                        color: _primaryFixed,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'آخر تسميع مسجّل',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      child.lastRecitationWhen,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _primaryFixed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          setState(() {
                            _isPlayingLastRecitation =
                                !_isPlayingLastRecitation;
                          });
                        },
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            _isPlayingLastRecitation
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: _primary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.lastRecitationTitle,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            child.lastRecitationNote,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          child.lastRecitationScore,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _secondaryFixed,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          child.lastRecitationDuration,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Card 2: In-Progress Surahs (السور قيد الحفظ)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.cached_rounded,
                          color: _primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'السور قيد الحفظ',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _onSurface,
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
                      color: _surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'جاري العمل',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...child.inProgressSurahs.map(
                (surah) => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: _primaryFixed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _onPrimaryFixed,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    surah.surahName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${surah.progressPercent}% (الآية ${surah.fromAyah} إلى ${surah.toAyah})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: surah.progressFraction,
                          minHeight: 10,
                          backgroundColor: _surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            _primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.edit_calendar_rounded,
                                size: 14,
                                color: _outline,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'المتبقي: ${surah.remainingVerses} آية',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _outline,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.event_available_rounded,
                                size: 14,
                                color: _secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'المتوقع: ${surah.expectedCompletionLabel}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 5. Card 3: In-Progress Ajzaa (الأجزاء قيد الحفظ)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: _primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'الأجزاء قيد الحفظ',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: _onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'مخطط الإتمام لعام 1446هـ',
                    style: TextStyle(
                      fontSize: 11,
                      color: _outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...child.inProgressAjzaa.map((juz) {
                if (juz.isActive) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.trip_origin_rounded,
                                      size: 18,
                                      color: _primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        juz.juzTitle,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: _onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${juz.progressPercent}% (${juz.completedPages} من ${juz.totalPages} صفحة)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: juz.progressFraction,
                              minHeight: 10,
                              backgroundColor: _surfaceContainerHighest,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                _primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                juz.startedDateLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _outline,
                                ),
                              ),
                              Text(
                                'متبقي ${juz.remainingPages} صفحات فقط',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _surface.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.radio_button_unchecked_rounded,
                              size: 18,
                              color: _outline,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                juz.juzTitle,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'قيد التحضير (0%)',
                          style: TextStyle(
                            fontSize: 11,
                            color: _outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 6. Card 4: Finished Surahs Tag Cloud (السور المكتملة)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: _primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'السور المكتملة',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _onSurface,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryFixed,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${child.completedSurahsCount} سورة مُتقنة',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _onPrimaryFixed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'تشمل سورة الفاتحة وجزء عمّ كاملاً بفضل الله، مع ثبوت التلاوة وأحكام التجويد:',
                style: TextStyle(
                  fontSize: 13,
                  color: _outline,
                ),
              ),
              const SizedBox(height: 12),

              // Emerald Tag Cloud
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...displayedSurahs.map(
                    (surahName) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _surfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        surahName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _primary,
                        ),
                      ),
                    ),
                  ),
                  if (child.completedSurahNames.length > 38)
                    Material(
                      color: _showAllCompletedSurahs
                          ? _tertiaryContainer
                          : _primary,
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {
                          setState(() {
                            _showAllCompletedSurahs = !_showAllCompletedSurahs;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _showAllCompletedSurahs
                                    ? 'تم عرض السور الـ ${child.completedSurahNames.length}'
                                    : '+${child.completedSurahNames.length - 38} سور أخرى',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                _showAllCompletedSurahs
                                    ? Icons.check_rounded
                                    : Icons.expand_more_rounded,
                                size: 14,
                                color: Colors.white,
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
        ),
        const SizedBox(height: 16),

        // 7. Weekly Review Schedule Reminder
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _secondaryFixed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.event_repeat_rounded,
                      color: _secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'جلسة مراجعة الحزب الأخير',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _onSurface,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'الخميس القادم بعد صلاة العصر',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: _outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Material(
                color: _isReminderEnabled ? _primaryFixed : _surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      _isReminderEnabled = !_isReminderEnabled;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isReminderEnabled
                              ? 'تم تفعيل التذكير لجلسة مراجعة الخميس القادم'
                              : 'تم إلغاء التذكير',
                        ),
                        backgroundColor: _primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    child: Text(
                      _isReminderEnabled ? 'مفعّل ✓' : 'تذكير',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            _isReminderEnabled ? _onPrimaryFixed : _onSurface,
                      ),
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

  Widget _buildBentoStatCard({
    required String title,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String mainValue,
    String? unitLabel,
    Color? mainValueColor,
    required String subtitle,
    required double progressFraction,
    required Color progressColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                mainValue,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: mainValueColor ?? _onSurface,
                  height: 1.1,
                ),
              ),
              if (unitLabel != null) ...[
                const SizedBox(width: 4),
                Text(
                  unitLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _outline,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: _outline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressFraction.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: _surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageTeacherSheet(
    BuildContext context,
    String langCode,
    ChildPortalProfile child,
  ) {
    final msgCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text(
          _tr(
            langCode,
            ar: 'مراسلة المعلم (${child.teacherNoteAuthor})',
            he: 'שליחת הודעה למורה',
            en: 'Message Teacher (${child.teacherNoteAuthor})',
          ),
        ),
        content: TextField(
          controller: msgCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: _tr(
              langCode,
              ar: 'اكتب ملاحظتك أو استفسارك حول متابعة ${child.shortName}...',
              he: 'כתוב הודעה למורה...',
              en: 'Write your note regarding ${child.shortName}...',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: Text(_tr(langCode, ar: 'إلغاء', he: 'ביטול', en: 'Cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DarAlFajrTheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dlgCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _tr(
                      langCode,
                      ar: 'تم إرسال رسالتك إلى ${child.teacherNoteAuthor} بنجاح',
                      he: 'ההודעה נשלחה בהצלחה',
                      en: 'Message sent to ${child.teacherNoteAuthor}',
                    ),
                  ),
                  backgroundColor: _primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(_tr(langCode, ar: 'إرسال', he: 'שלח', en: 'Send')),
          ),
        ],
      ),
    );
  }
}
