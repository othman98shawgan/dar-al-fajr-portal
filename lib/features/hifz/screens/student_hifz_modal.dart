import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/quran_metadata.dart';
import '../../../core/services/locale_provider.dart';
import '../../../core/services/quran_metadata_service.dart';
import '../models/teacher_models.dart';
import '../providers/teacher_providers.dart';

class StudentHifzModal extends ConsumerStatefulWidget {
  final String groupId;
  final String groupTitle;
  final String studentId;
  final String studentName;
  final AssignmentType currentType;
  final int currentSurahId;
  final String currentSurahName;
  final int currentFromAyah;
  final int currentToAyah;
  final EvaluationGrade initialGrade;
  final String initialNotes;
  final bool isFullScreenPage;

  const StudentHifzModal({
    super.key,
    this.groupId = 'grp-hifz-1',
    this.groupTitle = 'حلقة أبي بكر الصديق',
    this.studentId = 'st-1042',
    this.studentName = 'إبراهيم طه عثمان',
    this.currentType = AssignmentType.newHifz,
    this.currentSurahId = 16,
    this.currentSurahName = 'النحل',
    this.currentFromAyah = 1,
    this.currentToAyah = 128,
    this.initialGrade = EvaluationGrade.excellent,
    this.initialNotes = '',
    this.isFullScreenPage = false,
  });

  /// Launches `StudentHifzModal` as a rich modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    String groupId = 'grp-hifz-1',
    String groupTitle = 'حلقة أبي بكر الصديق',
    String studentId = 'st-1042',
    String studentName = 'إبراهيم طه عثمان',
    AssignmentType currentType = AssignmentType.newHifz,
    int currentSurahId = 16,
    String currentSurahName = 'النحل',
    int currentFromAyah = 1,
    int currentToAyah = 128,
    EvaluationGrade initialGrade = EvaluationGrade.excellent,
    String initialNotes = '',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.94,
        child: StudentHifzModal(
          groupId: groupId,
          groupTitle: groupTitle,
          studentId: studentId,
          studentName: studentName,
          currentType: currentType,
          currentSurahId: currentSurahId,
          currentSurahName: currentSurahName,
          currentFromAyah: currentFromAyah,
          currentToAyah: currentToAyah,
          initialGrade: initialGrade == EvaluationGrade.pending
              ? EvaluationGrade.excellent
              : initialGrade,
          initialNotes: initialNotes,
        ),
      ),
    );
  }

  @override
  ConsumerState<StudentHifzModal> createState() => _StudentHifzModalState();
}

class _StudentHifzModalState extends ConsumerState<StudentHifzModal> {
  late EvaluationGrade _selectedGrade;
  late final TextEditingController _notesController;

  // Section B: Next Week's Assignment State
  AssignmentType _nextAssignmentType = AssignmentType.newHifz;
  int _nextSurahId = 17; // سورة الإسراء
  late final TextEditingController _fromAyahController;
  late final TextEditingController _toAyahController;
  DateTime _dueDate = DateTime(2026, 10, 24);

  bool _isSaving = false;
  bool _isSavedSuccess = false;
  bool _isVoiceNoteRecording = false;

  // Color tokens mapped from Stitch
  static const Color _surface = Color(0xFFF7F9FB);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color _surfaceContainer = Color(0xFFECEEF0);
  static const Color _surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color _surfaceContainerHighest = Color(0xFFE0E3E5);
  static const Color _surfaceVariant = Color(0xFFE0E3E5);
  static const Color _onSurface = Color(0xFF191C1E);
  static const Color _onSurfaceVariant = Color(0xFF3D4947);
  static const Color _outline = Color(0xFF6D7A77);
  static const Color _primary = Color(0xFF00685F);
  static const Color _primaryFixed = Color(0xFF89F5E7);
  static const Color _onPrimaryFixed = Color(0xFF00201D);
  static const Color _onPrimaryFixedVariant = Color(0xFF005049);
  static const Color _secondary = Color(0xFF904D00);
  static const Color _secondaryFixed = Color(0xFFFFDCC3);
  static const Color _tertiary = Color(0xFF1E6661);
  static const Color _error = Color(0xFFBA1A1A);

  @override
  void initState() {
    super.initState();
    _selectedGrade = widget.initialGrade == EvaluationGrade.pending
        ? EvaluationGrade.excellent
        : widget.initialGrade;
    _notesController = TextEditingController(text: widget.initialNotes);
    _fromAyahController = TextEditingController(text: '1');
    _toAyahController = TextEditingController(text: '22');

    // Ensure Quran metadata is loaded
    Future<void>.microtask(() async {
      final quranService = ref.read(quranMetadataServiceProvider);
      if (quranService.surahs.isEmpty) {
        try {
          await quranService.loadMetadata();
          if (mounted) setState(() {});
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _fromAyahController.dispose();
    _toAyahController.dispose();
    super.dispose();
  }

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

  String _toArabicDigits(int number) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = number.toString();
    for (var i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], eastern[i]);
    }
    return result;
  }

  String _formatNum(int number, String langCode) {
    return langCode == 'ar' ? _toArabicDigits(number) : '$number';
  }

  String _formatDueDate(DateTime date, String langCode) {
    const weekdaysAr = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    const monthsAr = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    if (langCode == 'ar') {
      final dayName = weekdaysAr[(date.weekday - 1) % 7];
      final monthName = monthsAr[(date.month - 1) % 12];
      return '$dayName، ${_toArabicDigits(date.day)} $monthName';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null && mounted) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _openSurahPickerSheet(
    List<Surah> surahs,
    String langCode,
  ) async {
    if (surahs.isEmpty) return;

    String searchFilter = '';
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setPickerState) {
            final filtered = surahs.where((s) {
              if (searchFilter.trim().isEmpty) return true;
              final q = searchFilter.trim().toLowerCase();
              return s.name.contains(q) ||
                  s.nameEnglish.toLowerCase().contains(q) ||
                  s.id.toString() == q;
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.72,
              maxChildSize: 0.90,
              minChildSize: 0.45,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _surfaceVariant,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _tr(
                          langCode,
                          ar: 'اختر السورة المقررة',
                          he: 'בחר סורה',
                          en: 'Select Assigned Surah',
                        ),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        onChanged: (val) =>
                            setPickerState(() => searchFilter = val),
                        decoration: InputDecoration(
                          hintText: _tr(
                            langCode,
                            ar: 'ابحث باسم السورة أو رقمها...',
                            he: 'חפש לפי שם סורה או מספר...',
                            en: 'Search Surah by name or number...',
                          ),
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final s = filtered[index];
                            final isCurrent = s.id == _nextSurahId;
                            return ListTile(
                              selected: isCurrent,
                              leading: CircleAvatar(
                                backgroundColor: isCurrent
                                    ? _primary
                                    : _surfaceContainerLow,
                                foregroundColor:
                                    isCurrent ? Colors.white : _primary,
                                child: Text(
                                  _formatNum(s.id, langCode),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                'سورة ${s.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'الجزء ${_formatNum(s.juzBoundaries.firstOrNull?.juz ?? 1, langCode)} • ${_formatNum(s.totalVerses, langCode)} آية',
                              ),
                              trailing: isCurrent
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      color: _primary,
                                    )
                                  : null,
                              onTap: () => Navigator.of(sheetCtx).pop(s.id),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      final quranService = ref.read(quranMetadataServiceProvider);
      final surahObj = quranService.getSurahById(selected);
      setState(() {
        _nextSurahId = selected;
        _fromAyahController.text = '1';
        final maxVerses = surahObj?.totalVerses ?? 22;
        _toAyahController.text = '${maxVerses < 22 ? maxVerses : 22}';
      });
    }
  }

  Future<void> _handleSaveEvaluationAndAssignment(String langCode) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final quranService = ref.read(quranMetadataServiceProvider);
    final nextSurah = quranService.getSurahById(_nextSurahId);
    final nextFromAyah = int.tryParse(_fromAyahController.text.trim()) ?? 1;
    final nextToAyah = int.tryParse(_toAyahController.text.trim()) ?? 22;

    // 1. Save evaluation of the current recitation
    await ref.read(teacherControllerProvider.notifier).saveHifzAssignment(
          studentId: widget.studentId,
          studentName: widget.studentName,
          groupId: widget.groupId,
          type: widget.currentType,
          surahId: widget.currentSurahId,
          surahName: widget.currentSurahName,
          fromAyah: widget.currentFromAyah,
          toAyah: widget.currentToAyah,
          grade: _selectedGrade,
          teacherNotes: _notesController.text.trim(),
        );

    // 2. Save next week's pending assignment
    await ref.read(teacherControllerProvider.notifier).saveHifzAssignment(
          studentId: widget.studentId,
          studentName: widget.studentName,
          groupId: widget.groupId,
          type: _nextAssignmentType,
          surahId: _nextSurahId,
          surahName: nextSurah?.name ?? 'الإسراء',
          fromAyah: nextFromAyah,
          toAyah: nextToAyah,
          grade: EvaluationGrade.pending,
          teacherNotes:
              'واجب الأسبوع القادم • تاريخ الاستحقاق: ${_formatDueDate(_dueDate, 'ar')}',
        );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _isSavedSuccess = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _tr(
            langCode,
            ar: 'تم حفظ التقييم وتحديث سجل حفظ الطالب (${widget.studentName}) وجدولة الواجب القادم!',
            he: 'ההערכה נשמרה והמטלה הבאה נקבעה בהצלחה!',
            en: 'Evaluation saved, Quran progress updated & next assignment scheduled!',
          ),
        ),
        backgroundColor: _tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final langCode = currentLocale.languageCode;
    final isRtl = isRtlLocale(currentLocale);

    final quranService = ref.watch(quranMetadataServiceProvider);
    final surahs = quranService.surahs;
    final nextSurah = quranService.getSurahById(_nextSurahId);
    final nextSurahName = nextSurah?.name ?? 'الإسراء';
    final nextSurahJuz = nextSurah?.juzBoundaries.firstOrNull?.juz ?? 15;
    final nextSurahMaxVerses = nextSurah?.totalVerses ?? 111;

    final nextFromAyah = int.tryParse(_fromAyahController.text.trim()) ?? 1;
    final nextToAyah = int.tryParse(_toAyahController.text.trim()) ?? 22;
    final touchedPages = surahs.isNotEmpty
        ? quranService.calculatePages(
            _nextSurahId,
            nextFromAyah,
            nextToAyah,
          )
        : <int>[];

    final sheetContent = Container(
      decoration: const BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Top Grabber & Header
          Container(
            color: _surfaceContainerLowest,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _surfaceVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tr(
                              langCode,
                              ar: 'تقييم وتحديد واجب الطالب',
                              he: 'הערכה וקביעת מטלת תלמיד',
                              en: 'Evaluate & Assign Student Hifz',
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
                          const SizedBox(height: 2),
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: _onSurfaceVariant,
                                  ),
                              children: [
                                TextSpan(text: '${widget.studentName} • '),
                                TextSpan(
                                  text: widget.groupTitle,
                                  style: const TextStyle(
                                    color: _primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: _surfaceContainerHigh,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        customBorder: const CircleBorder(),
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: _onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Modal Content Container
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===========================================================
                  // SECTION A: تقييم التسميع الحالي (Evaluate Current Recitation)
                  // ===========================================================
                  _buildSectionA(context, langCode),
                  const SizedBox(height: 20),

                  // ===========================================================
                  // SECTION B: تحديد واجب الأسبوع القادم (Next Week's Assignment)
                  // ===========================================================
                  _buildSectionB(
                    context: context,
                    langCode: langCode,
                    surahs: surahs,
                    nextSurahName: nextSurahName,
                    nextSurahJuz: nextSurahJuz,
                    nextSurahMaxVerses: nextSurahMaxVerses,
                    touchedPages: touchedPages,
                  ),
                  const SizedBox(height: 20),

                  // ===========================================================
                  // Bottom Action Controls
                  // ===========================================================
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () => _handleSaveEvaluationAndAssignment(langCode),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isSavedSuccess ? _tertiary : _primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(
                        _isSaving
                            ? Icons.sync_rounded
                            : (_isSavedSuccess
                                ? Icons.check_circle_rounded
                                : Icons.verified_rounded),
                        size: 20,
                      ),
                      label: Text(
                        _isSaving
                            ? _tr(
                                langCode,
                                ar: 'جاري الحفظ...',
                                he: 'שומר...',
                                en: 'Saving...',
                              )
                            : (_isSavedSuccess
                                ? _tr(
                                    langCode,
                                    ar: 'تم الحفظ بنجاح',
                                    he: 'נשמר בהצלחה',
                                    en: 'Saved Successfully',
                                  )
                                : _tr(
                                    langCode,
                                    ar: 'حفظ التقييم والواجب',
                                    he: 'שמור הערכה ומטלה',
                                    en: 'Save Evaluation & Assignment',
                                  )),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: TextButton.styleFrom(
                      foregroundColor: _onSurfaceVariant,
                    ),
                    child: Text(
                      _tr(
                        langCode,
                        ar: 'إلغاء والتراجع',
                        he: 'ביטול וחזרה',
                        en: 'Cancel & Go Back',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: widget.isFullScreenPage
          ? Scaffold(
              backgroundColor: _surface,
              body: Stack(
                children: [
                  Positioned.fill(
                    top: MediaQuery.paddingOf(context).top + 64,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: sheetContent,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          color: _surface.withValues(alpha: 0.85),
                          child: SafeArea(
                            bottom: false,
                            child: SizedBox(
                              height: 64,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              Navigator.of(context).maybePop(),
                                          icon: const Icon(
                                            Icons.arrow_back_rounded,
                                          ),
                                        ),
                                        const Text(
                                          'Student Hifz Modal',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
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
                                  ],
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
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: sheetContent,
              ),
            ),
    );
  }

  Widget _buildSectionA(BuildContext context, String langCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section A Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: _primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    langCode == 'ar' ? '١' : '1',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: _onPrimaryFixed,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _tr(
                    langCode,
                    ar: 'تقييم التسميع الحالي',
                    he: 'הערכת השינון הנוכחי',
                    en: 'Evaluate Current Recitation',
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _secondaryFixed,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _tr(
                  langCode,
                  ar: 'جلسة اليوم',
                  he: 'מפגש היום',
                  en: "Today's Session",
                ),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Current Assignment Status Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _tr(
                      langCode,
                      ar: 'المقرر المرصود',
                      he: 'המטלה הנוכחית',
                      en: 'Assigned Range',
                    ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _onSurfaceVariant,
                          fontSize: 11,
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
                        const Icon(
                          Icons.auto_stories_rounded,
                          size: 13,
                          color: _onPrimaryFixed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.currentType.localizedName(langCode),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
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
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'سورة ${widget.currentSurahName}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _tr(
                      langCode,
                      ar: 'الآيات (${_formatNum(widget.currentFromAyah, langCode)} - ${_formatNum(widget.currentToAyah, langCode)})',
                      he: 'פסוקים (${widget.currentFromAyah} - ${widget.currentToAyah})',
                      en: 'Ayahs (${widget.currentFromAyah} - ${widget.currentToAyah})',
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const LinearProgressIndicator(
                  value: 1.0,
                  minHeight: 6,
                  backgroundColor: _surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(_primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Grade Selection Cards (3-column grid)
        Row(
          children: [
            Expanded(
              child: _GradeOptionCard(
                title: _tr(
                  langCode,
                  ar: 'ممتاز',
                  he: 'מצוין',
                  en: 'Excellent',
                ),
                subtitle: _tr(
                  langCode,
                  ar: '٩٠ - ١٠٠٪',
                  he: '90 - 100%',
                  en: '90 - 100%',
                ),
                subtitleColor: _onPrimaryFixedVariant,
                isSelected: _selectedGrade == EvaluationGrade.excellent,
                onTap: () => setState(
                  () => _selectedGrade = EvaluationGrade.excellent,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _GradeOptionCard(
                title: _tr(
                  langCode,
                  ar: 'جيد',
                  he: 'טוב',
                  en: 'Good',
                ),
                subtitle: _tr(
                  langCode,
                  ar: '٧٥ - ٨٩٪',
                  he: '75 - 89%',
                  en: '75 - 89%',
                ),
                subtitleColor: _secondary,
                isSelected: _selectedGrade == EvaluationGrade.good,
                onTap: () => setState(
                  () => _selectedGrade = EvaluationGrade.good,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _GradeOptionCard(
                title: _tr(
                  langCode,
                  ar: 'إعادة',
                  he: 'חזרה',
                  en: 'Retry',
                ),
                subtitle: _tr(
                  langCode,
                  ar: 'يحتاج تثبيت',
                  he: 'דורש חיזוק',
                  en: 'Needs Review',
                ),
                subtitleColor: _error,
                isSelected: _selectedGrade == EvaluationGrade.needsRepeat,
                onTap: () => setState(
                  () => _selectedGrade = EvaluationGrade.needsRepeat,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Teacher Notes Field with Mic Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tr(
                langCode,
                ar: 'ملاحظات المعلم وأخطاء التجويد',
                he: 'הערות המורה וטג׳וויד',
                en: 'Teacher Notes & Tajweed Mistakes',
              ),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.history_edu_rounded,
                  size: 14,
                  color: _tertiary,
                ),
                const SizedBox(width: 3),
                Text(
                  _tr(
                    langCode,
                    ar: 'اختياري',
                    he: 'אופציונלי',
                    en: 'Optional',
                  ),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _tertiary,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _onSurface,
                  ),
              decoration: InputDecoration(
                fillColor: _surfaceContainerLowest,
                filled: true,
                hintText: _tr(
                  langCode,
                  ar: 'اكتب التوجيهات الصوتية والتجويدية وأرقام الآيات التي تحتاج تثبيت...',
                  he: 'כתוב הערות היגוי וטג׳וויד ומספרי פסוקים לחיזוק...',
                  en: 'Write Tajweed feedback and Ayah numbers needing review...',
                ),
                hintStyle: const TextStyle(color: _outline, fontSize: 12),
                contentPadding: const EdgeInsetsDirectional.only(
                  start: 12,
                  end: 44,
                  top: 10,
                  bottom: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _surfaceContainerHigh),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _surfaceContainerHigh),
                ),
              ),
            ),
            PositionedDirectional(
              bottom: 8,
              end: 8,
              child: Material(
                color: _isVoiceNoteRecording
                    ? _primaryFixed
                    : _surfaceContainerHigh,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isVoiceNoteRecording = !_isVoiceNoteRecording;
                      if (_isVoiceNoteRecording &&
                          _notesController.text.trim().isEmpty) {
                        _notesController.text =
                            'تنبيه على تحقيق المد المتصل وترقيق الراء في الآيات الكريمة.';
                      }
                    });
                  },
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.mic_rounded,
                      size: 18,
                      color: _primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionB({
    required BuildContext context,
    required String langCode,
    required List<Surah> surahs,
    required String nextSurahName,
    required int nextSurahJuz,
    required int nextSurahMaxVerses,
    required List<int> touchedPages,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section B Header
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: _primaryFixed,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                langCode == 'ar' ? '٢' : '2',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: _onPrimaryFixed,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _tr(
                langCode,
                ar: 'تحديد واجب الأسبوع القادم',
                he: 'קביעת מטלה לשבוע הבא',
                en: "Set Next Week's Assignment",
              ),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Assignment Type Segmented Switcher
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _surfaceContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(
                    () => _nextAssignmentType = AssignmentType.newHifz,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _nextAssignmentType == AssignmentType.newHifz
                          ? _surfaceContainerLowest
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: _nextAssignmentType == AssignmentType.newHifz
                              ? _primary
                              : _onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _tr(
                            langCode,
                            ar: 'حفظ جديد',
                            he: 'שינון חדש',
                            en: 'New Hifz',
                          ),
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: _nextAssignmentType ==
                                            AssignmentType.newHifz
                                        ? _primary
                                        : _onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: InkWell(
                  onTap: () => setState(
                    () => _nextAssignmentType = AssignmentType.revision,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _nextAssignmentType == AssignmentType.revision
                          ? _surfaceContainerLowest
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sync_rounded,
                          size: 16,
                          color: _nextAssignmentType == AssignmentType.revision
                              ? _primary
                              : _onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _tr(
                            langCode,
                            ar: 'مراجعة وتثبيت',
                            he: 'חזרה וחיזוק',
                            en: 'Revision & Review',
                          ),
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: _nextAssignmentType ==
                                            AssignmentType.revision
                                        ? _primary
                                        : _onSurfaceVariant,
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
        ),
        const SizedBox(height: 10),

        // Surah Selector Card
        Text(
          _tr(
            langCode,
            ar: 'السورة المقررة',
            he: 'הסורה שנקבעה',
            en: 'Assigned Surah',
          ),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 4),
        Material(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          elevation: 0.5,
          child: InkWell(
            onTap: () => _openSurahPickerSheet(surahs, langCode),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
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
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: _surfaceContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            size: 16,
                            color: _primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'سورة $nextSurahName (${_formatNum(_nextSurahId, langCode)})',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: _onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'الجزء ${_formatNum(nextSurahJuz, langCode)} • ${_formatNum(nextSurahMaxVerses, langCode)} آية${touchedPages.isNotEmpty ? " • ${touchedPages.length} صفحات" : ""}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: _onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.expand_more_rounded,
                    color: _outline,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Verse Range Dual Inputs (من آية / إلى آية)
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tr(
                      langCode,
                      ar: 'من آية',
                      he: 'מפסוק',
                      en: 'From Ayah',
                    ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _onSurfaceVariant,
                          fontSize: 11,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Stack(
                    alignment: AlignmentDirectional.centerEnd,
                    children: [
                      TextField(
                        controller: _fromAyahController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (_) => setState(() {}),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _onSurface,
                                ),
                        decoration: InputDecoration(
                          fillColor: _surfaceContainerLowest,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: _surfaceContainerHigh,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: _surfaceContainerHigh,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10),
                        child: Text(
                          _tr(
                            langCode,
                            ar: 'بداية',
                            he: 'התחלה',
                            en: 'Start',
                          ),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _outline,
                                    fontSize: 11,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                      ar: 'إلى آية',
                      he: 'עד פסוק',
                      en: 'To Ayah',
                    ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _onSurfaceVariant,
                          fontSize: 11,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Stack(
                    alignment: AlignmentDirectional.centerEnd,
                    children: [
                      TextField(
                        controller: _toAyahController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (_) => setState(() {}),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _onSurface,
                                ),
                        decoration: InputDecoration(
                          fillColor: _surfaceContainerLowest,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: _surfaceContainerHigh,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: _surfaceContainerHigh,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10),
                        child: Text(
                          _tr(
                            langCode,
                            ar: 'نهاية',
                            he: 'סיום',
                            en: 'End',
                          ),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _outline,
                                    fontSize: 11,
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
        const SizedBox(height: 10),

        // Target Completion Date Badge
        InkWell(
          onTap: _pickDueDate,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: _secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _tr(
                        langCode,
                        ar: 'تاريخ الاستحقاق',
                        he: 'תאריך יעד',
                        en: 'Due Date',
                      ),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: _onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                Text(
                  _formatDueDate(_dueDate, langCode),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: _secondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GradeOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _GradeOptionCard({
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00685F);
    const primaryFixed = Color(0xFF89F5E7);
    const onPrimaryFixed = Color(0xFF00201D);
    const surfaceContainer = Color(0xFFECEEF0);
    const onSurfaceVariant = Color(0xFF3D4947);

    return Material(
      color: isSelected ? primaryFixed : surfaceContainer,
      borderRadius: BorderRadius.circular(10),
      elevation: isSelected ? 0.5 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            if (isSelected)
              const PositionedDirectional(
                top: 4,
                end: 4,
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: primary,
                ),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 4,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color:
                                isSelected ? onPrimaryFixed : onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: subtitleColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
