import 'package:flutter/widgets.dart';

import '../../../core/services/quran_metadata_service.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../../admin/models/admin_models.dart';
import '../../hifz/models/teacher_models.dart';
import '../models/parent_student_models.dart';
import 'parent_student_tokens.dart';

const List<String> _base38Surahs = [
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

const List<String> _extra10Surahs = [
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

/// Builds [ChildPortalProfile] items from Firestore student profiles, enrollments,
/// attendance logs, and Hifz assignments (falling back to the 3 sibling demo
/// profiles only when [isDemoMode] is true).
List<ChildPortalProfile> buildParentChildProfiles({
  required List<StudentProfile> firestoreChildren,
  required String activeChildId,
  required List<Enrollment> activeEnrollments,
  required List<AttendanceLog> activeAttendance,
  required List<HifzAssignment> activeAssignments,
  required QuranMetadataService quranService,
  required String langCode,
  required bool isDemoMode,
  DateTime? referenceDate,
}) {
  final now = referenceDate ?? DateTime.now();
  final list = <ChildPortalProfile>[];
  ChildScheduleSlot? demoTemplateSlot;

  if (isDemoMode) {
    // 1. Default Stitch Seed Child 1: إبراهيم (st-1042)
    final ibrahimFirestore =
        firestoreChildren.where((s) => s.id == 'st-1042').firstOrNull;
    final ibrahimProfile = applyChildFirestoreOverrides(
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
        weeklySchedule: [
          ChildScheduleSlot(
            dayAbbrev: 'أح',
            dayName: 'الأحد',
            dateLabel: formatParentWeekDayLabel(now, 0, langCode),
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
            dateLabel: formatParentWeekDayLabel(now, 2, langCode),
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
            dateLabel: formatParentWeekDayLabel(now, 4, langCode),
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
      langCode: langCode,
      isDemoMode: true,
    );

    // 2. Stitch Seed Child 2: يوسف (st-1088)
    final yousefFirestore =
        firestoreChildren.where((s) => s.id == 'st-1088').firstOrNull;
    final yousefProfile = applyChildFirestoreOverrides(
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
        weeklySchedule: [
          ChildScheduleSlot(
            dayAbbrev: 'سب',
            dayName: 'السبت',
            dateLabel: formatParentWeekDayLabel(now, -1, langCode),
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
            dateLabel: formatParentWeekDayLabel(now, 1, langCode),
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
            dateLabel: formatParentWeekDayLabel(now, 3, langCode),
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
      langCode: langCode,
      isDemoMode: true,
    );

    // 3. Stitch Seed Child 3: مريم (st-1102)
    final maryamFirestore =
        firestoreChildren.where((s) => s.id == 'st-1102').firstOrNull;
    final maryamProfile = applyChildFirestoreOverrides(
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
        weeklySchedule: [
          ChildScheduleSlot(
            dayAbbrev: 'أح',
            dayName: 'الأحد',
            dateLabel: formatParentWeekDayLabel(now, 0, langCode),
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
            dateLabel: formatParentWeekDayLabel(now, 4, langCode),
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
      langCode: langCode,
      isDemoMode: true,
    );

    demoTemplateSlot = ibrahimProfile.weeklySchedule.firstOrNull;
    list.addAll([
      ibrahimProfile,
      yousefProfile,
      maryamProfile,
    ]);
  }

  // Append real Firestore students (all students in live mode, or non-seed IDs in demo mode)
  for (final s in firestoreChildren) {
    final isSeedId =
        s.id == 'st-1042' || s.id == 'st-1088' || s.id == 'st-1102';
    if (!isDemoMode || !isSeedId) {
      final nameParts = s.fullName.trim().split(RegExp(r'\s+'));
      final firstName = nameParts.isNotEmpty && nameParts.first.isNotEmpty
          ? nameParts.first
          : s.fullName;
      final completedNames = s.completedSurahs
          .map((id) => quranService.getSurahById(id)?.name)
          .whereType<String>()
          .toList();

      list.add(
        applyChildFirestoreOverrides(
          base: ChildPortalProfile(
            id: s.id,
            shortName: firstName.isNotEmpty ? firstName : s.fullName,
            fullName: s.fullName,
            groupName: trByLang(
              langCode,
              ar: 'بانتظار التسجيل في حلقة',
              he: 'ממתין לשיבוץ בקבוצה',
              en: 'Not enrolled in a group yet',
            ),
            teacherName: '',
            periodLabel: '',
            attendancePercent: 0,
            streakBannerTitle: s.fullName,
            streakDaysLabel: '—',
            memorizedPagesCount: s.memorizedPages.length,
            completedSurahsCount: s.completedSurahs.length,
            completedJuzCount: s.completedJuz.length,
            completedJuzSubtitle: '${s.completedJuz.length} / 30',
            motivationalBannerHighlight:
                '${s.completedSurahs.length} ${trByLang(langCode, ar: 'سورة', he: 'סורות', en: 'Surahs')}',
            motivationalBannerBody: trByLang(
              langCode,
              ar: 'بيانات التقدم محدّثة تلقائيًا من جلسات التسميع.',
              he: 'נתוני ההתקדמות מתעדכנים אוטומטית ממפגשי השינון.',
              en: 'Progress is updated automatically from Tasmee\' sessions.',
            ),
            lastRecitationTitle: '—',
            lastRecitationNote: trByLang(
              langCode,
              ar: 'لا توجد جلسة تسميع مقيمة بعد',
              he: 'אין עדיין הערכת שינון',
              en: 'No evaluated recitation yet',
            ),
            lastRecitationScore: '—',
            lastRecitationDuration: '',
            lastRecitationWhen: '—',
            inProgressSurahs: const [],
            inProgressAjzaa: const [],
            completedSurahNames: completedNames,
            weeklySchedule: demoTemplateSlot != null
                ? [demoTemplateSlot]
                : const [],
            newHifzSurah: '—',
            newHifzAyahRange: '',
            newHifzPagesLabel: '',
            newHifzProgress: 0.0,
            newHifzStatusLeft: trByLang(
              langCode,
              ar: 'لا يوجد واجب جديد مسجّل',
              he: 'לא הוקצתה מטלה חדשה',
              en: 'No active homework assigned',
            ),
            newHifzStatusRight: '',
            revisionSurah: '—',
            revisionAyahRange: '',
            revisionHizbLabel: '',
            revisionProgress: 0.0,
            revisionStatusLeft: trByLang(
              langCode,
              ar: 'لا توجد مراجعة مسجّلة',
              he: 'לא הוקצתה חזרה',
              en: 'No revision assigned',
            ),
            revisionStatusRight: '',
            weeklyGradeLabel: '—',
            weeklyStarsCount: 0,
            teacherNoteAuthor: '',
            teacherNoteText: trByLang(
              langCode,
              ar: 'لا توجد ملاحظات معلم بعد.',
              he: 'אין הערות מורה עדיין.',
              en: 'No teacher notes yet.',
            ),
            teacherVoiceDuration: '',
            firestoreStudent: s,
          ),
          isSelected: activeChildId == s.id,
          enrollments: activeEnrollments,
          attendance: activeAttendance,
          assignments: activeAssignments,
          quranService: quranService,
          langCode: langCode,
          isDemoMode: isDemoMode,
        ),
      );
    }
  }

  return list;
}

/// Applies live Firestore `HifzAssignment`, `AttendanceLog`, & `Enrollment`
/// updates onto [base] when [isSelected] is true.
ChildPortalProfile applyChildFirestoreOverrides({
  required ChildPortalProfile base,
  required bool isSelected,
  required List<Enrollment> enrollments,
  required List<AttendanceLog> attendance,
  required List<HifzAssignment> assignments,
  required QuranMetadataService quranService,
  String langCode = 'ar',
  required bool isDemoMode,
}) {
  if (!isSelected) return base;

  final primaryEnr = enrollments.firstOrNull;
  final latestNewHifz =
      assignments.where((a) => a.type == AssignmentType.newHifz).firstOrNull;
  final latestRevision =
      assignments.where((a) => a.type == AssignmentType.revision).firstOrNull;
  final latestGraded =
      assignments.where((a) => a.grade != EvaluationGrade.pending).firstOrNull;

  String newHifzSurah = base.newHifzSurah;
  String newHifzAyahRange = base.newHifzAyahRange;
  String newHifzPagesLabel = base.newHifzPagesLabel;
  double newHifzProgress = base.newHifzProgress;
  String newHifzStatusLeft = base.newHifzStatusLeft;
  String newHifzStatusRight = base.newHifzStatusRight;
  String teacherNoteText = base.teacherNoteText;
  String weeklyGradeLabel = base.weeklyGradeLabel;
  List<InProgressSurahData> inProgressSurahs = base.inProgressSurahs;

  if (latestNewHifz != null) {
    final surahInfo = quranService.getSurahById(latestNewHifz.surahId);
    final resolvedName = latestNewHifz.surahName.isNotEmpty
        ? latestNewHifz.surahName
        : (surahInfo?.name ?? '');
    newHifzSurah =
        resolvedName.isNotEmpty ? 'سورة $resolvedName' : base.newHifzSurah;
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
    final totalVerses = surahInfo?.totalVerses ?? latestNewHifz.toAyah;
    if (totalVerses > 0) {
      newHifzProgress = (latestNewHifz.toAyah / totalVerses).clamp(0.0, 1.0);
      final pct = (newHifzProgress * 100).round();
      final remaining = (totalVerses - latestNewHifz.toAyah).clamp(0, totalVerses);
      newHifzStatusLeft = 'إنجاز $pct%';
      newHifzStatusRight = remaining > 0 ? 'متبقي $remaining آية' : 'مكتمل';
      if (!isDemoMode) {
        inProgressSurahs = [
          InProgressSurahData(
            surahNumber: latestNewHifz.surahId,
            surahName: newHifzSurah,
            fromAyah: latestNewHifz.fromAyah,
            toAyah: latestNewHifz.toAyah,
            totalVerses: totalVerses,
            expectedCompletionLabel: latestNewHifz.grade.localizedName(langCode),
          ),
        ];
      }
    }
    if (latestNewHifz.teacherNotes.trim().isNotEmpty) {
      teacherNoteText = '"${latestNewHifz.teacherNotes.trim()}"';
    }
    if (latestNewHifz.grade != EvaluationGrade.pending) {
      weeklyGradeLabel = latestNewHifz.score != null
          ? '${latestNewHifz.grade.localizedName(langCode)} (${latestNewHifz.score}%)'
          : latestNewHifz.grade.localizedName(langCode);
    }
  }

  String revisionSurah = base.revisionSurah;
  String revisionAyahRange = base.revisionAyahRange;
  String revisionHizbLabel = base.revisionHizbLabel;
  double revisionProgress = base.revisionProgress;
  String revisionStatusLeft = base.revisionStatusLeft;
  String revisionStatusRight = base.revisionStatusRight;
  if (latestRevision != null) {
    final surahInfo = quranService.getSurahById(latestRevision.surahId);
    final resolvedName = latestRevision.surahName.isNotEmpty
        ? latestRevision.surahName
        : (surahInfo?.name ?? '');
    revisionSurah =
        resolvedName.isNotEmpty ? 'سورة $resolvedName' : base.revisionSurah;
    revisionAyahRange =
        'من الآية ${latestRevision.fromAyah} إلى ${latestRevision.toAyah}';
    if (latestRevision.juzNumber != null) {
      revisionHizbLabel = 'الجزء ${latestRevision.juzNumber}';
    }
    final ayahSpan =
        (latestRevision.toAyah - latestRevision.fromAyah + 1).clamp(0, 300);
    revisionProgress =
        latestRevision.grade != EvaluationGrade.pending ? 1.0 : 0.0;
    revisionStatusLeft = latestRevision.grade.localizedName(langCode);
    revisionStatusRight = '$ayahSpan آية';
  }

  final liveSchedule = <ChildScheduleSlot>[];
  for (final enr in enrollments) {
    final trackLabel = enr.track.localizedName(langCode);
    if (enr.groupArrivalTime != null && enr.groupArrivalTime!.trim().isNotEmpty) {
      liveSchedule.add(
        ChildScheduleSlot(
          dayAbbrev: enr.groupName.isNotEmpty ? enr.groupName.characters.first : 'ح',
          dayName: enr.groupName,
          dateLabel: enr.groupArrivalTime!.trim(),
          statusLabel: '',
          isCompleted: false,
          trackBadgeLabel: trackLabel,
          isTertiaryTrackBadge: false,
          sessionModeLabel: trByLang(
            langCode,
            ar: 'حلقة جماعية',
            he: 'שיעור קבוצתי',
            en: 'Group Session',
          ),
          isOneOnOne: false,
          arrivalTime: enr.groupArrivalTime!.trim(),
        ),
      );
    }
    if (enr.oneOnOneSlotTime != null && enr.oneOnOneSlotTime!.trim().isNotEmpty) {
      liveSchedule.add(
        ChildScheduleSlot(
          dayAbbrev: '1:1',
          dayName: enr.groupName,
          dateLabel: enr.oneOnOneSlotTime!.trim(),
          statusLabel: '',
          isCompleted: false,
          trackBadgeLabel: trackLabel,
          isTertiaryTrackBadge: true,
          sessionModeLabel: trByLang(
            langCode,
            ar: 'تسميع فردي',
            he: 'שינון אישי',
            en: '1-on-1 Recitation',
          ),
          isOneOnOne: true,
          arrivalTime: enr.oneOnOneSlotTime!.trim(),
        ),
      );
    }
  }

  final int attendancePercent;
  final String streakDaysLabel;
  if (attendance.isNotEmpty) {
    final attended = attendance
        .where(
          (a) =>
              a.status == AttendanceStatus.present ||
              a.status == AttendanceStatus.late,
        )
        .length;
    attendancePercent = ((attended / attendance.length) * 100).round();
    streakDaysLabel = '$attended / ${attendance.length}';
  } else {
    attendancePercent = base.attendancePercent;
    streakDaysLabel = base.streakDaysLabel;
  }

  String lastRecitationTitle = base.lastRecitationTitle;
  String lastRecitationNote = base.lastRecitationNote;
  String lastRecitationScore = base.lastRecitationScore;
  if (!isDemoMode && latestGraded != null) {
    final surahLabel = latestGraded.surahName.isNotEmpty
        ? 'سورة ${latestGraded.surahName}'
        : (quranService.getSurahById(latestGraded.surahId)?.name ?? '');
    lastRecitationTitle =
        '$surahLabel • (${latestGraded.fromAyah} - ${latestGraded.toAyah})';
    lastRecitationNote = latestGraded.teacherNotes.isNotEmpty
        ? latestGraded.teacherNotes
        : latestGraded.grade.localizedName(langCode);
    lastRecitationScore = latestGraded.score != null
        ? '${latestGraded.grade.localizedName(langCode)} ${latestGraded.score}%'
        : latestGraded.grade.localizedName(langCode);
  }

  final fsPagesCount = base.firestoreStudent?.memorizedPages.length ?? 0;
  final effectivePagesCount = isDemoMode
      ? (fsPagesCount > base.memorizedPagesCount
          ? fsPagesCount
          : base.memorizedPagesCount)
      : fsPagesCount;

  final fsSurahsCount = base.firestoreStudent?.completedSurahs.length ?? 0;
  final effectiveSurahsCount = isDemoMode
      ? (fsSurahsCount > base.completedSurahsCount
          ? fsSurahsCount
          : base.completedSurahsCount)
      : fsSurahsCount;

  final fsJuzCount = base.firestoreStudent?.completedJuz.length ?? 0;
  final effectiveJuzCount = isDemoMode
      ? (fsJuzCount > base.completedJuzCount
          ? fsJuzCount
          : base.completedJuzCount)
      : fsJuzCount;

  return ChildPortalProfile(
    id: base.id,
    shortName: base.shortName,
    fullName: base.fullName,
    groupName: primaryEnr?.groupName.isNotEmpty == true
        ? primaryEnr!.groupName
        : base.groupName,
    teacherName: base.teacherName,
    periodLabel: primaryEnr != null
        ? primaryEnr.track.localizedName(langCode)
        : base.periodLabel,
    attendancePercent: attendancePercent,
    streakBannerTitle: base.streakBannerTitle,
    streakDaysLabel: streakDaysLabel,
    memorizedPagesCount: effectivePagesCount,
    completedSurahsCount: effectiveSurahsCount,
    completedJuzCount: effectiveJuzCount,
    completedJuzSubtitle: base.completedJuzSubtitle,
    motivationalBannerHighlight:
        '$effectiveSurahsCount ${trByLang(langCode, ar: 'سورة', he: 'סורות', en: 'Surahs')}',
    motivationalBannerBody: base.motivationalBannerBody,
    lastRecitationTitle: lastRecitationTitle,
    lastRecitationNote: lastRecitationNote,
    lastRecitationScore: lastRecitationScore,
    lastRecitationDuration: base.lastRecitationDuration,
    lastRecitationWhen: base.lastRecitationWhen,
    inProgressSurahs: inProgressSurahs,
    inProgressAjzaa: base.inProgressAjzaa,
    completedSurahNames: base.completedSurahNames,
    weeklySchedule: liveSchedule.isNotEmpty ? liveSchedule : base.weeklySchedule,
    newHifzSurah: newHifzSurah,
    newHifzAyahRange: newHifzAyahRange,
    newHifzPagesLabel: newHifzPagesLabel,
    newHifzProgress: newHifzProgress,
    newHifzStatusLeft: newHifzStatusLeft,
    newHifzStatusRight: newHifzStatusRight,
    revisionSurah: revisionSurah,
    revisionAyahRange: revisionAyahRange,
    revisionHizbLabel: revisionHizbLabel,
    revisionProgress: revisionProgress,
    revisionStatusLeft: revisionStatusLeft,
    revisionStatusRight: revisionStatusRight,
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
