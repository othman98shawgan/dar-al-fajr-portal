import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/quran_metadata.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/services/locale_provider.dart';
import '../../../core/services/quran_metadata_service.dart';
import '../models/teacher_models.dart';
import '../providers/teacher_providers.dart';

enum _AssignmentFilterTab {
  all,
  newHifz,
  revision,
  pending,
}

class _AssignmentCardItem {
  final String id;
  final String studentId;
  final String studentName;
  final String initial;
  final String timeSubtitle;
  final bool isPendingTimeAlert;
  final AssignmentType assignmentType;
  final String assignmentBadgeLabel;
  final int surahId;
  final String surahName;
  final int fromAyah;
  final int toAyah;
  final String rangeTitle;
  final EvaluationGrade grade;
  final String gradeBadgeLabel;
  final double progressFactor;
  final String feedbackText;
  final String audioDurationLabel;
  final bool isFromFirestore;

  const _AssignmentCardItem({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.initial,
    required this.timeSubtitle,
    this.isPendingTimeAlert = false,
    required this.assignmentType,
    required this.assignmentBadgeLabel,
    required this.surahId,
    required this.surahName,
    required this.fromAyah,
    required this.toAyah,
    required this.rangeTitle,
    required this.grade,
    required this.gradeBadgeLabel,
    required this.progressFactor,
    required this.feedbackText,
    required this.audioDurationLabel,
    this.isFromFirestore = false,
  });
}

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailScreen({
    super.key,
    this.groupId = '',
  });

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  bool _orderByDate = false;
  _AssignmentFilterTab _activeFilter = _AssignmentFilterTab.all;
  bool _showSearchField = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Design tokens from Stitch
  static const Color _surface = Color(0xFFF7F9FB);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color _surfaceContainer = Color(0xFFECEEF0);
  static const Color _surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color _onSurface = Color(0xFF191C1E);
  static const Color _onSurfaceVariant = Color(0xFF3D4947);
  static const Color _primary = Color(0xFF00685F);
  static const Color _primaryContainer = Color(0xFF008378);
  static const Color _secondary = Color(0xFF904D00);
  static const Color _secondaryContainer = Color(0xFFFE932C);
  static const Color _secondaryFixed = Color(0xFFFFDCC3);
  static const Color _onSecondaryFixed = Color(0xFF2F1500);
  static const Color _onSecondaryFixedVariant = Color(0xFF6E3900);
  static const Color _onSecondaryContainer = Color(0xFF663500);

  static const List<_AssignmentCardItem> _seedCards = [
    _AssignmentCardItem(
      id: 'seed-assign-1',
      studentId: 'st-1042',
      studentName: 'إبراهيم طه عثمان',
      initial: 'إ',
      timeSubtitle: 'اليوم • ٤:١٥ م',
      assignmentType: AssignmentType.newHifz,
      assignmentBadgeLabel: 'مقرر الحفظ الجديد كاملاً',
      surahId: 16,
      surahName: 'النحل',
      fromAyah: 1,
      toAyah: 128,
      rangeTitle: 'سورة النحل: الآية 1 إلى 128',
      grade: EvaluationGrade.excellent,
      gradeBadgeLabel: 'ممتاز (٩٨٪)',
      progressFactor: 1.0,
      feedbackText:
          'ما شاء الله، إتقان متين لأحكام النون الساكنة والمد المتصل، قراءة خاشعة وحضور ذهني متميز.',
      audioDurationLabel: 'تسجيل صوتي (٨ د)',
    ),
    _AssignmentCardItem(
      id: 'seed-assign-2',
      studentId: 'st-1088',
      studentName: 'عبد الرحمن يوسف الشريف',
      initial: 'ع',
      timeSubtitle: 'اليوم • ٤:٤٠ م',
      assignmentType: AssignmentType.revision,
      assignmentBadgeLabel: 'مراجعة صغرى',
      surahId: 15,
      surahName: 'الحجر',
      fromAyah: 1,
      toAyah: 48,
      rangeTitle: 'سورة الحجر: من الآية 1 إلى 48',
      grade: EvaluationGrade.good,
      gradeBadgeLabel: 'جيد جداً (٨٥٪)',
      progressFactor: 0.85,
      feedbackText:
          'تنبيه لموضع القلقلة في آية ٢٣ والانتباه لترقيق الراء الساكنة المسبوقة بكسر. المراجعة العامة طيبة.',
      audioDurationLabel: 'تسجيل صوتي (٥ د)',
    ),
    _AssignmentCardItem(
      id: 'seed-assign-3',
      studentId: 'st-1102',
      studentName: 'زياد المنصور',
      initial: 'ز',
      timeSubtitle: 'موعد التسميع اليوم ٥:٣٠ م',
      isPendingTimeAlert: true,
      assignmentType: AssignmentType.newHifz,
      assignmentBadgeLabel: 'حفظ جديد',
      surahId: 16,
      surahName: 'النحل',
      fromAyah: 1,
      toAyah: 35,
      rangeTitle: 'سورة النحل: الآية 1 إلى 35',
      grade: EvaluationGrade.pending,
      gradeBadgeLabel: 'بانتظار التقييم',
      progressFactor: 0.20,
      feedbackText:
          'لم يتم التسميع بعد - مقرر اليوم ٥:٣٠ م، جاهز للاستماع والرصد المباشر.',
      audioDurationLabel: 'تم تذكير الطالب',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
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

  List<_AssignmentCardItem> _buildAssignmentCards(
    List<HifzAssignment> firestoreAssignments,
    String langCode,
  ) {
    final mappedFirestore = firestoreAssignments.map((item) {
      final trimmed = item.studentName.trim();
      final initial = trimmed.isNotEmpty ? trimmed.characters.first : 'ط';
      final isPending = item.grade == EvaluationGrade.pending;
      final isExcellent = item.grade == EvaluationGrade.excellent;
      final isGood = item.grade == EvaluationGrade.good;

      final gradeBadge = switch (item.grade) {
        EvaluationGrade.excellent => _tr(
            langCode,
            ar: 'ممتاز (٩٨٪)',
            he: 'מצוין (98%)',
            en: 'Excellent (98%)',
          ),
        EvaluationGrade.good => _tr(
            langCode,
            ar: 'جيد جداً (٨٥٪)',
            he: 'טוב מאוד (85%)',
            en: 'Very Good (85%)',
          ),
        EvaluationGrade.needsRepeat => _tr(
            langCode,
            ar: 'يحتاج إعادة',
            he: 'דורש חזרה',
            en: 'Needs Repeat',
          ),
        EvaluationGrade.pending => _tr(
            langCode,
            ar: 'بانتظار التقييم',
            he: 'ממתין להערכה',
            en: 'Pending Evaluation',
          ),
      };

      return _AssignmentCardItem(
        id: item.id,
        studentId: item.studentId,
        studentName: item.studentName.isNotEmpty ? item.studentName : 'طالب الحلقة',
        initial: initial,
        timeSubtitle: isPending ? 'موعد التسميع اليوم ٥:٣٠ م' : 'اليوم • تم الرصد',
        isPendingTimeAlert: isPending,
        assignmentType: item.type,
        assignmentBadgeLabel: item.type.localizedName(langCode),
        surahId: item.surahId,
        surahName: item.surahName,
        fromAyah: item.fromAyah,
        toAyah: item.toAyah,
        rangeTitle:
            'سورة ${item.surahName}: الآية ${item.fromAyah} إلى ${item.toAyah}',
        grade: item.grade,
        gradeBadgeLabel: gradeBadge,
        progressFactor: isExcellent
            ? 1.0
            : (isGood ? 0.85 : (isPending ? 0.20 : 0.45)),
        feedbackText: item.teacherNotes.isNotEmpty
            ? item.teacherNotes
            : (isPending
                ? 'لم يتم التسميع بعد - جاهز للاستماع والرصد المباشر.'
                : 'تم تسميع المقرر بنجاح وتحديث سجل الإنجاز القرآني.'),
        audioDurationLabel: isPending ? 'تم تذكير الطالب' : 'تسجيل صوتي (٦ د)',
        isFromFirestore: true,
      );
    }).toList();

    final combined = [...mappedFirestore, ..._seedCards];

    final filtered = combined.where((card) {
      if (_activeFilter == _AssignmentFilterTab.newHifz &&
          card.assignmentType != AssignmentType.newHifz) {
        return false;
      }
      if (_activeFilter == _AssignmentFilterTab.revision &&
          card.assignmentType != AssignmentType.revision) {
        return false;
      }
      if (_activeFilter == _AssignmentFilterTab.pending &&
          card.grade != EvaluationGrade.pending) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        return card.studentName.toLowerCase().contains(q) ||
            card.rangeTitle.toLowerCase().contains(q) ||
            card.feedbackText.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    if (!_orderByDate) {
      filtered.sort((a, b) => a.studentName.compareTo(b.studentName));
    }

    return filtered;
  }

  void _openAttendanceView(String effectiveGroupId) {
    context.push('${AppRoutes.teacherAttendance}/$effectiveGroupId');
  }

  Future<void> _showAssignmentEvaluationModal({
    required BuildContext context,
    required String langCode,
    required String effectiveGroupId,
    _AssignmentCardItem? existingCard,
  }) async {
    final quranService = ref.read(quranMetadataServiceProvider);
    if (quranService.surahs.isEmpty) {
      try {
        await quranService.loadMetadata();
      } catch (_) {}
    }

    if (!context.mounted) return;

    final surahs = quranService.surahs;
    int selectedSurahId = existingCard?.surahId ?? 16;
    SurahMetadata? selectedSurah = quranService.getSurahById(selectedSurahId) ??
        (surahs.isNotEmpty ? surahs.first : null);

    final studentNameCtrl = TextEditingController(
      text: existingCard?.studentName ?? 'إبراهيم طه عثمان',
    );
    final fromAyahCtrl = TextEditingController(
      text: '${existingCard?.fromAyah ?? 1}',
    );
    final toAyahCtrl = TextEditingController(
      text: '${existingCard?.toAyah ?? (selectedSurah?.totalVerses ?? 30)}',
    );
    final notesCtrl = TextEditingController(
      text: existingCard != null &&
              existingCard.grade != EvaluationGrade.pending
          ? existingCard.feedbackText
          : '',
    );

    AssignmentType selectedType =
        existingCard?.assignmentType ?? AssignmentType.newHifz;
    EvaluationGrade selectedGrade = existingCard != null &&
            existingCard.grade != EvaluationGrade.pending
        ? existingCard.grade
        : EvaluationGrade.excellent;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final fromAyah = int.tryParse(fromAyahCtrl.text.trim()) ?? 1;
            final toAyah = int.tryParse(toAyahCtrl.text.trim()) ?? 10;
            final touchedPages = quranService.surahs.isNotEmpty
                ? quranService.calculatePages(
                    selectedSurahId,
                    fromAyah,
                    toAyah,
                  )
                : <int>[];
            final touchedJuz = quranService.surahs.isNotEmpty
                ? quranService.calculateJuz(
                    selectedSurahId,
                    fromAyah,
                    toAyah,
                  )
                : <int>[];

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existingCard == null
                              ? _tr(
                                  langCode,
                                  ar: 'إضافة واجب وتقييم جديد',
                                  he: 'הוספת מטלה והערכה חדשה',
                                  en: 'Add New Assignment & Grade',
                                )
                              : _tr(
                                  langCode,
                                  ar: 'تقييم ورصد تسميع الطالب',
                                  he: 'הערכת שינון תלמיד',
                                  en: 'Evaluate Student Recitation',
                                ),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _onSurface,
                                  ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Student Name
                    TextField(
                      controller: studentNameCtrl,
                      decoration: InputDecoration(
                        labelText: _tr(
                          langCode,
                          ar: 'اسم الطالب',
                          he: 'שם התלמיד',
                          en: 'Student Name',
                        ),
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Assignment Type Toggle (New Hifz vs Revision)
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(
                              _tr(
                                langCode,
                                ar: 'حفظ جديد',
                                he: 'שינון חדש',
                                en: 'New Hifz',
                              ),
                            ),
                            selected: selectedType == AssignmentType.newHifz,
                            onSelected: (_) {
                              setModalState(() {
                                selectedType = AssignmentType.newHifz;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(
                              _tr(
                                langCode,
                                ar: 'مراجعة',
                                he: 'חזרה',
                                en: 'Revision',
                              ),
                            ),
                            selected: selectedType == AssignmentType.revision,
                            onSelected: (_) {
                              setModalState(() {
                                selectedType = AssignmentType.revision;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Surah Selector Dropdown
                    if (surahs.isNotEmpty)
                      DropdownButtonFormField<int>(
                        initialValue: selectedSurahId,
                        decoration: InputDecoration(
                          labelText: _tr(
                            langCode,
                            ar: 'السورة الكريمة',
                            he: 'סורה',
                            en: 'Surah',
                          ),
                          prefixIcon: const Icon(Icons.menu_book_rounded),
                        ),
                        items: surahs.map((s) {
                          return DropdownMenuItem<int>(
                            value: s.id,
                            child: Text(
                              '${s.id}. سورة ${s.nameArabic} (${s.totalVerses} آية)',
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setModalState(() {
                            selectedSurahId = val;
                            selectedSurah = quranService.getSurahById(val);
                            fromAyahCtrl.text = '1';
                            toAyahCtrl.text =
                                '${selectedSurah?.totalVerses ?? 30}';
                          });
                        },
                      ),
                    const SizedBox(height: 12),

                    // From Ayah & To Ayah
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: fromAyahCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setModalState(() {}),
                            decoration: InputDecoration(
                              labelText: _tr(
                                langCode,
                                ar: 'من الآية',
                                he: 'מפסוק',
                                en: 'From Ayah',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: toAyahCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setModalState(() {}),
                            decoration: InputDecoration(
                              labelText: _tr(
                                langCode,
                                ar: 'إلى الآية',
                                he: 'עד פסוק',
                                en: 'To Ayah',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Automated Quran Engine Preview
                    if (touchedPages.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_graph_rounded,
                              size: 18,
                              color: _primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'حساب المصحف التلقائي: ${touchedPages.length} صفحة (ص ${touchedPages.first} - ${touchedPages.last}) • الجزء: ${touchedJuz.join("، ")}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),

                    // Grade Selection
                    Text(
                      _tr(
                        langCode,
                        ar: 'درجة التقييم',
                        he: 'ציון הערכה',
                        en: 'Evaluation Grade',
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('ممتاز (٩٨٪)'),
                          selected: selectedGrade == EvaluationGrade.excellent,
                          onSelected: (_) => setModalState(
                            () => selectedGrade = EvaluationGrade.excellent,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('جيد جداً (٨٥٪)'),
                          selected: selectedGrade == EvaluationGrade.good,
                          onSelected: (_) => setModalState(
                            () => selectedGrade = EvaluationGrade.good,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('يحتاج إعادة'),
                          selected:
                              selectedGrade == EvaluationGrade.needsRepeat,
                          onSelected: (_) => setModalState(
                            () => selectedGrade = EvaluationGrade.needsRepeat,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('بانتظار التقييم'),
                          selected: selectedGrade == EvaluationGrade.pending,
                          onSelected: (_) => setModalState(
                            () => selectedGrade = EvaluationGrade.pending,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Teacher Notes
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: _tr(
                          langCode,
                          ar: 'ملاحظات المعلم والتجويد',
                          he: 'הערות המורה וטג׳וויד',
                          en: 'Teacher Recitation Feedback',
                        ),
                        hintText:
                            'اكتب ملاحظات التجويد ومواضع الإتقان أو التنبيه...',
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Save Button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final surahObj =
                              quranService.getSurahById(selectedSurahId);
                          final surahNameAr =
                              surahObj?.nameArabic ?? 'النحل';
                          final studentName =
                              studentNameCtrl.text.trim().isNotEmpty
                                  ? studentNameCtrl.text.trim()
                                  : 'إبراهيم طه عثمان';
                          final studentId =
                              existingCard?.studentId ?? 'st-1042';

                          Navigator.of(sheetContext).pop();

                          await ref
                              .read(teacherControllerProvider.notifier)
                              .saveHifzAssignment(
                                studentId: studentId,
                                studentName: studentName,
                                groupId: effectiveGroupId,
                                type: selectedType,
                                surahId: selectedSurahId,
                                surahName: surahNameAr,
                                fromAyah: fromAyah,
                                toAyah: toAyah,
                                grade: selectedGrade,
                                teacherNotes: notesCtrl.text.trim(),
                              );

                          if (!mounted) return;
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _tr(
                                  langCode,
                                  ar: 'تم حفظ التقييم وتحديث تقدم الطالب ($studentName) بنجاح!',
                                  he: 'ההערכה נשמרה והתקדמות התלמיד עודכנה!',
                                  en: 'Assignment saved & student Quran progress updated!',
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: Text(
                          _tr(
                            langCode,
                            ar: 'حفظ الواجب والتقييم',
                            he: 'שמור מטלה והערכה',
                            en: 'Save Assignment & Evaluation',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final langCode = currentLocale.languageCode;
    final isRtl = isRtlLocale(currentLocale);

    final selectedGroupId = ref.watch(selectedGroupIdProvider);
    final effectiveGroupId = widget.groupId.isNotEmpty
        ? widget.groupId
        : (selectedGroupId.isNotEmpty ? selectedGroupId : 'grp-hifz-1');

    final teacherGroups =
        ref.watch(teacherGroupsProvider).asData?.value ?? const [];
    final matchedGroup = teacherGroups
        .where((g) => g.id == effectiveGroupId)
        .firstOrNull;

    final groupTitle = matchedGroup?.name.isNotEmpty == true
        ? matchedGroup!.name
        : _tr(
            langCode,
            ar: 'حلقة أبي بكر الصديق',
            he: 'קבוצת אבו בכר אל-סידיק',
            en: 'Abu Bakr As-Siddiq Circle',
          );

    final groupTrackSubtitle = matchedGroup != null
        ? matchedGroup.track.localizedName(langCode)
        : _tr(
            langCode,
            ar: 'المستوى الثالث • المسار المتقدم',
            he: 'רמה 3 • מסלול מתקדם',
            en: 'Level 3 • Advanced Track',
          );

    final firestoreAssignments = ref
            .watch(groupAssignmentsProvider(effectiveGroupId))
            .asData
            ?.value ??
        const [];

    final cards = _buildAssignmentCards(firestoreAssignments, langCode);

    // Counts for filter pills
    final totalCount = firestoreAssignments.isNotEmpty
        ? firestoreAssignments.length + _seedCards.length
        : 8;
    final newHifzCount = firestoreAssignments.isNotEmpty
        ? firestoreAssignments
                .where((a) => a.type == AssignmentType.newHifz)
                .length +
            2
        : 5;
    final revisionCount = firestoreAssignments.isNotEmpty
        ? firestoreAssignments
                .where((a) => a.type == AssignmentType.revision)
                .length +
            1
        : 3;
    final pendingCount = firestoreAssignments.isNotEmpty
        ? firestoreAssignments
                .where((a) => a.grade == EvaluationGrade.pending)
                .length +
            1
        : 2;

    final topPadding = MediaQuery.paddingOf(context).top + 64 + 8;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 96;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _surface,
        body: Stack(
          children: [
            // Main Scrollable Body
            Positioned.fill(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    padding: EdgeInsets.only(
                      top: topPadding,
                      bottom: bottomPadding,
                      left: 16,
                      right: 16,
                    ),
                    children: [
                      // 1. Group Summary & Navigation Header Block
                      _buildGroupSummaryHeader(
                        context: context,
                        langCode: langCode,
                        groupTitle: groupTitle,
                        groupTrackSubtitle: groupTrackSubtitle,
                        effectiveGroupId: effectiveGroupId,
                      ),
                      const SizedBox(height: 16),

                      // Optional expandable search input when filter button tapped
                      if (_showSearchField) ...[
                        TextField(
                          controller: _searchController,
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: _tr(
                              langCode,
                              ar: 'ابحث باسم الطالب أو السورة...',
                              he: 'חפש לפי שם תלמיד או סורה...',
                              en: 'Search by student or Surah...',
                            ),
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                    icon: const Icon(Icons.clear_rounded),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 2. Filter & Ordering Controls
                      _buildFilterAndOrderingControls(
                        context: context,
                        langCode: langCode,
                        totalCount: totalCount,
                        newHifzCount: newHifzCount,
                        revisionCount: revisionCount,
                        pendingCount: pendingCount,
                      ),
                      const SizedBox(height: 16),

                      // 3. Student Assignment Cards Stack
                      ...cards.map(
                        (card) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildStudentAssignmentCard(
                            context: context,
                            langCode: langCode,
                            card: card,
                            effectiveGroupId: effectiveGroupId,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed Translucent Top Bar
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (context.canPop()) {
                                          context.pop();
                                        } else {
                                          context.go(AppRoutes.teacher);
                                        }
                                      },
                                      tooltip: _tr(
                                        langCode,
                                        ar: 'العودة للخلف',
                                        he: 'חזור',
                                        en: 'Back',
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                        color: _onSurface,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _tr(
                                        langCode,
                                        ar: 'Group Assignments View',
                                        he: 'מטלות הקבוצה',
                                        en: 'Group Assignments View',
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: _onSurface,
                                            fontWeight: FontWeight.w600,
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
            ),

            // Bottom Floating / Sticky Primary Action
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.paddingOf(context).bottom + 16,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAssignmentEvaluationModal(
                        context: context,
                        langCode: langCode,
                        effectiveGroupId: effectiveGroupId,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shadowColor: _primary.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_rounded, size: 24),
                      label: Text(
                        _tr(
                          langCode,
                          ar: 'إضافة واجب جديد للحلقة',
                          he: 'הוסף מטלה חדשה לקבוצה',
                          en: 'Add New Group Assignment',
                        ),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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

  Widget _buildGroupSummaryHeader({
    required BuildContext context,
    required String langCode,
    required String groupTitle,
    required String groupTrackSubtitle,
    required String effectiveGroupId,
  }) {
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: _primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: _primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                groupTrackSubtitle,
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          groupTitle,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _onSurface,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: _surfaceContainer,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () =>
                    setState(() => _showSearchField = !_showSearchField),
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.filter_list_rounded,
                    color: _onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Main Module Segmented Tabs (Attendance vs Assignments)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Tab 1: Attendance & Absence (Navigates to AttendanceLoggingView)
              Expanded(
                child: InkWell(
                  onTap: () => _openAttendanceView(effectiveGroupId),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.how_to_reg_rounded,
                          size: 18,
                          color: _onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _tr(
                            langCode,
                            ar: 'الحضور والغياب',
                            he: 'נוכחות והיעדרות',
                            en: 'Attendance',
                          ),
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: _onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Tab 2: Assignments (Active)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        size: 18,
                        color: _primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _tr(
                          langCode,
                          ar: 'الواجبات',
                          he: 'מטלות',
                          en: 'Assignments',
                        ),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: _primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: _secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterAndOrderingControls({
    required BuildContext context,
    required String langCode,
    required int totalCount,
    required int newHifzCount,
    required int revisionCount,
    required int pendingCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Split Toggle: By Student / By Date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tr(
                langCode,
                ar: 'عرض الواجبات',
                he: 'תצוגת מטלות',
                en: 'View Assignments',
              ),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: _onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: _surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => setState(() => _orderByDate = false),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: !_orderByDate
                            ? _surfaceContainerLowest
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _tr(
                          langCode,
                          ar: 'حسب الطالب',
                          he: 'לפי תלמיד',
                          en: 'By Student',
                        ),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: !_orderByDate
                                      ? _primary
                                      : _onSurfaceVariant,
                                  fontWeight: !_orderByDate
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _orderByDate = true),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _orderByDate
                            ? _surfaceContainerLowest
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _tr(
                          langCode,
                          ar: 'حسب التاريخ',
                          he: 'לפי תאריך',
                          en: 'By Date',
                        ),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: _orderByDate
                                      ? _primary
                                      : _onSurfaceVariant,
                                  fontWeight: _orderByDate
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Horizontal Pill Filter Carousel
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // 1. All (الكل)
              _FilterPillButton(
                label: _tr(langCode, ar: 'الكل', he: 'הכל', en: 'All'),
                countLabel: '$totalCount',
                isSelected: _activeFilter == _AssignmentFilterTab.all,
                onTap: () =>
                    setState(() => _activeFilter = _AssignmentFilterTab.all),
              ),
              const SizedBox(width: 8),

              // 2. New Hifz (حفظ جديد)
              _FilterPillButton(
                label: _tr(
                  langCode,
                  ar: 'حفظ جديد',
                  he: 'שינון חדש',
                  en: 'New Hifz',
                ),
                countLabel: '$newHifzCount',
                dotColor: _primary,
                isSelected: _activeFilter == _AssignmentFilterTab.newHifz,
                onTap: () => setState(
                  () => _activeFilter = _AssignmentFilterTab.newHifz,
                ),
              ),
              const SizedBox(width: 8),

              // 3. Revision (مراجعة)
              _FilterPillButton(
                label: _tr(
                  langCode,
                  ar: 'مراجعة',
                  he: 'חזרה',
                  en: 'Revision',
                ),
                countLabel: '$revisionCount',
                dotColor: _secondary,
                isSelected: _activeFilter == _AssignmentFilterTab.revision,
                onTap: () => setState(
                  () => _activeFilter = _AssignmentFilterTab.revision,
                ),
              ),
              const SizedBox(width: 8),

              // 4. Pending Evaluation (بانتظار التقييم)
              _FilterPillButton(
                label: _tr(
                  langCode,
                  ar: 'بانتظار التقييم',
                  he: 'ממתין להערכה',
                  en: 'Pending',
                ),
                countLabel: '$pendingCount',
                dotColor: _secondaryContainer,
                isWarningAccent: true,
                isSelected: _activeFilter == _AssignmentFilterTab.pending,
                onTap: () => setState(
                  () => _activeFilter = _AssignmentFilterTab.pending,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentAssignmentCard({
    required BuildContext context,
    required String langCode,
    required _AssignmentCardItem card,
    required String effectiveGroupId,
  }) {
    final isPending = card.grade == EvaluationGrade.pending;
    final isRevision = card.assignmentType == AssignmentType.revision;

    final sideBarColor = isPending
        ? _secondaryContainer
        : (isRevision ? _secondary : _primary);

    final badgeSubIcon = isPending
        ? Icons.hourglass_top_rounded
        : (isRevision ? Icons.replay_rounded : Icons.verified_rounded);

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
          // Start vertical accent bar (Right in RTL)
          PositionedDirectional(
            top: 0,
            bottom: 0,
            start: 0,
            width: 6,
            child: Container(color: sideBarColor),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header: Avatar, Name, Status & Grade
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Student Avatar + Mini Status Badge
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: sideBarColor.withValues(alpha: 0.14),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  card.initial,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: sideBarColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: sideBarColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    badgeSubIcon,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.studentName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: _onSurface,
                                        fontWeight: FontWeight.w600,
                                        height: 1.25,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      card.isPendingTimeAlert
                                          ? Icons.alarm_rounded
                                          : Icons.schedule_rounded,
                                      size: 13,
                                      color: card.isPendingTimeAlert
                                          ? _secondary
                                          : _primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        card.timeSubtitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: card.isPendingTimeAlert
                                                  ? _secondary
                                                  : _onSurfaceVariant,
                                              fontSize: 11,
                                              fontWeight: card.isPendingTimeAlert
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                            ),
                                        overflow: TextOverflow.ellipsis,
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
                    const SizedBox(width: 8),

                    // Status & Grade Pills
                    if (isPending)
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
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: _secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              card.gradeBadgeLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: _onSecondaryFixedVariant,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 13,
                                  color: _primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _tr(
                                    langCode,
                                    ar: 'تم التقييم',
                                    he: 'הוערך',
                                    en: 'Evaluated',
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: _primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: card.grade == EvaluationGrade.excellent
                                  ? _secondaryFixed
                                  : _secondaryContainer.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              card.gradeBadgeLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color:
                                        card.grade == EvaluationGrade.excellent
                                            ? _onSecondaryFixed
                                            : _onSecondaryContainer,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. Task Details Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
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
                                Icon(
                                  isRevision
                                      ? Icons.sync_rounded
                                      : Icons.menu_book_rounded,
                                  size: 16,
                                  color: isRevision ? _secondary : _primary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    card.rangeTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: isRevision
                                              ? _secondary
                                              : _primary,
                                          fontWeight: FontWeight.bold,
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
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              card.assignmentBadgeLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: _onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: card.progressFactor,
                          minHeight: 6,
                          backgroundColor: _surfaceContainerHigh,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(sideBarColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Teacher Feedback or Pending Note Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isPending
                        ? _surfaceContainerLow
                        : _surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isPending
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isPending
                            ? Icons.pending_outlined
                            : (isRevision
                                ? Icons.error_rounded
                                : Icons.format_quote_rounded),
                        size: 18,
                        color: _secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          card.feedbackText,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _onSurfaceVariant,
                                    height: 1.45,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 4. Footer Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPending
                              ? Icons.notifications_active_outlined
                              : Icons.mic_none_rounded,
                          size: 16,
                          color: _onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          card.audioDurationLabel,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                        ),
                      ],
                    ),
                    if (isPending)
                      ElevatedButton.icon(
                        onPressed: () => _showAssignmentEvaluationModal(
                          context: context,
                          langCode: langCode,
                          effectiveGroupId: effectiveGroupId,
                          existingCard: card,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.rate_review_rounded, size: 18),
                        label: Text(
                          _tr(
                            langCode,
                            ar: 'تقييم الآن',
                            he: 'הערך עכשיו',
                            en: 'Evaluate Now',
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Material(
                        color: _surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () => _showAssignmentEvaluationModal(
                            context: context,
                            langCode: langCode,
                            effectiveGroupId: effectiveGroupId,
                            existingCard: card,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.edit_note_rounded,
                                  size: 16,
                                  color: _primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _tr(
                                    langCode,
                                    ar: 'تعديل التقييم',
                                    he: 'ערוך הערכה',
                                    en: 'Edit Evaluation',
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: _onSurface,
                                        fontWeight: FontWeight.w500,
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
          ),
        ],
      ),
    );
  }
}

class _FilterPillButton extends StatelessWidget {
  final String label;
  final String countLabel;
  final Color? dotColor;
  final bool isWarningAccent;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPillButton({
    required this.label,
    required this.countLabel,
    this.dotColor,
    this.isWarningAccent = false,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00685F);
    const secondary = Color(0xFF904D00);
    const secondaryFixed = Color(0xFFFFDCC3);
    const onSecondaryFixed = Color(0xFF2F1500);
    const onSurfaceVariant = Color(0xFF3D4947);

    final bgColor = isSelected ? primary : Colors.white;
    final fgColor = isSelected
        ? Colors.white
        : (isWarningAccent ? secondary : onSurfaceVariant);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(999),
      elevation: 0.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null && !isSelected) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: fgColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.20)
                      : (isWarningAccent
                          ? secondaryFixed
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  countLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected || isWarningAccent
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isWarningAccent
                            ? onSecondaryFixed
                            : onSurfaceVariant.withValues(alpha: 0.75)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
