import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/surah_page_map.dart';
import '../../../core/services/locale_provider.dart';
import '../models/teacher_models.dart';
import '../providers/teacher_providers.dart';

class StudentHifzModal extends ConsumerStatefulWidget {
  final String? existingAssignmentId;
  final String groupId;
  final String groupTitle;
  final String studentId;
  final String studentName;
  final AssignmentType currentType;
  final int currentSurahId;
  final String currentSurahName;
  final int currentFromAyah;
  final int currentToAyah;
  final int? currentTargetPage;
  final int? currentJuzNumber;
  final EvaluationGrade initialGrade;
  final String initialNotes;
  final bool assignOnlyMode;
  final bool isFullScreenPage;

  const StudentHifzModal({
    super.key,
    this.existingAssignmentId,
    this.groupId = 'grp-hifz-1',
    this.groupTitle = 'حلقة أبي بكر الصديق',
    this.studentId = 'st-1042',
    this.studentName = 'إبراهيم طه عثمان',
    this.currentType = AssignmentType.newHifz,
    this.currentSurahId = 16,
    this.currentSurahName = 'النحل',
    this.currentFromAyah = 1,
    this.currentToAyah = 128,
    this.currentTargetPage,
    this.currentJuzNumber,
    this.initialGrade = EvaluationGrade.excellent,
    this.initialNotes = '',
    this.assignOnlyMode = false,
    this.isFullScreenPage = false,
  });

  /// Launches `StudentHifzModal` as a rich modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    String? existingAssignmentId,
    String groupId = 'grp-hifz-1',
    String groupTitle = 'حلقة أبي بكر الصديق',
    String studentId = 'st-1042',
    String studentName = 'إبراهيم طه عثمان',
    AssignmentType currentType = AssignmentType.newHifz,
    int currentSurahId = 16,
    String currentSurahName = 'النحل',
    int currentFromAyah = 1,
    int currentToAyah = 128,
    int? currentTargetPage,
    int? currentJuzNumber,
    EvaluationGrade initialGrade = EvaluationGrade.excellent,
    String initialNotes = '',
    bool assignOnlyMode = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.94,
        child: StudentHifzModal(
          existingAssignmentId: existingAssignmentId,
          groupId: groupId,
          groupTitle: groupTitle,
          studentId: studentId,
          studentName: studentName,
          currentType: currentType,
          currentSurahId: currentSurahId,
          currentSurahName: currentSurahName,
          currentFromAyah: currentFromAyah,
          currentToAyah: currentToAyah,
          currentTargetPage: currentTargetPage,
          currentJuzNumber: currentJuzNumber,
          initialGrade: initialGrade == EvaluationGrade.pending
              ? EvaluationGrade.excellent
              : initialGrade,
          initialNotes: initialNotes,
          assignOnlyMode: assignOnlyMode,
        ),
      ),
    );
  }

  @override
  ConsumerState<StudentHifzModal> createState() => _StudentHifzModalState();
}

class _StudentHifzModalState extends ConsumerState<StudentHifzModal> {
  late bool _assignOnlyMode;
  late List<TasmeeRecitationUnit> _units;
  late final TextEditingController _notesController;

  // Section B: Next Week's Assignment State
  AssignmentType _nextAssignmentType = AssignmentType.newHifz;
  int _nextSurahId = 17;
  int _nextTargetPage = 282;
  int _nextJuzNumber = 30;
  late final TextEditingController _fromAyahController;
  late final TextEditingController _toAyahController;
  final bool _scheduleNextAssignment = true;

  bool _isSaving = false;
  bool _isSavedSuccess = false;
  bool _isVoiceNoteRecording = false;

  // Color tokens
  static const Color _surface = Color(0xFFF7F9FB);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color _surfaceContainer = Color(0xFFECEEF0);
  static const Color _surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color _surfaceVariant = Color(0xFFE0E3E5);
  static const Color _onSurface = Color(0xFF191C1E);
  static const Color _onSurfaceVariant = Color(0xFF3D4947);
  static const Color _outline = Color(0xFF6D7A77);
  static const Color _primary = Color(0xFF00685F);
  static const Color _primaryFixed = Color(0xFF89F5E7);
  static const Color _onPrimaryFixed = Color(0xFF00201D);
  static const Color _secondary = Color(0xFF904D00);
  static const Color _secondaryFixed = Color(0xFFFFDCC3);
  static const Color _tertiary = Color(0xFF1E6661);
  static const Color _error = Color(0xFFBA1A1A);

  @override
  void initState() {
    super.initState();
    _assignOnlyMode = widget.assignOnlyMode;
    _notesController = TextEditingController(text: widget.initialNotes);

    final initialSurah = CenterQuranMap.getSurahById(widget.currentSurahId);
    final initialUnitType = widget.currentType == AssignmentType.revision
        ? RecitationUnitType.juzExam
        : (initialSurah.isJuz30
            ? RecitationUnitType.surah
            : RecitationUnitType.page);

    _units = [
      TasmeeRecitationUnit(
        unitType: initialUnitType,
        surahId: initialSurah.id,
        surahName: initialSurah.nameAr,
        pageNumber: widget.currentTargetPage ?? initialSurah.startPage,
        juzNumber: widget.currentJuzNumber ?? initialSurah.primaryJuz,
        fromAyah: widget.currentFromAyah,
        toAyah: widget.currentToAyah,
        forceRepeat: widget.initialGrade == EvaluationGrade.needsRepeat,
      ),
    ];

    if (_assignOnlyMode) {
      _nextAssignmentType = widget.currentType;
      _nextSurahId = initialSurah.id;
      _nextTargetPage = widget.currentTargetPage ?? initialSurah.startPage;
      _nextJuzNumber = widget.currentJuzNumber ?? initialSurah.primaryJuz;
      _fromAyahController =
          TextEditingController(text: '${widget.currentFromAyah}');
      _toAyahController =
          TextEditingController(text: '${widget.currentToAyah}');
    } else {
      final suggested = CenterQuranMap.suggestNextTarget(
        currentSurahId: initialSurah.id,
        lastCompletedPage: widget.currentTargetPage ?? initialSurah.startPage,
      );
      final nextSurah = CenterQuranMap.getSurahById(suggested.surahId);
      _nextSurahId = nextSurah.id;
      _nextTargetPage = suggested.page;
      _nextJuzNumber = nextSurah.primaryJuz;
      _fromAyahController = TextEditingController(text: '1');
      _toAyahController =
          TextEditingController(text: '${nextSurah.totalVerses}');
    }
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

  void _syncNextAssignmentSuggestion(GradingPenaltyConfig config) {
    if (_assignOnlyMode || _units.isEmpty) return;
    final lastUnit = _units.last;
    if (lastUnit.unitType == RecitationUnitType.partialRead) {
      // Partial read -> keep the same target for next session
      final s = CenterQuranMap.getSurahById(lastUnit.surahId);
      _nextSurahId = s.id;
      _nextTargetPage = lastUnit.pageNumber ?? s.startPage;
      _fromAyahController.text = '${lastUnit.fromAyah}';
      _toAyahController.text = '${lastUnit.toAyah}';
      return;
    }

    final passed = lastUnit.isPassed(config);
    if (!passed) {
      // Needs repeat -> rollover current assignment to next session
      final s = CenterQuranMap.getSurahById(lastUnit.surahId);
      _nextSurahId = s.id;
      _nextTargetPage = lastUnit.pageNumber ?? s.startPage;
      _nextJuzNumber = lastUnit.juzNumber ?? s.primaryJuz;
      _fromAyahController.text = '${lastUnit.fromAyah}';
      _toAyahController.text = '${lastUnit.toAyah}';
    } else {
      // Passed -> suggest next page or surah from CenterQuranMap
      final suggested = CenterQuranMap.suggestNextTarget(
        currentSurahId: lastUnit.surahId,
        lastCompletedPage: lastUnit.pageNumber,
      );
      final nextS = CenterQuranMap.getSurahById(suggested.surahId);
      _nextSurahId = nextS.id;
      _nextTargetPage = suggested.page;
      _nextJuzNumber = nextS.primaryJuz;
      _fromAyahController.text = '1';
      _toAyahController.text = '${nextS.totalVerses}';
    }
  }

  void _addAnotherUnitInSitting(GradingPenaltyConfig config) {
    final prev = _units.last;
    final suggested = CenterQuranMap.suggestNextTarget(
      currentSurahId: prev.surahId,
      lastCompletedPage: prev.pageNumber,
    );
    final nextSurah = CenterQuranMap.getSurahById(suggested.surahId);
    setState(() {
      _units.add(
        TasmeeRecitationUnit(
          unitType: nextSurah.isJuz30
              ? RecitationUnitType.surah
              : RecitationUnitType.page,
          surahId: nextSurah.id,
          surahName: nextSurah.nameAr,
          pageNumber: suggested.page,
          juzNumber: nextSurah.primaryJuz,
          fromAyah: 1,
          toAyah: nextSurah.totalVerses,
        ),
      );
      _syncNextAssignmentSuggestion(config);
    });
  }

  Future<int?> _openCenterSurahPickerSheet(
    String langCode, {
    required int currentSurahId,
  }) async {
    String searchFilter = '';
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setPickerState) {
            final filtered = CenterQuranMap.surahs.where((s) {
              if (searchFilter.trim().isEmpty) return true;
              final q = searchFilter.trim().toLowerCase();
              return s.nameAr.contains(q) ||
                  s.nameEn.toLowerCase().contains(q) ||
                  s.nameHe.contains(q) ||
                  s.id.toString() == q;
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.92,
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
                          ar: 'اختر السورة (١١٤ سورة - توزيع المركز)',
                          he: 'בחר סורה (114 סורות)',
                          en: 'Select Surah (114 Surahs - Center Map)',
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
                            final isCurrent = s.id == currentSurahId;
                            return Material(
                              color: Colors.transparent,
                              child: ListTile(
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
                                  'سورة ${s.localizedName(langCode)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  s.isJuz30
                                      ? _tr(
                                          langCode,
                                          ar: 'الجزء ٣٠ • تحسب كصفحة واحدة في المركز (ص ${s.startPage})',
                                          he: 'ג׳וז 30 • נחשבת כיחידת עמוד אחת במרכז',
                                          en: 'Juz 30 • Counted as 1 Center Page (p. ${s.startPage})',
                                        )
                                      : _tr(
                                          langCode,
                                          ar: 'الجزء ${_formatNum(s.primaryJuz, langCode)} • الصفحات ${_formatNum(s.startPage, langCode)}-${_formatNum(s.endPage, langCode)} (${_formatNum(s.centerPageCount, langCode)} صفحات)',
                                          he: 'ג׳וז ${s.primaryJuz} • עמודים ${s.startPage}-${s.endPage} (${s.centerPageCount} עמ׳)',
                                          en: 'Juz ${s.primaryJuz} • Pages ${s.startPage}-${s.endPage} (${s.centerPageCount} pages)',
                                        ),
                                ),
                                trailing: isCurrent
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: _primary,
                                      )
                                    : null,
                                onTap: () => Navigator.of(sheetCtx).pop(s.id),
                              ),
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
  }

  Future<void> _handleSave(
    String langCode,
    GradingPenaltyConfig penaltyConfig,
  ) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final nextSurah = CenterQuranMap.getSurahById(_nextSurahId);
    final nextFromAyah = int.tryParse(_fromAyahController.text.trim()) ?? 1;
    final nextToAyah =
        int.tryParse(_toAyahController.text.trim()) ?? nextSurah.totalVerses;

    if (_assignOnlyMode) {
      // Only create or update a pending assignment (without logging a recitation evaluation)
      await ref.read(teacherControllerProvider.notifier).saveHifzAssignment(
            existingAssignmentId: widget.existingAssignmentId,
            studentId: widget.studentId,
            studentName: widget.studentName,
            groupId: widget.groupId,
            type: _nextAssignmentType,
            surahId: nextSurah.id,
            surahName: nextSurah.nameAr,
            fromAyah: nextFromAyah,
            toAyah: nextToAyah,
            targetPage: _nextTargetPage,
            juzNumber: _nextAssignmentType == AssignmentType.revision
                ? _nextJuzNumber
                : nextSurah.primaryJuz,
            isJuzExam: _nextAssignmentType == AssignmentType.revision,
            grade: EvaluationGrade.pending,
            teacherNotes: _notesController.text.trim(),
          );
    } else {
      // 1. Evaluate current recitation sitting (supports 1 or multiple units)
      final primaryUnit = _units.first;
      final primarySurah = CenterQuranMap.getSurahById(primaryUnit.surahId);
      final isPartial = primaryUnit.unitType == RecitationUnitType.partialRead;
      final isJuzRevision = primaryUnit.unitType == RecitationUnitType.juzExam;

      // Aggregate mistakes & average score across graded units
      final gradedUnits = _units.where((u) => u.isGraded).toList();
      int? finalScore;
      EvaluationGrade finalGrade = EvaluationGrade.pending;
      int totalLafzi = 0;
      int totalFath = 0;
      int totalTataa = 0;
      bool anyForceRepeat = false;

      for (final u in _units) {
        totalLafzi += u.lafziCount;
        totalFath += u.fathCount;
        totalTataa += u.tataaCount;
        if (u.forceRepeat) anyForceRepeat = true;
      }

      if (!isPartial && gradedUnits.isNotEmpty) {
        final sumScores = gradedUnits.fold<int>(
          0,
          (sum, u) => sum + (u.computedScore(penaltyConfig) ?? 100),
        );
        finalScore = (sumScores / gradedUnits.length).round();
        final allPassed =
            gradedUnits.every((u) => u.isPassed(penaltyConfig));
        if (!allPassed || anyForceRepeat) {
          finalGrade = EvaluationGrade.needsRepeat;
        } else {
          finalGrade = penaltyConfig.evaluateGrade(
            score: finalScore,
            isJuzExam: isJuzRevision,
            forceRepeat: anyForceRepeat,
          );
        }
      }

      await ref.read(teacherControllerProvider.notifier).saveHifzAssignment(
            existingAssignmentId: widget.existingAssignmentId,
            studentId: widget.studentId,
            studentName: widget.studentName,
            groupId: widget.groupId,
            type: isJuzRevision
                ? AssignmentType.revision
                : AssignmentType.newHifz,
            surahId: primarySurah.id,
            surahName: primarySurah.nameAr,
            fromAyah: primaryUnit.fromAyah,
            toAyah: primaryUnit.toAyah,
            targetPage: primaryUnit.pageNumber,
            juzNumber: primaryUnit.juzNumber ?? primarySurah.primaryJuz,
            grade: finalGrade,
            score: finalScore,
            lafziCount: totalLafzi,
            fathCount: totalFath,
            tataaCount: totalTataa,
            isPartialRead: isPartial,
            isJuzExam: isJuzRevision,
            forceRepeat: anyForceRepeat,
            recitationUnits: _units,
            teacherNotes: _notesController.text.trim(),
            autoCreateNextAssignment: _scheduleNextAssignment,
            nextSurahId: _nextSurahId,
            nextSurahName: nextSurah.nameAr,
            nextPage: _nextTargetPage,
            nextFromAyah: nextFromAyah,
            nextToAyah: nextToAyah,
          );
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _isSavedSuccess = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _assignOnlyMode
              ? _tr(
                  langCode,
                  ar: 'تم حفظ واجب الطالب (${widget.studentName}) بنجاح!',
                  he: 'מטלת התלמיד נשמרה בהצלחה!',
                  en: 'Student assignment saved successfully!',
                )
              : _tr(
                  langCode,
                  ar: 'تم حفظ جلسة التسميع وتحديث تقدم (${widget.studentName}) وجدولة الواجب القادم!',
                  he: 'מפגש השינון נשמר והמטלה הבאה נקבעה בהצלחה!',
                  en: 'Recitation saved, progress updated & next assignment scheduled!',
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
    final penaltyConfig =
        ref.watch(gradingPenaltyConfigProvider).asData?.value ??
            const GradingPenaltyConfig();

    final nextSurah = CenterQuranMap.getSurahById(_nextSurahId);

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
                            _assignOnlyMode
                                ? _tr(
                                    langCode,
                                    ar: 'تحديد / تعديل واجب الطالب',
                                    he: 'קביעת / עריכת מטלת תלמיד',
                                    en: 'Assign / Edit Student Homework',
                                  )
                                : _tr(
                                    langCode,
                                    ar: 'جلسة تسميع وتحديد الواجب',
                                    he: 'מפגש שינון וקביעת מטלה',
                                    en: 'Recitation (Tasmee) & Next Assignment',
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
                const SizedBox(height: 10),
                // Mode Switcher: Tasmee Session vs Assign Homework Only
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: _surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _assignOnlyMode = false),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: !_assignOnlyMode
                                  ? _surfaceContainerLowest
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _tr(
                                langCode,
                                ar: '🎙️ جلسة تسميع وتقييم',
                                he: '🎙️ מפגש שינון והערכה',
                                en: '🎙️ Tasmee Evaluation',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: !_assignOnlyMode
                                    ? _primary
                                    : _onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _assignOnlyMode = true),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: _assignOnlyMode
                                  ? _surfaceContainerLowest
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _tr(
                                langCode,
                                ar: '📝 تحديد / تعديل واجب فقط',
                                he: '📝 קביעת / עריכת מטלה בלבד',
                                en: '📝 Assign / Edit Only',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _assignOnlyMode
                                    ? _primary
                                    : _onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                  if (!_assignOnlyMode) ...[
                    _buildSectionA(context, langCode, penaltyConfig),
                    const SizedBox(height: 20),
                  ],

                  _buildSectionB(
                    context: context,
                    langCode: langCode,
                    nextSurah: nextSurah,
                    penaltyConfig: penaltyConfig,
                  ),
                  const SizedBox(height: 20),

                  // Bottom Action Controls
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      key: const Key('student_hifz_save_button'),
                      onPressed: _isSaving
                          ? null
                          : () => _handleSave(langCode, penaltyConfig),
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
                                : (_assignOnlyMode
                                    ? _tr(
                                        langCode,
                                        ar: 'حفظ الواجب المقرر',
                                        he: 'שמור מטלה',
                                        en: 'Save Assignment',
                                      )
                                    : _tr(
                                        langCode,
                                        ar: 'حفظ التسميع والواجب القادم',
                                        he: 'שמור הערכה ומטלה',
                                        en: 'Save Evaluation & Next Assignment',
                                      ))),
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
              body: SafeArea(
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
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: sheetContent,
              ),
            ),
    );
  }

  Widget _buildSectionA(
    BuildContext context,
    String langCode,
    GradingPenaltyConfig penaltyConfig,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section A Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
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
                  Expanded(
                    child: Text(
                      _tr(
                        langCode,
                        ar: 'تقييم التسميع الحالي (٠ - ١٠٠)',
                        he: 'הערכת השינון הנוכחי (0 - 100)',
                        en: 'Evaluate Recitation (0 - 100)',
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _primary,
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => _addAnotherUnitInSitting(penaltyConfig),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
              label: Text(
                _tr(
                  langCode,
                  ar: 'إضافة صفحة/سورة بالجلسة',
                  he: 'הוסף עמוד/סורה במפגש',
                  en: 'Add Unit in Sitting',
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Render each TasmeeRecitationUnit card
        for (int index = 0; index < _units.length; index++) ...[
          _buildRecitationUnitCard(
            context: context,
            langCode: langCode,
            index: index,
            unit: _units[index],
            penaltyConfig: penaltyConfig,
          ),
          const SizedBox(height: 12),
        ],

        // Teacher Notes Field
        Text(
          _tr(
            langCode,
            ar: 'ملاحظات المعلم وتوجيهات التجويد',
            he: 'הערות המורה וטג׳וויד',
            en: 'Teacher Notes & Tajweed Feedback',
          ),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            TextField(
              key: const Key('student_hifz_notes_field'),
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
                  ar: 'اكتب ملاحظات التسميع أو الكلمات التي تحتاج تثبيت...',
                  he: 'כתוב הערות שינון או מילים לחיזוק...',
                  en: 'Write recitation notes or words needing review...',
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

  Widget _buildRecitationUnitCard({
    required BuildContext context,
    required String langCode,
    required int index,
    required TasmeeRecitationUnit unit,
    required GradingPenaltyConfig penaltyConfig,
  }) {
    final surahDef = CenterQuranMap.getSurahById(unit.surahId);
    final score = unit.computedScore(penaltyConfig);
    final isPassed = unit.isPassed(penaltyConfig);
    final minThreshold = unit.unitType == RecitationUnitType.juzExam
        ? penaltyConfig.juzExamPassingThreshold
        : penaltyConfig.pagePassingThreshold;

    void updateUnit(TasmeeRecitationUnit updated) {
      setState(() {
        _units[index] = updated;
        _syncNextAssignmentSuggestion(penaltyConfig);
      });
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: !unit.isGraded
              ? _outline.withValues(alpha: 0.4)
              : (isPassed
                  ? _primary.withValues(alpha: 0.35)
                  : _error.withValues(alpha: 0.4)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row: Unit number + Unit Type chips + Delete button (if > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _units.length > 1
                    ? _tr(
                        langCode,
                        ar: 'مقطع التسميع #${_formatNum(index + 1, langCode)}',
                        he: 'יחידת שינון #${index + 1}',
                        en: 'Recitation Unit #${index + 1}',
                      )
                    : _tr(
                        langCode,
                        ar: 'نوع المقطع المسمّع',
                        he: 'סוג יחידת השינון',
                        en: 'Recited Unit Type',
                      ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _onSurfaceVariant,
                ),
              ),
              if (_units.length > 1)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _units.removeAt(index);
                      _syncNextAssignmentSuggestion(penaltyConfig);
                    });
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: _error,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Unit Type Segmented Chips (Page / Whole Surah / Whole Juz Exam / Partial Read)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: RecitationUnitType.values.map((t) {
              final selected = unit.unitType == t;
              return ChoiceChip(
                label: Text(
                  t.localizedName(langCode),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? _onPrimaryFixed : _onSurfaceVariant,
                  ),
                ),
                selected: selected,
                selectedColor: _primaryFixed,
                backgroundColor: _surfaceContainerLowest,
                onSelected: (_) {
                  updateUnit(
                    unit.copyWith(
                      unitType: t,
                      juzNumber: t == RecitationUnitType.juzExam
                          ? (unit.juzNumber ?? surahDef.primaryJuz)
                          : unit.juzNumber,
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Target selector (Juz selector if juzExam, else Surah + Page selector)
          if (unit.unitType == RecitationUnitType.juzExam)
            Row(
              children: [
                const Icon(Icons.menu_book_rounded, size: 18, color: _primary),
                const SizedBox(width: 8),
                Text(
                  _tr(
                    langCode,
                    ar: 'مراجعة / اختبار الجزء الكامل:',
                    he: 'מבחן / חזרה על ג׳וז מלא:',
                    en: 'Whole Juz Exam / Revision:',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: (unit.juzNumber ?? 30).clamp(1, 30),
                  items: List.generate(30, (i) => i + 1)
                      .map(
                        (j) => DropdownMenuItem<int>(
                          value: j,
                          child: Text(
                            _tr(
                              langCode,
                              ar: 'الجزء ${_formatNum(j, langCode)}',
                              he: 'ג׳וז $j',
                              en: 'Juz $j',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      updateUnit(unit.copyWith(juzNumber: val));
                    }
                  },
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () async {
                      final pickedId = await _openCenterSurahPickerSheet(
                        langCode,
                        currentSurahId: unit.surahId,
                      );
                      if (pickedId != null) {
                        final pickedSurah =
                            CenterQuranMap.getSurahById(pickedId);
                        updateUnit(
                          unit.copyWith(
                            surahId: pickedSurah.id,
                            surahName: pickedSurah.nameAr,
                            pageNumber: pickedSurah.startPage,
                            juzNumber: pickedSurah.primaryJuz,
                            fromAyah: 1,
                            toAyah: pickedSurah.totalVerses,
                            unitType: pickedSurah.isJuz30 &&
                                    unit.unitType == RecitationUnitType.page
                                ? RecitationUnitType.surah
                                : unit.unitType,
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _surfaceContainerHigh),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'سورة ${surahDef.localizedName(langCode)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.expand_more_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                if (unit.unitType == RecitationUnitType.page &&
                    !surahDef.isJuz30) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: _surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _surfaceContainerHigh),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: surahDef.pages.contains(unit.pageNumber)
                              ? unit.pageNumber
                              : surahDef.startPage,
                          items: surahDef.pages
                              .map(
                                (p) => DropdownMenuItem<int>(
                                  value: p,
                                  child: Text(
                                    _tr(
                                      langCode,
                                      ar: 'صفحة ${_formatNum(p, langCode)}',
                                      he: 'עמוד $p',
                                      en: 'Page $p',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (p) {
                            if (p != null) {
                              updateUnit(unit.copyWith(pageNumber: p));
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

          const SizedBox(height: 10),

          // If Partial Read: show informational banner (Note only, no grade)
          if (!unit.isGraded)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _secondaryFixed.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: _secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _tr(
                        langCode,
                        ar: 'قراءة جزئية (أقل من صفحة أو سورة كاملة): تُسجّل كملاحظة متابعة فقط بدون علامة رقمية ولا تُحتسب كصفحة منجزة حتى يتم تسميعها كاملة.',
                        he: 'קריאה חלקית: נרשמת כהערת מעקב בלבד ללא ציון מספרי.',
                        en: 'Partial read (< 1 full page/surah): Recorded with teacher notes only (no numeric grade).',
                      ),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: _secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // 3-Tier Mistake Counters (لفظي / فتح / تعتعة واستدراك)
            Row(
              children: [
                Expanded(
                  child: _MistakeCounterTile(
                    label: _tr(
                      langCode,
                      ar: 'خطأ لفظي',
                      he: 'טעות הגייה',
                      en: 'Verbal (Lafzi)',
                    ),
                    penaltyLabel: '-${penaltyConfig.lafziPenalty}',
                    count: unit.lafziCount,
                    color: _error,
                    onDecrement: unit.lafziCount > 0
                        ? () => updateUnit(
                              unit.copyWith(
                                lafziCount: unit.lafziCount - 1,
                                clearManualScore: true,
                              ),
                            )
                        : null,
                    onIncrement: () => updateUnit(
                      unit.copyWith(
                        lafziCount: unit.lafziCount + 1,
                        clearManualScore: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _MistakeCounterTile(
                    label: _tr(
                      langCode,
                      ar: 'فتح (توقف)',
                      he: 'פתיחה (עצירה)',
                      en: 'Prompt (Fath)',
                    ),
                    penaltyLabel: '-${penaltyConfig.fathPenalty}',
                    count: unit.fathCount,
                    color: _secondary,
                    onDecrement: unit.fathCount > 0
                        ? () => updateUnit(
                              unit.copyWith(
                                fathCount: unit.fathCount - 1,
                                clearManualScore: true,
                              ),
                            )
                        : null,
                    onIncrement: () => updateUnit(
                      unit.copyWith(
                        fathCount: unit.fathCount + 1,
                        clearManualScore: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _MistakeCounterTile(
                    label: _tr(
                      langCode,
                      ar: 'تعتعة / استدراك',
                      he: 'תיקון עצמי',
                      en: 'Self-Correct',
                    ),
                    penaltyLabel: penaltyConfig.tataaPenalty == 0
                        ? '0'
                        : '-${penaltyConfig.tataaPenalty}',
                    count: unit.tataaCount,
                    color: _tertiary,
                    onDecrement: unit.tataaCount > 0
                        ? () => updateUnit(
                              unit.copyWith(
                                tataaCount: unit.tataaCount - 1,
                                clearManualScore: true,
                              ),
                            )
                        : null,
                    onIncrement: () => updateUnit(
                      unit.copyWith(
                        tataaCount: unit.tataaCount + 1,
                        clearManualScore: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Live 0-100 Score Banner + Teacher Override ("إعادة")
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isPassed
                    ? _primaryFixed.withValues(alpha: 0.45)
                    : _error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isPassed ? _primary : _error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_formatNum(score ?? 100, langCode)} / ${_formatNum(100, langCode)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPassed
                                    ? _tr(
                                        langCode,
                                        ar: 'مجتاز بنجاح ✓',
                                        he: 'עבר בהצלחה ✓',
                                        en: 'Passed ✓',
                                      )
                                    : _tr(
                                        langCode,
                                        ar: 'يحتاج إعادة التسميع',
                                        he: 'דורש חזרה',
                                        en: 'Needs Repeat',
                                      ),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: isPassed ? _primary : _error,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _tr(
                                  langCode,
                                  ar: 'علامة النجاح: ${_formatNum(minThreshold, langCode)} فأعلى',
                                  he: 'ציון מעבר: $minThreshold ומעלה',
                                  en: 'Passing score: >= $minThreshold',
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Teacher Override Checkbox: Require Repeat regardless of score
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: unit.forceRepeat,
                        activeColor: _error,
                        visualDensity: VisualDensity.compact,
                        onChanged: (val) {
                          updateUnit(unit.copyWith(forceRepeat: val ?? false));
                        },
                      ),
                      Text(
                        _tr(
                          langCode,
                          ar: 'إلزام بالإعادة',
                          he: 'חייב חזרה',
                          en: 'Force Repeat',
                        ),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: _error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionB({
    required BuildContext context,
    required String langCode,
    required SurahPageDefinition nextSurah,
    required GradingPenaltyConfig penaltyConfig,
  }) {
    final lastUnit = _units.isNotEmpty ? _units.last : null;
    final isRollover = !_assignOnlyMode &&
        lastUnit != null &&
        (!lastUnit.isGraded || !lastUnit.isPassed(penaltyConfig));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section B Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
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
                      _assignOnlyMode
                          ? (langCode == 'ar' ? '١' : '1')
                          : (langCode == 'ar' ? '٢' : '2'),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: _onPrimaryFixed,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _assignOnlyMode
                          ? _tr(
                              langCode,
                              ar: 'تفاصيل الواجب المقرر للطالب',
                              he: 'פרטי המטלה לתלמיד',
                              en: 'Student Assignment Details',
                            )
                          : _tr(
                              langCode,
                              ar: 'تحديد الواجب القادم (قابل للتعديل)',
                              he: 'קביעת המטלה הבאה',
                              en: 'Next Assignment (Editable)',
                            ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _primary,
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (!_assignOnlyMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isRollover
                      ? _error.withValues(alpha: 0.12)
                      : _primaryFixed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isRollover
                      ? _tr(
                          langCode,
                          ar: 'ترحيل للإعادة',
                          he: 'הועבר לחזרה',
                          en: 'Rollover for Repeat',
                        )
                      : _tr(
                          langCode,
                          ar: 'مقترح تلقائياً',
                          he: 'מוצע אוטומטית',
                          en: 'Auto-Suggested',
                        ),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isRollover ? _error : _onPrimaryFixed,
                  ),
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
                        Flexible(
                          child: Text(
                            _tr(
                              langCode,
                              ar: 'حفظ جديد (صفحة / سورة)',
                              he: 'שינון חדש (עמוד / סורה)',
                              en: 'New Hifz (Page / Surah)',
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: _nextAssignmentType ==
                                          AssignmentType.newHifz
                                      ? _primary
                                      : _onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
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
                        Flexible(
                          child: Text(
                            _tr(
                              langCode,
                              ar: 'مراجعة / اختبار جزء كامل',
                              he: 'חזרה / מבחן ג׳וז מלא',
                              en: 'Whole Juz Revision / Exam',
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: _nextAssignmentType ==
                                          AssignmentType.revision
                                      ? _primary
                                      : _onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
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

        if (_nextAssignmentType == AssignmentType.revision)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _surfaceContainerHigh),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _tr(
                    langCode,
                    ar: 'الجزء المقرر للمراجعة / الاختبار:',
                    he: 'הג׳וז שנקבע לחזרה / מבחן:',
                    en: 'Assigned Juz for Revision / Exam:',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                DropdownButton<int>(
                  value: _nextJuzNumber.clamp(1, 30),
                  items: List.generate(30, (i) => i + 1)
                      .map(
                        (j) => DropdownMenuItem<int>(
                          value: j,
                          child: Text(
                            _tr(
                              langCode,
                              ar: 'الجزء ${_formatNum(j, langCode)} كامل',
                              he: 'ג׳וז $j מלא',
                              en: 'Whole Juz $j',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final firstSurahInJuz =
                          CenterQuranMap.getSurahsByJuz(val).firstOrNull ??
                              CenterQuranMap.surahs.first;
                      setState(() {
                        _nextJuzNumber = val;
                        _nextSurahId = firstSurahInJuz.id;
                        _nextTargetPage =
                            CenterQuranMap.getJuzPageRange(val).startPage;
                      });
                    }
                  },
                ),
              ],
            ),
          )
        else ...[
          // Surah + Page Selector Card from CenterQuranMap (114 Surahs)
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Material(
                  color: _surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () async {
                      final picked = await _openCenterSurahPickerSheet(
                        langCode,
                        currentSurahId: _nextSurahId,
                      );
                      if (picked != null && mounted) {
                        final s = CenterQuranMap.getSurahById(picked);
                        setState(() {
                          _nextSurahId = s.id;
                          _nextTargetPage = s.startPage;
                          _nextJuzNumber = s.primaryJuz;
                          _fromAyahController.text = '1';
                          _toAyahController.text = '${s.totalVerses}';
                        });
                      }
                    },
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'سورة ${nextSurah.localizedName(langCode)} (${_formatNum(nextSurah.id, langCode)})',
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
                                  nextSurah.isJuz30
                                      ? _tr(
                                          langCode,
                                          ar: 'الجزء ٣٠ • سورة كاملة (صفحة واحدة بجدول المركز)',
                                          he: 'ג׳וז 30 • סורה מלאה',
                                          en: 'Juz 30 • Whole Surah (1 Center Page)',
                                        )
                                      : _tr(
                                          langCode,
                                          ar: 'الجزء ${_formatNum(nextSurah.primaryJuz, langCode)} • الصفحات ${_formatNum(nextSurah.startPage, langCode)}-${_formatNum(nextSurah.endPage, langCode)}',
                                          he: 'ג׳וז ${nextSurah.primaryJuz} • עמ׳ ${nextSurah.startPage}-${nextSurah.endPage}',
                                          en: 'Juz ${nextSurah.primaryJuz} • Pages ${nextSurah.startPage}-${nextSurah.endPage}',
                                        ),
                                  style: const TextStyle(
                                    color: _onSurfaceVariant,
                                    fontSize: 11,
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
              ),
              if (!nextSurah.isJuz30) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _surfaceContainerHigh),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: nextSurah.pages.contains(_nextTargetPage)
                            ? _nextTargetPage
                            : nextSurah.startPage,
                        items: nextSurah.pages
                            .map(
                              (p) => DropdownMenuItem<int>(
                                value: p,
                                child: Text(
                                  _tr(
                                    langCode,
                                    ar: 'صفحة ${_formatNum(p, langCode)}',
                                    he: 'עמוד $p',
                                    en: 'Page $p',
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _nextTargetPage = val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Ayah Range Dual Inputs (من آية / إلى آية)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fromAyahController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: _tr(
                      langCode,
                      ar: 'من آية',
                      he: 'מפסוק',
                      en: 'From Ayah',
                    ),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _toAyahController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: _tr(
                      langCode,
                      ar: 'إلى آية',
                      he: 'עד פסוק',
                      en: 'To Ayah',
                    ),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _MistakeCounterTile extends StatelessWidget {
  final String label;
  final String penaltyLabel;
  final int count;
  final Color color;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _MistakeCounterTile({
    required this.label,
    required this.penaltyLabel,
    required this.count,
    required this.color,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: count > 0
              ? color.withValues(alpha: 0.5)
              : const Color(0xFFE6E8EA),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191C1E),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '($penaltyLabel)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: onDecrement,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.remove_rounded, size: 16),
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: count > 0 ? color : const Color(0xFF191C1E),
                ),
              ),
              InkWell(
                onTap: onIncrement,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.add_rounded, size: 16, color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
