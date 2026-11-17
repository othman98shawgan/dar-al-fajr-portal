import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/surah_page_map.dart';
import '../../../core/services/locale_provider.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../models/teacher_models.dart';
import '../providers/teacher_providers.dart';
import '../widgets/tasmee_homework_section.dart';
import '../widgets/tasmee_modal_tokens.dart';
import '../widgets/tasmee_recitation_unit_card.dart';

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
    this.groupId = '',
    this.groupTitle = '',
    this.studentId = '',
    this.studentName = '',
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
    String groupId = '',
    String groupTitle = '',
    String studentId = '',
    String studentName = '',
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
          initialGrade: initialGrade == EvaluationGrade.pending ? EvaluationGrade.excellent : initialGrade,
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

  String get _effectiveGroupId => widget.groupId.isNotEmpty ? widget.groupId : (Firebase.apps.isEmpty ? 'grp-hifz-1' : '');

  String get _effectiveGroupTitle =>
      widget.groupTitle.isNotEmpty ? widget.groupTitle : (Firebase.apps.isEmpty ? 'حلقة أبي بكر الصديق' : '');

  String get _effectiveStudentId =>
      widget.studentId.isNotEmpty ? widget.studentId : (Firebase.apps.isEmpty ? 'st-1042' : '');

  String get _effectiveStudentName =>
      widget.studentName.isNotEmpty ? widget.studentName : (Firebase.apps.isEmpty ? 'إبراهيم طه عثمان' : '');

  @override
  void initState() {
    super.initState();
    _assignOnlyMode = widget.assignOnlyMode;
    _notesController = TextEditingController(text: widget.initialNotes);

    final initialSurah = CenterQuranMap.getSurahById(widget.currentSurahId);
    final initialUnitType = widget.currentType == AssignmentType.revision
        ? RecitationUnitType.juzExam
        : (initialSurah.isJuz30 ? RecitationUnitType.surah : RecitationUnitType.page);

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
      _fromAyahController = TextEditingController(text: '${widget.currentFromAyah}');
      _toAyahController = TextEditingController(text: '${widget.currentToAyah}');
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
      _toAyahController = TextEditingController(text: '${nextSurah.totalVerses}');
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _fromAyahController.dispose();
    _toAyahController.dispose();
    super.dispose();
  }

  void _syncNextAssignmentSuggestion(GradingPenaltyConfig config) {
    if (_assignOnlyMode || _units.isEmpty) return;
    final lastUnit = _units.last;
    if (lastUnit.unitType == RecitationUnitType.partialRead) {
      final s = CenterQuranMap.getSurahById(lastUnit.surahId);
      _nextSurahId = s.id;
      _nextTargetPage = lastUnit.pageNumber ?? s.startPage;
      _fromAyahController.text = '${lastUnit.fromAyah}';
      _toAyahController.text = '${lastUnit.toAyah}';
      return;
    }

    final passed = lastUnit.isPassed(config);
    if (!passed) {
      final s = CenterQuranMap.getSurahById(lastUnit.surahId);
      _nextSurahId = s.id;
      _nextTargetPage = lastUnit.pageNumber ?? s.startPage;
      _nextJuzNumber = lastUnit.juzNumber ?? s.primaryJuz;
      _fromAyahController.text = '${lastUnit.fromAyah}';
      _toAyahController.text = '${lastUnit.toAyah}';
    } else {
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
          unitType: nextSurah.isJuz30 ? RecitationUnitType.surah : RecitationUnitType.page,
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

  Future<void> _handleSave(
    String langCode,
    GradingPenaltyConfig penaltyConfig,
  ) async {
    if (_isSaving) return;
    if (_effectiveStudentId.isEmpty || _effectiveGroupId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            trByLang(
              langCode,
              ar: 'بيانات الطالب أو الحلقة غير مكتملة',
              he: 'פרטי התלמיד או הקבוצה חסרים',
              en: 'Student or group details are missing',
            ),
          ),
          backgroundColor: TasmeeModalTokens.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final nextSurah = CenterQuranMap.getSurahById(_nextSurahId);
    final nextFromAyah = int.tryParse(_fromAyahController.text.trim()) ?? 1;
    final nextToAyah = int.tryParse(_toAyahController.text.trim()) ?? nextSurah.totalVerses;

    if (_assignOnlyMode) {
      await ref.read(teacherControllerProvider.notifier).saveHifzAssignment(
            existingAssignmentId: widget.existingAssignmentId,
            studentId: _effectiveStudentId,
            studentName: _effectiveStudentName,
            groupId: _effectiveGroupId,
            type: _nextAssignmentType,
            surahId: nextSurah.id,
            surahName: nextSurah.nameAr,
            fromAyah: nextFromAyah,
            toAyah: nextToAyah,
            targetPage: _nextTargetPage,
            juzNumber: _nextAssignmentType == AssignmentType.revision ? _nextJuzNumber : nextSurah.primaryJuz,
            isJuzExam: _nextAssignmentType == AssignmentType.revision,
            grade: EvaluationGrade.pending,
            teacherNotes: _notesController.text.trim(),
          );
    } else {
      final primaryUnit = _units.first;
      final primarySurah = CenterQuranMap.getSurahById(primaryUnit.surahId);
      final isPartial = primaryUnit.unitType == RecitationUnitType.partialRead;
      final isJuzRevision = primaryUnit.unitType == RecitationUnitType.juzExam;

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
        final allPassed = gradedUnits.every((u) => u.isPassed(penaltyConfig));
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
            studentId: _effectiveStudentId,
            studentName: _effectiveStudentName,
            groupId: _effectiveGroupId,
            type: isJuzRevision ? AssignmentType.revision : AssignmentType.newHifz,
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
              ? trByLang(
                  langCode,
                  ar: 'تم حفظ واجب الطالب ($_effectiveStudentName) بنجاح!',
                  he: 'מטלת התלמיד נשמרה בהצלחה!',
                  en: 'Student assignment saved successfully!',
                )
              : trByLang(
                  langCode,
                  ar: 'تم حفظ جلسة التسميع وتحديث تقدم ($_effectiveStudentName) وجدولة الواجب القادم!',
                  he: 'מפגש השינון נשמר והמטלה הבאה נקבעה בהצלחה!',
                  en: 'Recitation saved, progress updated & next assignment scheduled!',
                ),
        ),
        backgroundColor: TasmeeModalTokens.tertiary,
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
    final penaltyConfig = ref.watch(gradingPenaltyConfigProvider).asData?.value ?? const GradingPenaltyConfig();
    final nextSurah = CenterQuranMap.getSurahById(_nextSurahId);
    final lastUnit = _units.isNotEmpty ? _units.last : null;
    final isRollover =
        !_assignOnlyMode && lastUnit != null && (!lastUnit.isGraded || !lastUnit.isPassed(penaltyConfig));

    final sheetContent = Container(
      decoration: const BoxDecoration(
        color: TasmeeModalTokens.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, -4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: TasmeeModalTokens.surfaceContainerLowest,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: TasmeeModalTokens.surfaceVariant,
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
                                ? trByLang(
                                    langCode,
                                    ar: 'تحديد / تعديل واجب الطالب',
                                    he: 'קביעת / עריכת מטלת תלמיד',
                                    en: 'Assign / Edit Student Homework',
                                  )
                                : trByLang(
                                    langCode,
                                    ar: 'جلسة تسميع وتحديد الواجب',
                                    he: 'מפגש שינון וקביעת מטלה',
                                    en: 'Recitation (Tasmee) & Next Assignment',
                                  ),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: TasmeeModalTokens.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: TasmeeModalTokens.onSurfaceVariant,
                                  ),
                              children: [
                                TextSpan(text: '$_effectiveStudentName • '),
                                TextSpan(
                                  text: _effectiveGroupTitle,
                                  style: const TextStyle(
                                    color: TasmeeModalTokens.primary,
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
                      color: TasmeeModalTokens.surfaceContainerHigh,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        customBorder: const CircleBorder(),
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(Icons.close_rounded, size: 20, color: TasmeeModalTokens.onSurface),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: TasmeeModalTokens.surfaceContainer,
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
                              color: !_assignOnlyMode ? TasmeeModalTokens.surfaceContainerLowest : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              trByLang(
                                langCode,
                                ar: '🎙️ جلسة تسميع وتقييم',
                                he: '🎙️ מפגש שינון והערכה',
                                en: '🎙️ Tasmee Evaluation',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: !_assignOnlyMode ? TasmeeModalTokens.primary : TasmeeModalTokens.onSurfaceVariant,
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
                              color: _assignOnlyMode ? TasmeeModalTokens.surfaceContainerLowest : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              trByLang(
                                langCode,
                                ar: '📝 تحديد / تعديل واجب فقط',
                                he: '📝 קביעת / עריכת מטלה בלבד',
                                en: '📝 Assign / Edit Only',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _assignOnlyMode ? TasmeeModalTokens.primary : TasmeeModalTokens.onSurfaceVariant,
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
                  TasmeeHomeworkSection(
                    langCode: langCode,
                    assignOnlyMode: _assignOnlyMode,
                    isRollover: isRollover,
                    nextAssignmentType: _nextAssignmentType,
                    nextSurahId: _nextSurahId,
                    nextSurah: nextSurah,
                    nextTargetPage: _nextTargetPage,
                    nextJuzNumber: _nextJuzNumber,
                    fromAyahController: _fromAyahController,
                    toAyahController: _toAyahController,
                    onAssignmentTypeChanged: (t) => setState(() => _nextAssignmentType = t),
                    onJuzChanged: (val) {
                      final firstSurahInJuz =
                          CenterQuranMap.getSurahsByJuz(val).firstOrNull ?? CenterQuranMap.surahs.first;
                      setState(() {
                        _nextJuzNumber = val;
                        _nextSurahId = firstSurahInJuz.id;
                        _nextTargetPage = CenterQuranMap.getJuzPageRange(val).startPage;
                      });
                    },
                    onSurahPicked: (s) {
                      if (!mounted) return;
                      setState(() {
                        _nextSurahId = s.id;
                        _nextTargetPage = s.startPage;
                        _nextJuzNumber = s.primaryJuz;
                        _fromAyahController.text = '1';
                        _toAyahController.text = '${s.totalVerses}';
                      });
                    },
                    onPageChanged: (val) => setState(() => _nextTargetPage = val),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      key: const Key('student_hifz_save_button'),
                      onPressed: _isSaving ? null : () => _handleSave(langCode, penaltyConfig),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSavedSuccess ? TasmeeModalTokens.tertiary : TasmeeModalTokens.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: Icon(
                        _isSaving
                            ? Icons.sync_rounded
                            : (_isSavedSuccess ? Icons.check_circle_rounded : Icons.verified_rounded),
                        size: 20,
                      ),
                      label: Text(
                        _isSaving
                            ? trByLang(langCode, ar: 'جاري الحفظ...', he: 'שומר...', en: 'Saving...')
                            : (_isSavedSuccess
                                ? trByLang(langCode, ar: 'تم الحفظ بنجاح', he: 'נשמר בהצלחה', en: 'Saved Successfully')
                                : (_assignOnlyMode
                                    ? trByLang(langCode, ar: 'حفظ الواجب المقرر', he: 'שמור מטלה', en: 'Save Assignment')
                                    : trByLang(
                                        langCode,
                                        ar: 'حفظ التسميع والواجب القادم',
                                        he: 'שמור הערכה ומטלה',
                                        en: 'Save Evaluation & Next Assignment',
                                      ))),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: TextButton.styleFrom(foregroundColor: TasmeeModalTokens.onSurfaceVariant),
                    child: Text(
                      trByLang(langCode, ar: 'إلغاء والتراجع', he: 'ביטול וחזרה', en: 'Cancel & Go Back'),
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
              backgroundColor: TasmeeModalTokens.surface,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(color: TasmeeModalTokens.primaryFixed, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(
                      langCode == 'ar' ? '١' : '1',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: TasmeeModalTokens.onPrimaryFixed,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      trByLang(
                        langCode,
                        ar: 'تقييم التسميع الحالي (٠ - ١٠٠)',
                        he: 'הערכת השינון הנוכחי (0 - 100)',
                        en: 'Evaluate Recitation (0 - 100)',
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: TasmeeModalTokens.primary,
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
                trByLang(
                  langCode,
                  ar: 'إضافة صفحة/سورة بالجلسة',
                  he: 'הוסף עמוד/סורה במפגש',
                  en: 'Add Unit in Sitting',
                ),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (int index = 0; index < _units.length; index++) ...[
          TasmeeRecitationUnitCard(
            langCode: langCode,
            index: index,
            totalUnits: _units.length,
            unit: _units[index],
            penaltyConfig: penaltyConfig,
            onUpdateUnit: (updated) {
              setState(() {
                _units[index] = updated;
                _syncNextAssignmentSuggestion(penaltyConfig);
              });
            },
            onDeleteUnit: _units.length > 1
                ? () {
                    setState(() {
                      _units.removeAt(index);
                      _syncNextAssignmentSuggestion(penaltyConfig);
                    });
                  }
                : null,
          ),
          const SizedBox(height: 12),
        ],
        Text(
          trByLang(
            langCode,
            ar: 'ملاحظات المعلم وتوجيهات التجويد',
            he: 'הערות המורה וטג׳וויד',
            en: 'Teacher Notes & Tajweed Feedback',
          ),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: TasmeeModalTokens.onSurfaceVariant,
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TasmeeModalTokens.onSurface),
              decoration: InputDecoration(
                fillColor: TasmeeModalTokens.surfaceContainerLowest,
                filled: true,
                hintText: trByLang(
                  langCode,
                  ar: 'اكتب ملاحظات التسميع أو الكلمات التي تحتاج تثبيت...',
                  he: 'כתוב הערות שינון או מילים לחיזוק...',
                  en: 'Write recitation notes or words needing review...',
                ),
                hintStyle: const TextStyle(color: TasmeeModalTokens.outline, fontSize: 12),
                contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 44, top: 10, bottom: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: TasmeeModalTokens.surfaceContainerHigh),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: TasmeeModalTokens.surfaceContainerHigh),
                ),
              ),
            ),
            PositionedDirectional(
              bottom: 8,
              end: 8,
              child: Material(
                color: _isVoiceNoteRecording ? TasmeeModalTokens.primaryFixed : TasmeeModalTokens.surfaceContainerHigh,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isVoiceNoteRecording = !_isVoiceNoteRecording;
                      if (_isVoiceNoteRecording && _notesController.text.trim().isEmpty) {
                        _notesController.text = 'تنبيه على تحقيق المد المتصل وترقيق الراء في الآيات الكريمة.';
                      }
                    });
                  },
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(Icons.mic_rounded, size: 18, color: TasmeeModalTokens.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
