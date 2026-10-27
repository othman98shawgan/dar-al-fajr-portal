import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/surah_page_map.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/services/locale_provider.dart';
import '../../admin/models/admin_models.dart';
import '../models/teacher_models.dart';
import '../providers/teacher_providers.dart';
import '../repositories/teacher_repository.dart';
import 'student_hifz_modal.dart';

enum _GroupModuleTab {
  assignments,
  weeklyRevision,
  monthlyAttendance,
}

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
  final int? targetPage;
  final int? juzNumber;
  final String rangeTitle;
  final EvaluationGrade grade;
  final int? score;
  final bool isPartialRead;
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
    this.targetPage,
    this.juzNumber,
    required this.rangeTitle,
    required this.grade,
    this.score,
    this.isPartialRead = false,
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
  _GroupModuleTab _activeModuleTab = _GroupModuleTab.assignments;
  bool _orderByDate = false;
  _AssignmentFilterTab _activeFilter = _AssignmentFilterTab.all;
  bool _showSearchField = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Weekly Revision Tab State
  String _selectedRevisionStudentId = 'st-1042';
  List<DailyRevisionTask> _draftRevisionTasks = [];
  bool _revisionTasksInitialized = false;
  bool _isSavingRevisionPlan = false;

  // Monthly Attendance Tab State
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // Design tokens
  static const Color _surface = Color(0xFFF7F9FB);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color _surfaceContainer = Color(0xFFECEEF0);
  static const Color _surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color _onSurface = Color(0xFF191C1E);
  static const Color _onSurfaceVariant = Color(0xFF3D4947);
  static const Color _primary = Color(0xFF00685F);
  static const Color _primaryFixed = Color(0xFF89F5E7);
  static const Color _onPrimaryFixed = Color(0xFF00201D);
  static const Color _secondary = Color(0xFF904D00);
  static const Color _secondaryContainer = Color(0xFFFE932C);
  static const Color _secondaryFixed = Color(0xFFFFDCC3);
  static const Color _onSecondaryFixed = Color(0xFF2F1500);
  static const Color _onSecondaryFixedVariant = Color(0xFF6E3900);
  static const Color _tertiary = Color(0xFF1E6661);

  static const List<_AssignmentCardItem> _seedCards = [
    _AssignmentCardItem(
      id: 'seed-assign-1',
      studentId: 'st-1042',
      studentName: 'إبراهيم طه عثمان',
      initial: 'إ',
      timeSubtitle: 'تم التسميع اليوم • ٤:١٥ م',
      assignmentType: AssignmentType.newHifz,
      assignmentBadgeLabel: 'صفحة كاملة (ص ٢٨٢)',
      surahId: 17,
      surahName: 'الإسراء',
      fromAyah: 1,
      toAyah: 15,
      targetPage: 282,
      juzNumber: 15,
      rangeTitle: 'سورة الإسراء • صفحة ٢٨٢',
      grade: EvaluationGrade.excellent,
      score: 97,
      gradeBadgeLabel: '٩٧ / ١٠٠ • ممتاز',
      progressFactor: 0.97,
      feedbackText:
          'ما شاء الله، إتقان متين لأحكام النون الساكنة والمد المتصل، خطأ لفظي واحد فقط.',
      audioDurationLabel: 'تم الرصد اليوم',
    ),
    _AssignmentCardItem(
      id: 'seed-assign-2',
      studentId: 'st-1088',
      studentName: 'عبد الرحمن يوسف الشريف',
      initial: 'ع',
      timeSubtitle: 'تم التسميع اليوم • ٤:٤٠ م',
      assignmentType: AssignmentType.revision,
      assignmentBadgeLabel: 'اختبار جزء كامل',
      surahId: 78,
      surahName: 'النبأ',
      fromAyah: 1,
      toAyah: 40,
      juzNumber: 30,
      rangeTitle: 'مراجعة واختبار الجزء ٣٠ كاملاً',
      grade: EvaluationGrade.good,
      score: 88,
      gradeBadgeLabel: '٨٨ / ١٠٠ • مجتاز الجزء',
      progressFactor: 0.88,
      feedbackText:
          'تنبيه لموضع القلقلة في سورة البروج والانتباه لترقيق الراء. اجتاز اختبار الجزء بنجاح (الحد الأدنى ٧٩).',
      audioDurationLabel: 'اجتاز اختبار الجزء',
    ),
    _AssignmentCardItem(
      id: 'seed-assign-3',
      studentId: 'st-1102',
      studentName: 'زياد المنصور',
      initial: 'ز',
      timeSubtitle: 'في الانتظار • موعده ٥:٣٠ م',
      isPendingTimeAlert: true,
      assignmentType: AssignmentType.newHifz,
      assignmentBadgeLabel: 'حفظ جديد (صفحة ٢٦٧)',
      surahId: 16,
      surahName: 'النحل',
      fromAyah: 1,
      toAyah: 35,
      targetPage: 267,
      juzNumber: 14,
      rangeTitle: 'سورة النحل • صفحة ٢٦٧ (آية ١ - ٣٥)',
      grade: EvaluationGrade.pending,
      gradeBadgeLabel: 'في الانتظار',
      progressFactor: 0.20,
      feedbackText:
          'لم يتم التسميع بعد - مقرر اليوم جاهز للاستماع والرصد المباشر.',
      audioDurationLabel: 'بانتظار التسميع',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initDefaultDraftRevisionTasks();
  }

  void _initDefaultDraftRevisionTasks() {
    _draftRevisionTasks = List<DailyRevisionTask>.generate(7, (dayIndex) {
      // Friday (5) and Saturday (6) default to rest days as an example
      if (dayIndex == 5 || dayIndex == 6) {
        return DailyRevisionTask(dayIndex: dayIndex, isRestDay: true);
      }
      return DailyRevisionTask(
        dayIndex: dayIndex,
        isRestDay: false,
        targetType: RevisionTargetType.juz,
        juzNumber: (30 - dayIndex).clamp(1, 30),
        status: dayIndex < 2
            ? RevisionTaskStatus.doneOnTime
            : RevisionTaskStatus.pending,
      );
    });
  }

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

  List<_AssignmentCardItem> _buildAssignmentCards(
    List<HifzAssignment> firestoreAssignments,
    String langCode,
  ) {
    final mappedFirestore = firestoreAssignments.map((item) {
      final trimmed = item.studentName.trim();
      final initial = trimmed.isNotEmpty ? trimmed.characters.first : 'ط';
      final isPending = item.grade == EvaluationGrade.pending && !item.isPartialRead;
      final isExcellent = item.grade == EvaluationGrade.excellent;
      final isGood = item.grade == EvaluationGrade.good;

      String gradeBadge;
      if (item.isPartialRead) {
        gradeBadge = _tr(
          langCode,
          ar: 'قراءة جزئية (ملاحظة فقط)',
          he: 'קריאה חלקית (הערה)',
          en: 'Partial Read (Note Only)',
        );
      } else if (item.score != null && !isPending) {
        final sText = _formatNum(item.score!, langCode);
        final gText = item.grade.localizedName(langCode);
        gradeBadge = '$sText / ${_formatNum(100, langCode)} • $gText';
      } else {
        gradeBadge = switch (item.grade) {
          EvaluationGrade.excellent => _tr(
              langCode,
              ar: 'ممتاز (٩٨ / ١٠٠)',
              he: 'מצוין (98/100)',
              en: 'Excellent (98/100)',
            ),
          EvaluationGrade.good => _tr(
              langCode,
              ar: 'جيد جداً (٨٥ / ١٠٠)',
              he: 'טוב מאוד (85/100)',
              en: 'Very Good (85/100)',
            ),
          EvaluationGrade.needsRepeat => _tr(
              langCode,
              ar: 'يحتاج إعادة',
              he: 'דורש חזרה',
              en: 'Needs Repeat',
            ),
          EvaluationGrade.pending => _tr(
              langCode,
              ar: 'في الانتظار',
              he: 'ממתין',
              en: 'Pending',
            ),
        };
      }

      final pageLabel = item.targetPage != null
          ? ' • ص ${_formatNum(item.targetPage!, langCode)}'
          : '';
      final rangeTitle = item.isJuzExam && item.juzNumber != null
          ? 'اختبار ومراجعة الجزء ${_formatNum(item.juzNumber!, langCode)} كاملاً'
          : 'سورة ${item.surahName}$pageLabel (الآية ${item.fromAyah} إلى ${item.toAyah})';

      return _AssignmentCardItem(
        id: item.id,
        studentId: item.studentId,
        studentName:
            item.studentName.isNotEmpty ? item.studentName : 'طالب الحلقة',
        initial: initial,
        timeSubtitle: isPending
            ? _tr(
                langCode,
                ar: 'في الانتظار • جاهز للتسميع',
                he: 'ממתין לשינון',
                en: 'Pending Recitation',
              )
            : _tr(
                langCode,
                ar: 'تم التسميع اليوم ✓',
                he: 'נבחן היום ✓',
                en: 'Evaluated Today ✓',
              ),
        isPendingTimeAlert: isPending,
        assignmentType: item.type,
        assignmentBadgeLabel: item.type.localizedName(langCode),
        surahId: item.surahId,
        surahName: item.surahName,
        fromAyah: item.fromAyah,
        toAyah: item.toAyah,
        targetPage: item.targetPage,
        juzNumber: item.juzNumber,
        rangeTitle: rangeTitle,
        grade: item.grade,
        score: item.score,
        isPartialRead: item.isPartialRead,
        gradeBadgeLabel: gradeBadge,
        progressFactor: item.score != null
            ? (item.score! / 100.0).clamp(0.1, 1.0)
            : (isExcellent
                ? 1.0
                : (isGood ? 0.85 : (isPending ? 0.20 : 0.45))),
        feedbackText: item.teacherNotes.isNotEmpty
            ? item.teacherNotes
            : (isPending
                ? 'لم يتم التسميع بعد - جاهز للاستماع والرصد المباشر.'
                : 'تم تسميع المقرر بنجاح وتحديث سجل الإنجاز القرآني.'),
        audioDurationLabel: item.recitationUnits.length > 1
            ? 'تم تسميع ${item.recitationUnits.length} مقاطع بالجلسة'
            : (isPending ? 'بانتظار التسميع' : 'تم الرصد'),
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
    bool assignOnlyMode = false,
  }) {
    final teacherGroups =
        ref.read(teacherGroupsProvider).asData?.value ?? const [];
    final matchedGroup = teacherGroups
        .where((g) => g.id == effectiveGroupId)
        .firstOrNull;
    final groupTitle = matchedGroup?.name.isNotEmpty == true
        ? matchedGroup!.name
        : 'حلقة أبي بكر الصديق';

    return StudentHifzModal.show(
      context,
      existingAssignmentId:
          existingCard?.isFromFirestore == true ? existingCard!.id : null,
      groupId: effectiveGroupId,
      groupTitle: groupTitle,
      studentId: existingCard?.studentId ?? 'st-1042',
      studentName: existingCard?.studentName ?? 'إبراهيم طه عثمان',
      currentType: existingCard?.assignmentType ?? AssignmentType.newHifz,
      currentSurahId: existingCard?.surahId ?? 16,
      currentSurahName: existingCard?.surahName ?? 'النحل',
      currentFromAyah: existingCard?.fromAyah ?? 1,
      currentToAyah: existingCard?.toAyah ?? 128,
      currentTargetPage: existingCard?.targetPage,
      currentJuzNumber: existingCard?.juzNumber,
      initialGrade: existingCard?.grade ?? EvaluationGrade.excellent,
      initialNotes: existingCard != null &&
              existingCard.grade != EvaluationGrade.pending
          ? existingCard.feedbackText
          : '',
      assignOnlyMode: assignOnlyMode,
    );
  }

  void _showStudentStatsBottomSheet({
    required BuildContext context,
    required String langCode,
    required String studentId,
    required String studentName,
    required List<AttendanceLog> groupAttendanceLogs,
  }) {
    final studentsMap =
        ref.read(allStudentsMapProvider).asData?.value ?? const {};
    final profile = studentsMap[studentId] ??
        StudentProfile(
          id: studentId,
          fullName: studentName,
          parentId: 'parent-1',
          memorizedPages: const [1, 2, 3, 4, 5, 582, 583, 584, 585, 586, 587],
          completedSurahs: List.generate(37, (i) => 78 + i),
          completedJuz: const [30, 29],
          juzStatuses: const {
            30: 'passed_exam',
            29: 'ready_for_exam',
            28: 'in_progress',
          },
        );

    final studentLogs = groupAttendanceLogs
        .where((l) => l.studentId == studentId)
        .toList();
    final totalSessions = studentLogs.isNotEmpty ? studentLogs.length : 12;
    final attendedSessions = studentLogs.isNotEmpty
        ? studentLogs
            .where((l) =>
                l.status == AttendanceStatus.present ||
                l.status == AttendanceStatus.late)
            .length
        : 11;
    final attendancePercent =
        totalSessions > 0 ? ((attendedSessions / totalSessions) * 100).round() : 92;

    final centerPagesCount = profile.memorizedCenterPagesCount;
    final totalCenterPages = CenterQuranMap.totalCenterPages; // 657

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          maxChildSize: 0.92,
          minChildSize: 0.5,
          builder: (_, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _primaryFixed,
                      child: Text(
                        studentName.characters.first,
                        style: const TextStyle(
                          color: _onPrimaryFixed,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            _tr(
                              langCode,
                              ar: 'سجل الإحصائيات المتكامل (الحفظ، اختبارات الأجزاء، والحضور)',
                              he: 'סטטיסטיקת תלמיד (שינון, מבחני ג׳וז ונוכחות)',
                              en: 'Student Hifz, Juz Exams & Attendance Stats',
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
                const SizedBox(height: 16),

                // Top 3 KPI Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatKpiBox(
                        label: _tr(
                          langCode,
                          ar: 'صفحات المركز',
                          he: 'עמודי מרכז',
                          en: 'Center Pages',
                        ),
                        value:
                            '${_formatNum(centerPagesCount, langCode)} / ${_formatNum(totalCenterPages, langCode)}',
                        color: _primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatKpiBox(
                        label: _tr(
                          langCode,
                          ar: 'السور المنجزة',
                          he: 'סורות שהושלמו',
                          en: 'Surahs Done',
                        ),
                        value:
                            '${_formatNum(profile.completedSurahs.length, langCode)} / ${_formatNum(114, langCode)}',
                        color: _tertiary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatKpiBox(
                        label: _tr(
                          langCode,
                          ar: 'نسبة الحضور',
                          he: 'אחוז נוכחות',
                          en: 'Attendance',
                        ),
                        value: '${_formatNum(attendancePercent, langCode)}%',
                        color: _secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  _tr(
                    langCode,
                    ar: 'حالة الأجزاء واختبارات الأجزاء (علامة النجاح: ٧٩ فأعلى)',
                    he: 'סטטוס ג׳וזים ומבחני ג׳וז (ציון מעבר: 79)',
                    en: 'Juz Progression & Whole-Juz Exam Status (Pass >= 79)',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(30, (idx) {
                    final juz = 30 - idx;
                    final rawStatus = profile.juzStatuses[juz] ??
                        (profile.completedJuz.contains(juz)
                            ? 'passed_exam'
                            : null);
                    final status = rawStatus != null
                        ? JuzProgressStatus.fromString(rawStatus)
                        : null;

                    final bgColor = switch (status) {
                      JuzProgressStatus.passedExam => _primaryFixed,
                      JuzProgressStatus.readyForExam => _secondaryFixed,
                      JuzProgressStatus.inProgress =>
                        _primary.withValues(alpha: 0.08),
                      null => _surfaceContainerLow,
                    };
                    final textColor = switch (status) {
                      JuzProgressStatus.passedExam => _onPrimaryFixed,
                      JuzProgressStatus.readyForExam => _onSecondaryFixed,
                      JuzProgressStatus.inProgress => _primary,
                      null => _onSurfaceVariant,
                    };

                    return Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _tr(
                              langCode,
                              ar: 'الجزء ${_formatNum(juz, langCode)}',
                              he: 'ג׳וז $juz',
                              en: 'Juz $juz',
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            status != null
                                ? status.localizedName(langCode)
                                : _tr(
                                    langCode,
                                    ar: 'لم يبدأ',
                                    he: 'טרם התחיל',
                                    en: 'Not Started',
                                  ),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
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

    // Check if group is a Hifz group (defaults to true for seed Hifz groups)
    final isHifzGroup = matchedGroup == null
        ? !effectiveGroupId.contains('qaidah') &&
            !effectiveGroupId.contains('tajweed') &&
            !effectiveGroupId.contains('tarbawi')
        : matchedGroup.track == CenterTrack.hifz;

    final effectiveTab =
        !isHifzGroup ? _GroupModuleTab.monthlyAttendance : _activeModuleTab;

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
            ar: 'مسار الحفظ والتسميع • المستوى المتقدم',
            he: 'מסלול חיפז ושינון • רמה מתקדמת',
            en: 'Hifz & Memorization Track',
          );

    final firestoreAssignments = ref
            .watch(groupAssignmentsProvider(effectiveGroupId))
            .asData
            ?.value ??
        const [];
    final groupAttendanceLogs = ref
            .watch(groupAttendanceProvider(effectiveGroupId))
            .asData
            ?.value ??
        const [];

    final cards = _buildAssignmentCards(firestoreAssignments, langCode);

    final totalCount = firestoreAssignments.length + _seedCards.length;
    final newHifzCount = firestoreAssignments
            .where((a) => a.type == AssignmentType.newHifz)
            .length +
        2;
    final revisionCount = firestoreAssignments
            .where((a) => a.type == AssignmentType.revision)
            .length +
        1;
    final pendingCount = firestoreAssignments
            .where((a) => a.grade == EvaluationGrade.pending)
            .length +
        1;

    final topPadding = MediaQuery.paddingOf(context).top + 64 + 8;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 96;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _surface,
        body: Stack(
          children: [
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
                      // 1. Group Summary & Track-Aware Module Switcher
                      _buildGroupSummaryHeader(
                        context: context,
                        langCode: langCode,
                        groupTitle: groupTitle,
                        groupTrackSubtitle: groupTrackSubtitle,
                        effectiveGroupId: effectiveGroupId,
                        isHifzGroup: isHifzGroup,
                        effectiveTab: effectiveTab,
                      ),
                      const SizedBox(height: 16),

                      if (effectiveTab == _GroupModuleTab.assignments) ...[
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
                        _buildFilterAndOrderingControls(
                          context: context,
                          langCode: langCode,
                          totalCount: totalCount,
                          newHifzCount: newHifzCount,
                          revisionCount: revisionCount,
                          pendingCount: pendingCount,
                        ),
                        const SizedBox(height: 16),
                        ...cards.map(
                          (card) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildStudentAssignmentCard(
                              context: context,
                              langCode: langCode,
                              card: card,
                              effectiveGroupId: effectiveGroupId,
                              groupAttendanceLogs: groupAttendanceLogs,
                            ),
                          ),
                        ),
                      ] else if (effectiveTab ==
                          _GroupModuleTab.weeklyRevision) ...[
                        _buildWeeklyRevisionPlanSection(
                          context: context,
                          langCode: langCode,
                          effectiveGroupId: effectiveGroupId,
                          cards: cards,
                        ),
                      ] else ...[
                        _buildMonthlyAttendanceSection(
                          context: context,
                          langCode: langCode,
                          effectiveGroupId: effectiveGroupId,
                          groupAttendanceLogs: groupAttendanceLogs,
                          cards: cards,
                        ),
                      ],
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
                                      groupTitle,
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
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _openAttendanceView(effectiveGroupId),
                                  icon: const Icon(
                                    Icons.how_to_reg_rounded,
                                    size: 16,
                                  ),
                                  label: Text(
                                    _tr(
                                      langCode,
                                      ar: 'تحضير اليوم',
                                      he: 'נוכחות היום',
                                      en: 'Log Today',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
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

            // Bottom Floating Action (Only on Assignments tab for Hifz groups)
            if (effectiveTab == _GroupModuleTab.assignments)
              Positioned(
                left: 16,
                right: 16,
                bottom: MediaQuery.paddingOf(context).bottom + 16,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 390),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAssignmentEvaluationModal(
                          context: context,
                          langCode: langCode,
                          effectiveGroupId: effectiveGroupId,
                          assignOnlyMode: true,
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
                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 22),
                        label: Text(
                          _tr(
                            langCode,
                            ar: 'تحديد واجب فردي لطالب',
                            he: 'קבע מטלה אישית לתלמיד',
                            en: 'Assign Individual Student Homework',
                          ),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
    required bool isHifzGroup,
    required _GroupModuleTab effectiveTab,
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
                        Text(
                          groupTrackSubtitle,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _onSurfaceVariant,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          groupTitle,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isHifzGroup && effectiveTab == _GroupModuleTab.assignments)
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
                      Icons.search_rounded,
                      color: _onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Track-Aware Module Segmented Tabs
        if (isHifzGroup)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildModuleTabButton(
                  label: _tr(
                    langCode,
                    ar: 'الواجبات والتسميع',
                    he: 'מטלות ושינון',
                    en: 'Assignments',
                  ),
                  icon: Icons.menu_book_rounded,
                  isSelected: effectiveTab == _GroupModuleTab.assignments,
                  onTap: () => setState(
                    () => _activeModuleTab = _GroupModuleTab.assignments,
                  ),
                ),
                _buildModuleTabButton(
                  label: _tr(
                    langCode,
                    ar: 'خطة المراجعة',
                    he: 'תוכנית חזרה',
                    en: 'Revision Plan',
                  ),
                  icon: Icons.calendar_view_week_rounded,
                  isSelected: effectiveTab == _GroupModuleTab.weeklyRevision,
                  onTap: () => setState(
                    () => _activeModuleTab = _GroupModuleTab.weeklyRevision,
                  ),
                ),
                _buildModuleTabButton(
                  label: _tr(
                    langCode,
                    ar: 'الحضور الشهري',
                    he: 'נוכחות חודשית',
                    en: 'Monthly Attendance',
                  ),
                  icon: Icons.fact_check_rounded,
                  isSelected: effectiveTab == _GroupModuleTab.monthlyAttendance,
                  onTap: () => setState(
                    () => _activeModuleTab = _GroupModuleTab.monthlyAttendance,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildModuleTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? _surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? _primary : _onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? _primary : _onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 2: Weekly Revision Plan & LRU Priority Queue
  // ===========================================================================
  Widget _buildWeeklyRevisionPlanSection({
    required BuildContext context,
    required String langCode,
    required String effectiveGroupId,
    required List<_AssignmentCardItem> cards,
  }) {
    final uniqueStudents = <String, String>{
      'st-1042': 'إبراهيم طه عثمان',
      'st-1088': 'عبد الرحمن يوسف الشريف',
      'st-1102': 'زياد المنصور',
    };
    for (final c in cards) {
      uniqueStudents[c.studentId] = c.studentName;
    }
    if (!uniqueStudents.containsKey(_selectedRevisionStudentId)) {
      _selectedRevisionStudentId = uniqueStudents.keys.first;
    }
    final selectedStudentName =
        uniqueStudents[_selectedRevisionStudentId] ?? 'إبراهيم طه عثمان';

    final studentsMap =
        ref.watch(allStudentsMapProvider).asData?.value ?? const {};
    final studentProfile = studentsMap[_selectedRevisionStudentId] ??
        StudentProfile(
          id: _selectedRevisionStudentId,
          fullName: selectedStudentName,
          parentId: 'parent-1',
          completedJuz: const [30, 29, 28, 27],
          juzStatuses: const {
            30: 'passed_exam',
            29: 'passed_exam',
            28: 'ready_for_exam',
            27: 'in_progress',
          },
          lastRevisedJuzDates: {
            30: DateTime.now().subtract(const Duration(days: 3)),
            29: DateTime.now().subtract(const Duration(days: 19)),
            28: DateTime.now().subtract(const Duration(days: 12)),
          },
        );

    final lruQueue =
        TeacherRepository.computeRevisionPriorityQueueForStudent(studentProfile);

    // Watch existing Firestore weekly plan for this student
    final studentPlans = ref
            .watch(studentWeeklyPlansProvider(_selectedRevisionStudentId))
            .asData
            ?.value ??
        const [];
    if (!_revisionTasksInitialized && studentPlans.isNotEmpty) {
      _draftRevisionTasks = List<DailyRevisionTask>.from(
        studentPlans.first.dailyTasks,
      );
      _revisionTasksInitialized = true;
    }

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

    void autoSuggestFromLruQueue() {
      if (lruQueue.isEmpty) return;
      setState(() {
        _draftRevisionTasks = List<DailyRevisionTask>.generate(7, (dayIndex) {
          // Leave Friday (5) and Saturday (6) as rest days by default
          if (dayIndex == 5 || dayIndex == 6) {
            return DailyRevisionTask(dayIndex: dayIndex, isRestDay: true);
          }
          final item = lruQueue[dayIndex % lruQueue.length];
          return DailyRevisionTask(
            dayIndex: dayIndex,
            isRestDay: false,
            targetType: RevisionTargetType.juz,
            juzNumber: item.juzNumber,
            status: RevisionTaskStatus.pending,
          );
        });
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Student Selector Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_rounded, color: _primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _tr(
                      langCode,
                      ar: 'الطالب:',
                      he: 'תלמיד:',
                      en: 'Student:',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: _selectedRevisionStudentId,
                items: uniqueStudents.entries
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(
                          e.value,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedRevisionStudentId = val;
                      _revisionTasksInitialized = false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. LRU Spaced Repetition Priority Queue Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _primary.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                            ar: 'أولوية المراجعة (الأبعد عهداً بالمراجعة)',
                            he: 'עדיפות חזרה (הזמן הארוך ביותר ללא חזרה)',
                            en: 'Revision Priority Queue (Least Recently Revised)',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _primary,
                          ),
                        ),
                        Text(
                          _tr(
                            langCode,
                            ar: 'مرتبة تلقائياً من الأجزاء التي لم يراجعها الطالب منذ أطول فترة',
                            he: 'מדורג אוטומטית מהג׳וזים שלא נחזרו הכי הרבה זמן',
                            en: 'Sorted by longest days since last revision',
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            color: _onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: autoSuggestFromLruQueue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryFixed,
                      foregroundColor: _onPrimaryFixed,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                    icon: const Icon(Icons.auto_awesome_rounded, size: 15),
                    label: Text(
                      _tr(
                        langCode,
                        ar: 'توليد تلقائي',
                        he: 'מילוי אוטומטי',
                        en: 'Auto-Fill',
                      ),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: lruQueue.map((item) {
                    final isUrgent = item.daysSinceLastRevision >= 14;
                    return Container(
                      margin: const EdgeInsetsDirectional.only(end: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isUrgent
                            ? _secondaryFixed.withValues(alpha: 0.7)
                            : _surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _tr(
                                  langCode,
                                  ar: 'الجزء ${_formatNum(item.juzNumber, langCode)}',
                                  he: 'ג׳וז ${item.juzNumber}',
                                  en: 'Juz ${item.juzNumber}',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item.juzStatus.localizedName(langCode),
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: _primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.daysSinceLastRevision >= 900
                                ? _tr(
                                    langCode,
                                    ar: 'لم يُراجع بعد',
                                    he: 'טרם נערך סבב חזרה',
                                    en: 'Never revised yet',
                                  )
                                : _tr(
                                    langCode,
                                    ar: 'منذ ${_formatNum(item.daysSinceLastRevision, langCode)} يوم',
                                    he: 'לפני ${item.daysSinceLastRevision} ימים',
                                    en: '${item.daysSinceLastRevision} days ago',
                                  ),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isUrgent ? _secondary : _onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. 7-Day Revision Plan Builder (Allows Empty Rest Days)
        ...List.generate(_draftRevisionTasks.length, (idx) {
          final task = _draftRevisionTasks[idx];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: task.isRestDay
                  ? _surfaceContainerLow
                  : _surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: task.isRestDay
                    ? _surfaceContainerHigh
                    : _primary.withValues(alpha: 0.2),
              ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: task.isRestDay
                                ? _surfaceContainerHigh
                                : _primaryFixed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            getDayName(task.dayIndex),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: task.isRestDay
                                  ? _onSurfaceVariant
                                  : _onPrimaryFixed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!task.isRestDay)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: task.status ==
                                      RevisionTaskStatus.doneOnTime
                                  ? _primary.withValues(alpha: 0.12)
                                  : (task.status == RevisionTaskStatus.doneLate
                                      ? _secondaryFixed
                                      : _surfaceContainerLow),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              task.status.localizedName(langCode),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: task.status ==
                                        RevisionTaskStatus.doneOnTime
                                    ? _primary
                                    : (task.status ==
                                            RevisionTaskStatus.doneLate
                                        ? _secondary
                                        : _onSurfaceVariant),
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Rest Day Toggle (يمكن للمعلم ترك أيام فارغة)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _tr(
                            langCode,
                            ar: 'يوم فارغ / راحة',
                            he: 'יום מנוחה',
                            en: 'Empty / Rest Day',
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            color: _onSurfaceVariant,
                          ),
                        ),
                        Switch(
                          value: task.isRestDay,
                          activeThumbColor: _secondary,
                          onChanged: (val) {
                            setState(() {
                              _draftRevisionTasks[idx] =
                                  task.copyWith(isRestDay: val);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                if (!task.isRestDay) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      DropdownButton<RevisionTargetType>(
                        value: task.targetType,
                        items: [
                          DropdownMenuItem(
                            value: RevisionTargetType.juz,
                            child: Text(
                              _tr(
                                langCode,
                                ar: 'جزء كامل',
                                he: 'ג׳וז מלא',
                                en: 'Whole Juz',
                              ),
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          ),
                          DropdownMenuItem(
                            value: RevisionTargetType.surah,
                            child: Text(
                              _tr(
                                langCode,
                                ar: 'سورة',
                                he: 'סורה',
                                en: 'Surah',
                              ),
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          ),
                        ],
                        onChanged: (t) {
                          if (t != null) {
                            setState(() {
                              _draftRevisionTasks[idx] = task.copyWith(
                                targetType: t,
                                juzNumber: task.juzNumber ?? 30,
                                surahId: task.surahId ?? 67,
                                surahName: task.surahName ?? 'الملك',
                              );
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      if (task.targetType == RevisionTargetType.juz)
                        DropdownButton<int>(
                          value: (task.juzNumber ?? 30).clamp(1, 30),
                          items: List.generate(30, (i) => 30 - i)
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (j) {
                            if (j != null) {
                              setState(() {
                                _draftRevisionTasks[idx] =
                                    task.copyWith(juzNumber: j);
                              });
                            }
                          },
                        )
                      else
                        Expanded(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: (task.surahId ?? 67).clamp(1, 114),
                            items: CenterQuranMap.surahs
                                .map(
                                  (s) => DropdownMenuItem<int>(
                                    value: s.id,
                                    child: Text(
                                      'سورة ${s.localizedName(langCode)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (sId) {
                              if (sId != null) {
                                final s = CenterQuranMap.getSurahById(sId);
                                setState(() {
                                  _draftRevisionTasks[idx] = task.copyWith(
                                    surahId: s.id,
                                    surahName: s.nameAr,
                                  );
                                });
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),

        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isSavingRevisionPlan
                ? null
                : () async {
                    setState(() => _isSavingRevisionPlan = true);
                    final now = DateTime.now();
                    final weekStart =
                        now.subtract(Duration(days: now.weekday % 7));
                    await ref
                        .read(teacherControllerProvider.notifier)
                        .saveWeeklyRevisionPlan(
                          existingPlanId: studentPlans.firstOrNull?.id,
                          studentId: _selectedRevisionStudentId,
                          studentName: selectedStudentName,
                          groupId: effectiveGroupId,
                          weekStartDate: DateTime(
                            weekStart.year,
                            weekStart.month,
                            weekStart.day,
                          ),
                          dailyTasks: _draftRevisionTasks,
                        );
                    if (!context.mounted) return;
                    setState(() => _isSavingRevisionPlan = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _tr(
                            langCode,
                            ar: 'تم حفظ خطة المراجعة الأسبوعية للطالب ($selectedStudentName) بنجاح!',
                            he: 'תוכנית החזרה השבועית נשמרה בהצלחה!',
                            en: 'Weekly revision plan saved successfully!',
                          ),
                        ),
                        backgroundColor: _tertiary,
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
            icon: const Icon(Icons.save_rounded),
            label: Text(
              _tr(
                langCode,
                ar: 'حفظ خطة المراجعة الأسبوعية',
                he: 'שמור תוכנית חזרה שבועית',
                en: 'Save Weekly Revision Plan',
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 3: Monthly Group Attendance Record (Each Month Alone)
  // ===========================================================================
  Widget _buildMonthlyAttendanceSection({
    required BuildContext context,
    required String langCode,
    required String effectiveGroupId,
    required List<AttendanceLog> groupAttendanceLogs,
    required List<_AssignmentCardItem> cards,
  }) {
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
    const monthsEn = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final monthName = langCode == 'en'
        ? monthsEn[(_selectedMonth.month - 1) % 12]
        : monthsAr[(_selectedMonth.month - 1) % 12];
    final monthLabel =
        '$monthName ${_formatNum(_selectedMonth.year, langCode)}';

    // Filter logs for the selected month alone
    final monthLogs = groupAttendanceLogs
        .where(
          (l) =>
              l.sessionDate.year == _selectedMonth.year &&
              l.sessionDate.month == _selectedMonth.month,
        )
        .toList();

    final roster = <String, String>{
      'st-1042': 'إبراهيم طه عثمان',
      'st-1088': 'عبد الرحمن يوسف الشريف',
      'st-1102': 'زياد المنصور',
      'st-1115': 'حمزة كمال الدين',
    };
    for (final c in cards) {
      roster[c.studentId] = c.studentName;
    }
    for (final l in monthLogs) {
      if (l.studentName.trim().isNotEmpty) {
        roster[l.studentId] = l.studentName;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Month Picker Bar (Each Month Alone)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month - 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: _primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    monthLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Per-Student Monthly Attendance Breakdown
        ...roster.entries.map((entry) {
          final stId = entry.key;
          final stName = entry.value;
          final stLogs =
              monthLogs.where((l) => l.studentId == stId).toList();

          final present = stLogs.isNotEmpty
              ? stLogs
                  .where((l) => l.status == AttendanceStatus.present)
                  .length
              : (stId == 'st-1115' ? 6 : 8);
          final lateCount = stLogs.isNotEmpty
              ? stLogs.where((l) => l.status == AttendanceStatus.late).length
              : (stId == 'st-1102' ? 1 : 0);
          final absent = stLogs.isNotEmpty
              ? stLogs
                  .where((l) =>
                      l.status == AttendanceStatus.absent ||
                      l.status == AttendanceStatus.excused)
                  .length
              : (stId == 'st-1115' ? 2 : 0);
          final total = (present + lateCount + absent).clamp(1, 999);
          final rate = (((present + lateCount) / total) * 100).round();

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _tr(
                          langCode,
                          ar: 'حاضر: ${_formatNum(present, langCode)} • متأخر: ${_formatNum(lateCount, langCode)} • غائب/معذور: ${_formatNum(absent, langCode)}',
                          he: 'נוכח: $present • איחור: $lateCount • חיסור: $absent',
                          en: 'Present: $present • Late: $lateCount • Absent: $absent',
                        ),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: rate >= 85
                        ? _primaryFixed
                        : _secondaryFixed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_formatNum(rate, langCode)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          rate >= 85 ? _onPrimaryFixed : _onSecondaryFixed,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _tr(
                  langCode,
                  ar: 'قائمة الطلاب والواجبات المقررة',
                  he: 'רשימת תלמידים ומטלות',
                  en: 'Students & Assigned Homework',
                ),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: _onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
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
                        horizontal: 10,
                        vertical: 5,
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
                        style: TextStyle(
                          fontSize: 11.5,
                          color:
                              !_orderByDate ? _primary : _onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _orderByDate = true),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
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
                        style: TextStyle(
                          fontSize: 11.5,
                          color: _orderByDate ? _primary : _onSurfaceVariant,
                          fontWeight: FontWeight.bold,
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterPillButton(
                label: _tr(langCode, ar: 'الكل', he: 'הכל', en: 'All'),
                countLabel: '$totalCount',
                isSelected: _activeFilter == _AssignmentFilterTab.all,
                onTap: () =>
                    setState(() => _activeFilter = _AssignmentFilterTab.all),
              ),
              const SizedBox(width: 8),
              _FilterPillButton(
                label: _tr(
                  langCode,
                  ar: 'من تبقى فقط (في الانتظار)',
                  he: 'ממתינים בלבד',
                  en: 'Pending Only',
                ),
                countLabel: '$pendingCount',
                dotColor: _secondaryContainer,
                isWarningAccent: true,
                isSelected: _activeFilter == _AssignmentFilterTab.pending,
                onTap: () => setState(
                  () => _activeFilter = _AssignmentFilterTab.pending,
                ),
              ),
              const SizedBox(width: 8),
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
              _FilterPillButton(
                label: _tr(
                  langCode,
                  ar: 'مراجعة واختبار جزء',
                  he: 'חזרה ומבחן ג׳וז',
                  en: 'Juz Revision',
                ),
                countLabel: '$revisionCount',
                dotColor: _secondary,
                isSelected: _activeFilter == _AssignmentFilterTab.revision,
                onTap: () => setState(
                  () => _activeFilter = _AssignmentFilterTab.revision,
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
    required List<AttendanceLog> groupAttendanceLogs,
  }) {
    final isPending = card.grade == EvaluationGrade.pending && !card.isPartialRead;
    final isRevision = card.assignmentType == AssignmentType.revision;

    final sideBarColor = isPending
        ? _secondaryContainer
        : (isRevision ? _secondary : _primary);

    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
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
                // 1. Header: Avatar, Name, Live Queue Status & Grade/Score Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: sideBarColor.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              card.initial,
                              style: TextStyle(
                                color: sideBarColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
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
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  card.timeSubtitle,
                                  style: TextStyle(
                                    color: card.isPendingTimeAlert
                                        ? _secondary
                                        : _primary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Score / Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPending ? _secondaryFixed : _primaryFixed,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        card.gradeBadgeLabel,
                        style: TextStyle(
                          color: isPending
                              ? _onSecondaryFixedVariant
                              : _onPrimaryFixed,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. Assigned Range Box
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
                            child: Text(
                              card.rangeTitle,
                              style: TextStyle(
                                color: isRevision ? _secondary : _primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            card.assignmentBadgeLabel,
                            style: const TextStyle(
                              color: _onSurfaceVariant,
                              fontSize: 11,
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
                const SizedBox(height: 10),

                // 3. Teacher Notes
                Text(
                  card.feedbackText,
                  style: const TextStyle(
                    color: _onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),

                // 4. Footer Actions: Student Stats + Edit Homework + Tasmee' Now
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showStudentStatsBottomSheet(
                        context: context,
                        langCode: langCode,
                        studentId: card.studentId,
                        studentName: card.studentName,
                        groupAttendanceLogs: groupAttendanceLogs,
                      ),
                      icon: const Icon(Icons.insights_rounded, size: 16),
                      label: Text(
                        _tr(
                          langCode,
                          ar: 'إحصائيات الطالب والأجزاء',
                          he: 'סטטיסטיקת תלמיד',
                          en: 'Student Stats',
                        ),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showAssignmentEvaluationModal(
                            context: context,
                            langCode: langCode,
                            effectiveGroupId: effectiveGroupId,
                            existingCard: card,
                            assignOnlyMode: true,
                          ),
                          icon: const Icon(Icons.edit_calendar_rounded, size: 15),
                          label: Text(
                            _tr(
                              langCode,
                              ar: 'تعديل الواجب',
                              he: 'ערוך מטלה',
                              en: 'Edit Homework',
                            ),
                            style: const TextStyle(fontSize: 11.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showAssignmentEvaluationModal(
                            context: context,
                            langCode: langCode,
                            effectiveGroupId: effectiveGroupId,
                            existingCard: card,
                            assignOnlyMode: false,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.mic_rounded, size: 16),
                          label: Text(
                            isPending
                                ? _tr(
                                    langCode,
                                    ar: 'تسميع الآن',
                                    he: 'שינון עכשיו',
                                    en: 'Tasmee Now',
                                  )
                                : _tr(
                                    langCode,
                                    ar: 'تعديل التسميع',
                                    he: 'ערוך הערכה',
                                    en: 'Edit Evaluation',
                                  ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

class _StatKpiBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatKpiBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF3D4947),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
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
