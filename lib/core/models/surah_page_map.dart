/// Complete 114-Surah to Pages distribution map following Dar al-Fajr Center rules:
/// - Surahs 1 to 77 (Juz 1 to 29): Each Surah covers its inclusive Madani Mushaf
///   page range `[startPage .. endPage]`. Shared boundary pages are included in both Surahs.
/// - Surahs 78 to 114 (Juz 30 - جزء عمّ): Each Surah is counted as 1 center page unit
///   and graded as a complete Surah.
class SurahPageDefinition {
  final int id;
  final String nameAr;
  final String nameEn;
  final String nameHe;
  final int primaryJuz;
  final int totalVerses;
  final int startPage;
  final int endPage;

  const SurahPageDefinition({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.nameHe,
    required this.primaryJuz,
    required this.totalVerses,
    required this.startPage,
    required this.endPage,
  });

  /// Whether this Surah belongs to Juz 30 (where each Surah counts as 1 page unit).
  bool get isJuz30 => id >= 78;

  /// Inclusive list of Madani Mushaf pages covered by this Surah.
  List<int> get pages => List<int>.generate(
        endPage - startPage + 1,
        (index) => startPage + index,
      );

  /// Number of pages counted in Dar al-Fajr Center's progress system:
  /// - Juz 30 Surahs (78-114) = 1 page each
  /// - Surahs 1-77 = inclusive page count (endPage - startPage + 1)
  int get centerPageCount => isJuz30 ? 1 : (endPage - startPage + 1);

  String localizedName(String langCode) {
    switch (langCode) {
      case 'he':
        return nameHe;
      case 'en':
        return nameEn;
      case 'ar':
      default:
        return nameAr;
    }
  }
}

class CenterQuranMap {
  CenterQuranMap._();

  /// Total center page units across all 114 Surahs (620 in Juz 1-29 + 37 in Juz 30 = 657).
  static int get totalCenterPages =>
      surahs.fold<int>(0, (sum, s) => sum + s.centerPageCount);

  static SurahPageDefinition getSurahById(int id) {
    return surahs.firstWhere(
      (s) => s.id == id,
      orElse: () => surahs.first,
    );
  }

  static List<SurahPageDefinition> getSurahsByJuz(int juz) {
    return surahs.where((s) => s.primaryJuz == juz).toList();
  }

  /// Standard Madani Mushaf Juz' start pages (Juz 1 to 30).
  static const List<int> juzStartPages = [
    1, 22, 42, 62, 82, 102, 122, 142, 162, 182,
    202, 222, 242, 262, 282, 302, 322, 342, 362, 382,
    402, 422, 442, 462, 482, 502, 522, 542, 562, 582,
  ];

  /// Returns the inclusive start and end Mushaf pages for a given Juz' (1-30).
  static ({int startPage, int endPage}) getJuzPageRange(int juz) {
    final clamped = juz.clamp(1, 30);
    final start = juzStartPages[clamped - 1];
    final end = clamped < 30 ? juzStartPages[clamped] - 1 : 604;
    return (startPage: start, endPage: end);
  }

  /// Returns all Mushaf page numbers belonging to a given Juz' (1-30).
  static List<int> getPagesForJuz(int juz) {
    final range = getJuzPageRange(juz);
    return List<int>.generate(
      range.endPage - range.startPage + 1,
      (i) => range.startPage + i,
    );
  }

  /// Returns the Juz' number (1-30) for a given Mushaf page (1-604).
  static int getJuzForPage(int page) {
    final clamped = page.clamp(1, 604);
    for (int j = 30; j >= 1; j--) {
      if (clamped >= juzStartPages[j - 1]) {
        return j;
      }
    }
    return 1;
  }

  /// Calculates total memorized center page units (out of 657) according to Dar al-Fajr rules:
  /// - Surahs 1-77: each memorized page within a Surah counts as 1 unit (shared boundary pages
  ///   count in both Surahs when both Surahs are completed or explicitly recorded in `centerUnits`).
  /// - Surahs 78-114 (Juz 30): each completed Surah counts as 1 page unit.
  static int calculateMemorizedCenterPages({
    required List<int> memorizedPages,
    required List<int> completedSurahs,
    List<String> memorizedCenterUnits = const [],
  }) {
    if (memorizedCenterUnits.isNotEmpty) {
      return memorizedCenterUnits.toSet().length;
    }
    final pageSet = memorizedPages.toSet();
    final surahSet = completedSurahs.toSet();
    int total = 0;

    for (final surah in surahs) {
      if (surah.isJuz30) {
        if (surahSet.contains(surah.id) ||
            surah.pages.every((p) => pageSet.contains(p))) {
          total += 1;
        }
      } else {
        if (surahSet.contains(surah.id)) {
          total += surah.centerPageCount;
        } else {
          for (final p in surah.pages) {
            if (pageSet.contains(p)) {
              total += 1;
            }
          }
        }
      }
    }
    return total;
  }

  /// Suggests the next assignment (Surah ID and page number) after passing a unit.
  static ({int surahId, int page, bool isWholeSurah}) suggestNextTarget({
    required int currentSurahId,
    int? lastCompletedPage,
  }) {
    final current = getSurahById(currentSurahId);
    if (current.isJuz30) {
      final nextId = currentSurahId < 114 ? currentSurahId + 1 : 1;
      final nextSurah = getSurahById(nextId);
      return (
        surahId: nextSurah.id,
        page: nextSurah.startPage,
        isWholeSurah: nextSurah.isJuz30,
      );
    }

    final page = lastCompletedPage ?? current.startPage;
    if (page < current.endPage) {
      return (
        surahId: current.id,
        page: page + 1,
        isWholeSurah: false,
      );
    }

    final nextId = currentSurahId < 114 ? currentSurahId + 1 : 1;
    final nextSurah = getSurahById(nextId);
    return (
      surahId: nextSurah.id,
      page: nextSurah.startPage,
      isWholeSurah: nextSurah.isJuz30,
    );
  }

  static const List<SurahPageDefinition> surahs = [
    SurahPageDefinition(id: 1, nameAr: 'الفاتحة', nameEn: 'Al-Fatihah', nameHe: 'אל-פאתיחה', primaryJuz: 1, totalVerses: 7, startPage: 1, endPage: 1),
    SurahPageDefinition(id: 2, nameAr: 'البقرة', nameEn: 'Al-Baqarah', nameHe: 'אל-בקרה', primaryJuz: 1, totalVerses: 286, startPage: 2, endPage: 49),
    SurahPageDefinition(id: 3, nameAr: 'آل عمران', nameEn: "Ali 'Imran", nameHe: 'אל עמראן', primaryJuz: 3, totalVerses: 200, startPage: 50, endPage: 76),
    SurahPageDefinition(id: 4, nameAr: 'النساء', nameEn: 'An-Nisa', nameHe: 'א-ניסאא', primaryJuz: 4, totalVerses: 176, startPage: 77, endPage: 106),
    SurahPageDefinition(id: 5, nameAr: 'المائدة', nameEn: "Al-Ma'idah", nameHe: 'אל-מאאידה', primaryJuz: 6, totalVerses: 120, startPage: 106, endPage: 127),
    SurahPageDefinition(id: 6, nameAr: 'الأنعام', nameEn: "Al-An'am", nameHe: 'אל-אנעאם', primaryJuz: 7, totalVerses: 165, startPage: 128, endPage: 150),
    SurahPageDefinition(id: 7, nameAr: 'الأعراف', nameEn: "Al-A'raf", nameHe: 'אל-אעראף', primaryJuz: 8, totalVerses: 206, startPage: 151, endPage: 176),
    SurahPageDefinition(id: 8, nameAr: 'الأنفال', nameEn: 'Al-Anfal', nameHe: 'אל-אנפאל', primaryJuz: 9, totalVerses: 75, startPage: 177, endPage: 186),
    SurahPageDefinition(id: 9, nameAr: 'التوبة', nameEn: 'At-Tawbah', nameHe: 'א-תובה', primaryJuz: 10, totalVerses: 129, startPage: 187, endPage: 207),
    SurahPageDefinition(id: 10, nameAr: 'يونس', nameEn: 'Yunus', nameHe: 'יונוס', primaryJuz: 11, totalVerses: 109, startPage: 208, endPage: 221),
    SurahPageDefinition(id: 11, nameAr: 'هود', nameEn: 'Hud', nameHe: 'הוד', primaryJuz: 11, totalVerses: 123, startPage: 221, endPage: 235),
    SurahPageDefinition(id: 12, nameAr: 'يوسف', nameEn: 'Yusuf', nameHe: 'יוסף', primaryJuz: 12, totalVerses: 111, startPage: 235, endPage: 248),
    SurahPageDefinition(id: 13, nameAr: 'الرعد', nameEn: "Ar-Ra'd", nameHe: 'א-רעד', primaryJuz: 13, totalVerses: 43, startPage: 249, endPage: 255),
    SurahPageDefinition(id: 14, nameAr: 'إبراهيم', nameEn: 'Ibrahim', nameHe: 'אבראהים', primaryJuz: 13, totalVerses: 52, startPage: 255, endPage: 261),
    SurahPageDefinition(id: 15, nameAr: 'الحجر', nameEn: 'Al-Hijr', nameHe: 'אל-חיג׳ר', primaryJuz: 14, totalVerses: 99, startPage: 262, endPage: 267),
    SurahPageDefinition(id: 16, nameAr: 'النحل', nameEn: 'An-Nahl', nameHe: 'א-נחל', primaryJuz: 14, totalVerses: 128, startPage: 267, endPage: 281),
    SurahPageDefinition(id: 17, nameAr: 'الإسراء', nameEn: 'Al-Isra', nameHe: 'אל-אסראא', primaryJuz: 15, totalVerses: 111, startPage: 282, endPage: 293),
    SurahPageDefinition(id: 18, nameAr: 'الكهف', nameEn: 'Al-Kahf', nameHe: 'אל-כהף', primaryJuz: 15, totalVerses: 110, startPage: 293, endPage: 304),
    SurahPageDefinition(id: 19, nameAr: 'مريم', nameEn: 'Maryam', nameHe: 'מרים', primaryJuz: 16, totalVerses: 98, startPage: 305, endPage: 312),
    SurahPageDefinition(id: 20, nameAr: 'طه', nameEn: 'Taha', nameHe: 'طه', primaryJuz: 16, totalVerses: 135, startPage: 312, endPage: 321),
    SurahPageDefinition(id: 21, nameAr: 'الأنبياء', nameEn: 'Al-Anbiya', nameHe: 'אל-אנביאא', primaryJuz: 17, totalVerses: 112, startPage: 322, endPage: 331),
    SurahPageDefinition(id: 22, nameAr: 'الحج', nameEn: 'Al-Hajj', nameHe: 'אל-חג׳', primaryJuz: 17, totalVerses: 78, startPage: 332, endPage: 341),
    SurahPageDefinition(id: 23, nameAr: 'المؤمنون', nameEn: "Al-Mu'minun", nameHe: 'אל-مؤمنون', primaryJuz: 18, totalVerses: 118, startPage: 342, endPage: 349),
    SurahPageDefinition(id: 24, nameAr: 'النور', nameEn: 'An-Nur', nameHe: 'א-נור', primaryJuz: 18, totalVerses: 64, startPage: 350, endPage: 359),
    SurahPageDefinition(id: 25, nameAr: 'الفرقان', nameEn: 'Al-Furqan', nameHe: 'אל-פורקאן', primaryJuz: 18, totalVerses: 77, startPage: 359, endPage: 366),
    SurahPageDefinition(id: 26, nameAr: 'الشعراء', nameEn: "Ash-Shu'ara", nameHe: 'א-שועראא', primaryJuz: 19, totalVerses: 227, startPage: 367, endPage: 376),
    SurahPageDefinition(id: 27, nameAr: 'النمل', nameEn: 'An-Naml', nameHe: 'א-נמל', primaryJuz: 19, totalVerses: 93, startPage: 377, endPage: 385),
    SurahPageDefinition(id: 28, nameAr: 'القصص', nameEn: 'Al-Qasas', nameHe: 'אל-קסס', primaryJuz: 20, totalVerses: 88, startPage: 385, endPage: 396),
    SurahPageDefinition(id: 29, nameAr: 'العنكبوت', nameEn: "Al-'Ankabut", nameHe: 'אל-ענכבות', primaryJuz: 20, totalVerses: 69, startPage: 396, endPage: 404),
    SurahPageDefinition(id: 30, nameAr: 'الروم', nameEn: 'Ar-Rum', nameHe: 'א-רום', primaryJuz: 21, totalVerses: 60, startPage: 404, endPage: 410),
    SurahPageDefinition(id: 31, nameAr: 'لقمان', nameEn: 'Luqman', nameHe: 'לוקמאן', primaryJuz: 21, totalVerses: 34, startPage: 411, endPage: 414),
    SurahPageDefinition(id: 32, nameAr: 'السجدة', nameEn: 'As-Sajdah', nameHe: 'א-סג׳דה', primaryJuz: 21, totalVerses: 30, startPage: 415, endPage: 417),
    SurahPageDefinition(id: 33, nameAr: 'الأحزاب', nameEn: 'Al-Ahzab', nameHe: 'אל-אחזאב', primaryJuz: 21, totalVerses: 73, startPage: 418, endPage: 427),
    SurahPageDefinition(id: 34, nameAr: 'سبأ', nameEn: 'Saba', nameHe: 'סבא', primaryJuz: 22, totalVerses: 54, startPage: 428, endPage: 434),
    SurahPageDefinition(id: 35, nameAr: 'فاطر', nameEn: 'Fatir', nameHe: 'פאטיר', primaryJuz: 22, totalVerses: 45, startPage: 434, endPage: 440),
    SurahPageDefinition(id: 36, nameAr: 'يس', nameEn: 'Ya-Sin', nameHe: 'יא-סין', primaryJuz: 22, totalVerses: 83, startPage: 440, endPage: 445),
    SurahPageDefinition(id: 37, nameAr: 'الصافات', nameEn: 'As-Saffat', nameHe: 'א-סאפאת', primaryJuz: 23, totalVerses: 182, startPage: 446, endPage: 452),
    SurahPageDefinition(id: 38, nameAr: 'ص', nameEn: 'Sad', nameHe: 'צאד', primaryJuz: 23, totalVerses: 88, startPage: 453, endPage: 458),
    SurahPageDefinition(id: 39, nameAr: 'الزمر', nameEn: 'Az-Zumar', nameHe: 'א-זומר', primaryJuz: 23, totalVerses: 75, startPage: 458, endPage: 467),
    SurahPageDefinition(id: 40, nameAr: 'غافر', nameEn: 'Ghafir', nameHe: 'גאפיר', primaryJuz: 24, totalVerses: 85, startPage: 467, endPage: 476),
    SurahPageDefinition(id: 41, nameAr: 'فصلت', nameEn: 'Fussilat', nameHe: 'פוצילת', primaryJuz: 24, totalVerses: 54, startPage: 477, endPage: 482),
    SurahPageDefinition(id: 42, nameAr: 'الشورى', nameEn: 'Ash-Shuraa', nameHe: 'א-שורא', primaryJuz: 25, totalVerses: 53, startPage: 483, endPage: 489),
    SurahPageDefinition(id: 43, nameAr: 'الزخرف', nameEn: 'Az-Zukhruf', nameHe: 'א-זוכרוף', primaryJuz: 25, totalVerses: 89, startPage: 489, endPage: 495),
    SurahPageDefinition(id: 44, nameAr: 'الدخان', nameEn: 'Ad-Dukhan', nameHe: 'א-דוכאן', primaryJuz: 25, totalVerses: 59, startPage: 496, endPage: 498),
    SurahPageDefinition(id: 45, nameAr: 'الجاثية', nameEn: 'Al-Jathiyah', nameHe: 'אל-ג׳את׳יה', primaryJuz: 25, totalVerses: 37, startPage: 499, endPage: 502),
    SurahPageDefinition(id: 46, nameAr: 'الأحقاف', nameEn: 'Al-Ahqaf', nameHe: 'אל-אחקאף', primaryJuz: 26, totalVerses: 35, startPage: 502, endPage: 506),
    SurahPageDefinition(id: 47, nameAr: 'محمد', nameEn: 'Muhammad', nameHe: 'מוחמד', primaryJuz: 26, totalVerses: 38, startPage: 507, endPage: 510),
    SurahPageDefinition(id: 48, nameAr: 'الفتح', nameEn: 'Al-Fath', nameHe: 'אל-פתח', primaryJuz: 26, totalVerses: 29, startPage: 511, endPage: 515),
    SurahPageDefinition(id: 49, nameAr: 'الحجرات', nameEn: 'Al-Hujurat', nameHe: 'אל-חוג׳וראת', primaryJuz: 26, totalVerses: 18, startPage: 515, endPage: 517),
    SurahPageDefinition(id: 50, nameAr: 'ق', nameEn: 'Qaf', nameHe: 'קאף', primaryJuz: 26, totalVerses: 45, startPage: 518, endPage: 520),
    SurahPageDefinition(id: 51, nameAr: 'الذاريات', nameEn: 'Adh-Dhariyat', nameHe: 'א-ד׳אריאת', primaryJuz: 26, totalVerses: 60, startPage: 520, endPage: 523),
    SurahPageDefinition(id: 52, nameAr: 'الطور', nameEn: 'At-Tur', nameHe: 'א-טור', primaryJuz: 27, totalVerses: 49, startPage: 523, endPage: 525),
    SurahPageDefinition(id: 53, nameAr: 'النجم', nameEn: 'An-Najm', nameHe: 'א-נג׳ם', primaryJuz: 27, totalVerses: 62, startPage: 526, endPage: 528),
    SurahPageDefinition(id: 54, nameAr: 'القمر', nameEn: 'Al-Qamar', nameHe: 'אל-קמר', primaryJuz: 27, totalVerses: 55, startPage: 528, endPage: 531),
    SurahPageDefinition(id: 55, nameAr: 'الرحمن', nameEn: 'Ar-Rahman', nameHe: 'א-רחמאן', primaryJuz: 27, totalVerses: 78, startPage: 531, endPage: 534),
    SurahPageDefinition(id: 56, nameAr: 'الواقعة', nameEn: "Al-Waqi'ah", nameHe: 'אל-ואקיעה', primaryJuz: 27, totalVerses: 96, startPage: 534, endPage: 537),
    SurahPageDefinition(id: 57, nameAr: 'الحديد', nameEn: 'Al-Hadid', nameHe: 'אל-חדיד', primaryJuz: 27, totalVerses: 29, startPage: 537, endPage: 541),
    SurahPageDefinition(id: 58, nameAr: 'المجادلة', nameEn: 'Al-Mujadila', nameHe: 'אל-מוג׳אדלה', primaryJuz: 28, totalVerses: 22, startPage: 542, endPage: 545),
    SurahPageDefinition(id: 59, nameAr: 'الحشر', nameEn: 'Al-Hashr', nameHe: 'אל-חשר', primaryJuz: 28, totalVerses: 24, startPage: 545, endPage: 548),
    SurahPageDefinition(id: 60, nameAr: 'الممتحنة', nameEn: 'Al-Mumtahanah', nameHe: 'אל-מומתחנה', primaryJuz: 28, totalVerses: 13, startPage: 549, endPage: 551),
    SurahPageDefinition(id: 61, nameAr: 'الصف', nameEn: 'As-Saff', nameHe: 'א-סף', primaryJuz: 28, totalVerses: 14, startPage: 551, endPage: 552),
    SurahPageDefinition(id: 62, nameAr: 'الجمعة', nameEn: "Al-Jumu'ah", nameHe: 'אל-ג׳ומועה', primaryJuz: 28, totalVerses: 11, startPage: 553, endPage: 554),
    SurahPageDefinition(id: 63, nameAr: 'المنافقون', nameEn: 'Al-Munafiqun', nameHe: 'אל-מונאפיקון', primaryJuz: 28, totalVerses: 11, startPage: 554, endPage: 555),
    SurahPageDefinition(id: 64, nameAr: 'التغابن', nameEn: 'At-Taghabun', nameHe: 'א-תגאבון', primaryJuz: 28, totalVerses: 18, startPage: 556, endPage: 557),
    SurahPageDefinition(id: 65, nameAr: 'الطلاق', nameEn: 'At-Talaq', nameHe: 'א-טלאק', primaryJuz: 28, totalVerses: 12, startPage: 558, endPage: 559),
    SurahPageDefinition(id: 66, nameAr: 'التحريم', nameEn: 'At-Tahrim', nameHe: 'א-תחרים', primaryJuz: 28, totalVerses: 12, startPage: 560, endPage: 561),
    SurahPageDefinition(id: 67, nameAr: 'الملك', nameEn: 'Al-Mulk', nameHe: 'אל-מולכ', primaryJuz: 29, totalVerses: 30, startPage: 562, endPage: 564),
    SurahPageDefinition(id: 68, nameAr: 'القلم', nameEn: 'Al-Qalam', nameHe: 'אל-קלם', primaryJuz: 29, totalVerses: 52, startPage: 564, endPage: 566),
    SurahPageDefinition(id: 69, nameAr: 'الحاقة', nameEn: 'Al-Haqqah', nameHe: 'אל-חאקה', primaryJuz: 29, totalVerses: 52, startPage: 566, endPage: 568),
    SurahPageDefinition(id: 70, nameAr: 'المعارج', nameEn: "Al-Ma'arij", nameHe: 'אל-מעאריג׳', primaryJuz: 29, totalVerses: 44, startPage: 568, endPage: 570),
    SurahPageDefinition(id: 71, nameAr: 'نوح', nameEn: 'Nuh', nameHe: 'נוח', primaryJuz: 29, totalVerses: 28, startPage: 570, endPage: 571),
    SurahPageDefinition(id: 72, nameAr: 'الجن', nameEn: 'Al-Jinn', nameHe: 'אל-ג׳ין', primaryJuz: 29, totalVerses: 28, startPage: 572, endPage: 573),
    SurahPageDefinition(id: 73, nameAr: 'المزمل', nameEn: 'Al-Muzzammil', nameHe: 'אל-מוזמיל', primaryJuz: 29, totalVerses: 20, startPage: 574, endPage: 575),
    SurahPageDefinition(id: 74, nameAr: 'المدثر', nameEn: 'Al-Muddaththir', nameHe: 'אל-מודת׳יר', primaryJuz: 29, totalVerses: 56, startPage: 575, endPage: 577),
    SurahPageDefinition(id: 75, nameAr: 'القيامة', nameEn: 'Al-Qiyamah', nameHe: 'אל-קיאמה', primaryJuz: 29, totalVerses: 40, startPage: 577, endPage: 578),
    SurahPageDefinition(id: 76, nameAr: 'الإنسان', nameEn: 'Al-Insan', nameHe: 'אל-אנסאן', primaryJuz: 29, totalVerses: 31, startPage: 578, endPage: 580),
    SurahPageDefinition(id: 77, nameAr: 'المرسلات', nameEn: 'Al-Mursalat', nameHe: 'אל-מורסלאת', primaryJuz: 29, totalVerses: 50, startPage: 580, endPage: 581),
    // Juz 30 (Surahs 78 to 114) - Each counted as 1 center page unit
    SurahPageDefinition(id: 78, nameAr: 'النبأ', nameEn: 'An-Naba', nameHe: 'א-נבא', primaryJuz: 30, totalVerses: 40, startPage: 582, endPage: 583),
    SurahPageDefinition(id: 79, nameAr: 'النازعات', nameEn: "An-Nazi'at", nameHe: 'א-נאזיעאת', primaryJuz: 30, totalVerses: 46, startPage: 583, endPage: 584),
    SurahPageDefinition(id: 80, nameAr: 'عبس', nameEn: "'Abasa", nameHe: 'עבס', primaryJuz: 30, totalVerses: 42, startPage: 585, endPage: 585),
    SurahPageDefinition(id: 81, nameAr: 'التكوير', nameEn: 'At-Takwir', nameHe: 'א-תכויר', primaryJuz: 30, totalVerses: 29, startPage: 586, endPage: 586),
    SurahPageDefinition(id: 82, nameAr: 'الانفطار', nameEn: 'Al-Infitar', nameHe: 'אל-אנפטאר', primaryJuz: 30, totalVerses: 19, startPage: 587, endPage: 587),
    SurahPageDefinition(id: 83, nameAr: 'المطففين', nameEn: 'Al-Mutaffifin', nameHe: 'אל-מוטפיפין', primaryJuz: 30, totalVerses: 36, startPage: 587, endPage: 589),
    SurahPageDefinition(id: 84, nameAr: 'الانشقاق', nameEn: 'Al-Inshiqaq', nameHe: 'אל-אנשקאק', primaryJuz: 30, totalVerses: 25, startPage: 589, endPage: 589),
    SurahPageDefinition(id: 85, nameAr: 'البروج', nameEn: 'Al-Buruj', nameHe: 'אל-בורוג׳', primaryJuz: 30, totalVerses: 22, startPage: 590, endPage: 590),
    SurahPageDefinition(id: 86, nameAr: 'الطارق', nameEn: 'At-Tariq', nameHe: 'א-טארק', primaryJuz: 30, totalVerses: 17, startPage: 591, endPage: 591),
    SurahPageDefinition(id: 87, nameAr: 'الأعلى', nameEn: "Al-A'la", nameHe: 'אל-אעלא', primaryJuz: 30, totalVerses: 19, startPage: 591, endPage: 592),
    SurahPageDefinition(id: 88, nameAr: 'الغاشية', nameEn: 'Al-Ghashiyah', nameHe: 'אל-גאשיה', primaryJuz: 30, totalVerses: 26, startPage: 592, endPage: 592),
    SurahPageDefinition(id: 89, nameAr: 'الفجر', nameEn: 'Al-Fajr', nameHe: 'אל-פג׳ר', primaryJuz: 30, totalVerses: 30, startPage: 593, endPage: 594),
    SurahPageDefinition(id: 90, nameAr: 'البلد', nameEn: 'Al-Balad', nameHe: 'אל-בלד', primaryJuz: 30, totalVerses: 20, startPage: 594, endPage: 594),
    SurahPageDefinition(id: 91, nameAr: 'الشمس', nameEn: 'Ash-Shams', nameHe: 'א-שמס', primaryJuz: 30, totalVerses: 15, startPage: 595, endPage: 595),
    SurahPageDefinition(id: 92, nameAr: 'الليل', nameEn: 'Al-Layl', nameHe: 'א-ליל', primaryJuz: 30, totalVerses: 21, startPage: 595, endPage: 596),
    SurahPageDefinition(id: 93, nameAr: 'الضحى', nameEn: 'Ad-Duhaa', nameHe: 'א-דוחא', primaryJuz: 30, totalVerses: 11, startPage: 596, endPage: 596),
    SurahPageDefinition(id: 94, nameAr: 'الشرح', nameEn: 'Ash-Sharh', nameHe: 'א-שרח', primaryJuz: 30, totalVerses: 8, startPage: 596, endPage: 596),
    SurahPageDefinition(id: 95, nameAr: 'التين', nameEn: 'At-Tin', nameHe: 'א-תין', primaryJuz: 30, totalVerses: 8, startPage: 597, endPage: 597),
    SurahPageDefinition(id: 96, nameAr: 'العلق', nameEn: "Al-'Alaq", nameHe: 'אל-עלק', primaryJuz: 30, totalVerses: 19, startPage: 597, endPage: 597),
    SurahPageDefinition(id: 97, nameAr: 'القدر', nameEn: 'Al-Qadr', nameHe: 'אל-קדר', primaryJuz: 30, totalVerses: 5, startPage: 598, endPage: 598),
    SurahPageDefinition(id: 98, nameAr: 'البينة', nameEn: 'Al-Bayyinah', nameHe: 'אל-ביינה', primaryJuz: 30, totalVerses: 8, startPage: 598, endPage: 599),
    SurahPageDefinition(id: 99, nameAr: 'الزلزلة', nameEn: 'Az-Zalzalah', nameHe: 'א-זלזלה', primaryJuz: 30, totalVerses: 8, startPage: 599, endPage: 599),
    SurahPageDefinition(id: 100, nameAr: 'العاديات', nameEn: "Al-'Adiyat", nameHe: 'אל-עאדיאת', primaryJuz: 30, totalVerses: 11, startPage: 599, endPage: 600),
    SurahPageDefinition(id: 101, nameAr: 'القارعة', nameEn: "Al-Qari'ah", nameHe: 'אל-קאריעה', primaryJuz: 30, totalVerses: 11, startPage: 600, endPage: 600),
    SurahPageDefinition(id: 102, nameAr: 'التكاثر', nameEn: 'At-Takathur', nameHe: 'א-תכאת׳ור', primaryJuz: 30, totalVerses: 8, startPage: 600, endPage: 600),
    SurahPageDefinition(id: 103, nameAr: 'العصر', nameEn: "Al-'Asr", nameHe: 'אל-עסר', primaryJuz: 30, totalVerses: 3, startPage: 601, endPage: 601),
    SurahPageDefinition(id: 104, nameAr: 'الهمزة', nameEn: 'Al-Humazah', nameHe: 'אל-הומזה', primaryJuz: 30, totalVerses: 9, startPage: 601, endPage: 601),
    SurahPageDefinition(id: 105, nameAr: 'الفيل', nameEn: 'Al-Fil', nameHe: 'אל-פיל', primaryJuz: 30, totalVerses: 5, startPage: 601, endPage: 601),
    SurahPageDefinition(id: 106, nameAr: 'قريش', nameEn: 'Quraysh', nameHe: 'קורייש', primaryJuz: 30, totalVerses: 4, startPage: 602, endPage: 602),
    SurahPageDefinition(id: 107, nameAr: 'الماعون', nameEn: "Al-Ma'un", nameHe: 'אל-מאעון', primaryJuz: 30, totalVerses: 7, startPage: 602, endPage: 602),
    SurahPageDefinition(id: 108, nameAr: 'الكوثر', nameEn: 'Al-Kawthar', nameHe: 'אל-כות׳ר', primaryJuz: 30, totalVerses: 3, startPage: 602, endPage: 602),
    SurahPageDefinition(id: 109, nameAr: 'الكافرون', nameEn: 'Al-Kafirun', nameHe: 'אל-כאפירון', primaryJuz: 30, totalVerses: 6, startPage: 603, endPage: 603),
    SurahPageDefinition(id: 110, nameAr: 'النصر', nameEn: 'An-Nasr', nameHe: 'א-נסר', primaryJuz: 30, totalVerses: 3, startPage: 603, endPage: 603),
    SurahPageDefinition(id: 111, nameAr: 'المسد', nameEn: 'Al-Masad', nameHe: 'אל-מסד', primaryJuz: 30, totalVerses: 5, startPage: 603, endPage: 603),
    SurahPageDefinition(id: 112, nameAr: 'الإخلاص', nameEn: 'Al-Ikhlas', nameHe: 'אל-אח׳לאص', primaryJuz: 30, totalVerses: 4, startPage: 604, endPage: 604),
    SurahPageDefinition(id: 113, nameAr: 'الفلق', nameEn: 'Al-Falaq', nameHe: 'אל-פלק', primaryJuz: 30, totalVerses: 5, startPage: 604, endPage: 604),
    SurahPageDefinition(id: 114, nameAr: 'الناس', nameEn: 'An-Nas', nameHe: 'א-נאס', primaryJuz: 30, totalVerses: 6, startPage: 604, endPage: 604),
  ];
}
