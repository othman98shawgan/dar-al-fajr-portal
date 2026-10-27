import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/services/locale_provider.dart';
import '../models/teacher_models.dart';
import '../providers/teacher_providers.dart';

class _StudentAttendanceRowItem {
  final String studentId;
  final String fullName;
  final String initial;
  final String subtitle;
  final String? lateExcuseSubtitle;
  final String? absentExcuseSubtitle;
  final bool isStarred;
  final AttendanceStatus defaultStatus;

  const _StudentAttendanceRowItem({
    required this.studentId,
    required this.fullName,
    required this.initial,
    required this.subtitle,
    this.lateExcuseSubtitle,
    this.absentExcuseSubtitle,
    this.isStarred = false,
    this.defaultStatus = AttendanceStatus.present,
  });
}

class AttendanceLoggingView extends ConsumerStatefulWidget {
  final String groupId;

  const AttendanceLoggingView({
    super.key,
    this.groupId = '',
  });

  @override
  ConsumerState<AttendanceLoggingView> createState() =>
      _AttendanceLoggingViewState();
}

class _AttendanceLoggingViewState extends ConsumerState<AttendanceLoggingView> {
  DateTime _selectedDate = DateTime(2026, 10, 18);
  SessionMode _sessionMode = SessionMode.group;
  bool _isSaving = false;
  bool _showSuccessBanner = false;

  final Map<String, AttendanceStatus> _studentStatuses = {};

  // Color tokens mapped from Stitch
  static const Color _surface = Color(0xFFF7F9FB);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color _surfaceContainer = Color(0xFFECEEF0);
  static const Color _surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color _onSurface = Color(0xFF191C1E);
  static const Color _onSurfaceVariant = Color(0xFF3D4947);
  static const Color _outline = Color(0xFF6D7A77);
  static const Color _primary = Color(0xFF00685F);
  static const Color _secondary = Color(0xFF904D00);
  static const Color _secondaryFixed = Color(0xFFFFDCC3);
  static const Color _onSecondaryFixed = Color(0xFF2F1500);
  static const Color _tertiary = Color(0xFF1E6661);
  static const Color _error = Color(0xFFBA1A1A);
  static const Color _errorContainer = Color(0xFFFFDAD6);
  static const Color _onErrorContainer = Color(0xFF93000A);

  static const List<_StudentAttendanceRowItem> _seedStudents = [
    _StudentAttendanceRowItem(
      studentId: 'st-1042',
      fullName: 'إبراهيم طه عثمان',
      initial: 'إ',
      subtitle: 'سورة البقرة • الحزب الأول',
      isStarred: true,
      defaultStatus: AttendanceStatus.present,
    ),
    _StudentAttendanceRowItem(
      studentId: 'st-1088',
      fullName: 'عبد الرحمن يوسف الشريف',
      initial: 'ع',
      subtitle: 'سورة آل عمران • الحزب الثاني',
      defaultStatus: AttendanceStatus.present,
    ),
    _StudentAttendanceRowItem(
      studentId: 'st-1102',
      fullName: 'زياد المنصور',
      initial: 'ز',
      subtitle: 'سورة النحل • الحزب السابع والعشرون',
      lateExcuseSubtitle: 'تأخر ١٥ دقيقة (ازدحام سير)',
      defaultStatus: AttendanceStatus.late,
    ),
    _StudentAttendanceRowItem(
      studentId: 'st-1115',
      fullName: 'حمزة كمال الدين',
      initial: 'ح',
      subtitle: 'سورة الكهف • الحزب الثلاثون',
      absentExcuseSubtitle: 'غائب بعذر مسبق (طبي)',
      defaultStatus: AttendanceStatus.excused,
    ),
    _StudentAttendanceRowItem(
      studentId: 'st-1120',
      fullName: 'عمر فاروق البغدادي',
      initial: 'ع',
      subtitle: 'سورة المائدة • الحزب الرابع',
      defaultStatus: AttendanceStatus.present,
    ),
    _StudentAttendanceRowItem(
      studentId: 'st-1125',
      fullName: 'محمد أنس رضوان',
      initial: 'م',
      subtitle: 'سورة الأعراف • الحزب السادس',
      defaultStatus: AttendanceStatus.present,
    ),
    _StudentAttendanceRowItem(
      studentId: 'st-1130',
      fullName: 'خالد بن وليد التميمي',
      initial: 'خ',
      subtitle: 'سورة الأنفال • مراجعة',
      defaultStatus: AttendanceStatus.present,
    ),
    _StudentAttendanceRowItem(
      studentId: 'st-1135',
      fullName: 'بلال سعد السبيعي',
      initial: 'ب',
      subtitle: 'سورة التوبة • الحزب التاسع',
      defaultStatus: AttendanceStatus.present,
    ),
  ];

  @override
  void initState() {
    super.initState();
    for (final s in _seedStudents) {
      _studentStatuses[s.studentId] = s.defaultStatus;
    }
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

  String _formatDateLabel(DateTime date, String langCode) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    final raw = '$d / $m / $y';
    if (langCode != 'ar') return raw;
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var localized = raw;
    for (var i = 0; i < western.length; i++) {
      localized = localized.replaceAll(western[i], eastern[i]);
    }
    return localized;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _markAllPresent(List<_StudentAttendanceRowItem> students) {
    setState(() {
      for (final s in students) {
        _studentStatuses[s.studentId] = AttendanceStatus.present;
      }
    });
  }

  Future<void> _handleSaveAttendance({
    required String effectiveGroupId,
    required List<_StudentAttendanceRowItem> students,
    required String langCode,
  }) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final statusesToSave = <String, AttendanceStatus>{};
    final namesToSave = <String, String>{};
    for (final s in students) {
      statusesToSave[s.studentId] =
          _studentStatuses[s.studentId] ?? s.defaultStatus;
      namesToSave[s.studentId] = s.fullName;
    }

    final ok = await ref
        .read(teacherControllerProvider.notifier)
        .saveBatchAttendance(
          groupId: effectiveGroupId,
          studentStatuses: statusesToSave,
          studentNames: namesToSave,
          sessionMode: _sessionMode,
          sessionDate: _selectedDate,
        );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _showSuccessBanner = ok;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? _tr(
                  langCode,
                  ar: 'تم حفظ الحضور واعتماد السجل بنجاح (${students.length} طلاب)',
                  he: 'נוכחות נשמרה ואושרה בהצלחה (${students.length} תלמידים)',
                  en: 'Attendance saved and approved (${students.length} students)',
                )
              : _tr(
                  langCode,
                  ar: 'حدث خطأ أثناء حفظ الحضور',
                  he: 'אירעה שגיאה בשמירת הנוכחות',
                  en: 'Failed to save attendance',
                ),
        ),
        backgroundColor: ok ? _tertiary : _error,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (ok) {
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showSuccessBanner = false;
          });
        }
      });
    }
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

    final enrollments = ref
            .watch(groupEnrollmentsProvider(effectiveGroupId))
            .asData
            ?.value ??
        const [];

    final students = <_StudentAttendanceRowItem>[..._seedStudents];
    for (final enrollment in enrollments) {
      final exists =
          students.any((s) => s.studentId == enrollment.studentId);
      if (!exists && enrollment.studentName.trim().isNotEmpty) {
        final trimmed = enrollment.studentName.trim();
        students.add(
          _StudentAttendanceRowItem(
            studentId: enrollment.studentId,
            fullName: trimmed,
            initial: trimmed.characters.first,
            subtitle: enrollment.track.localizedName(langCode),
            defaultStatus: AttendanceStatus.present,
          ),
        );
        _studentStatuses.putIfAbsent(
          enrollment.studentId,
          () => AttendanceStatus.present,
        );
      }
    }

    int presentCount = 0;
    int lateCount = 0;
    int absentCount = 0;
    int excusedCount = 0;
    for (final s in students) {
      final st = _studentStatuses[s.studentId] ?? s.defaultStatus;
      switch (st) {
        case AttendanceStatus.present:
          presentCount++;
          break;
        case AttendanceStatus.late:
          lateCount++;
          break;
        case AttendanceStatus.absent:
          absentCount++;
          break;
        case AttendanceStatus.excused:
          excusedCount++;
          break;
      }
    }

    final topPadding = MediaQuery.paddingOf(context).top + 64 + 8;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 140;

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
                      _buildSessionHeader(
                        context: context,
                        langCode: langCode,
                        groupTitle: groupTitle,
                      ),
                      const SizedBox(height: 8),
                      _buildSegmentedTabs(
                        context: context,
                        langCode: langCode,
                        effectiveGroupId: effectiveGroupId,
                      ),
                      const SizedBox(height: 16),
                      _buildFilterAndModeRow(
                        context: context,
                        langCode: langCode,
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActionAndStatsCard(
                        context: context,
                        langCode: langCode,
                        students: students,
                        presentCount: presentCount,
                        lateCount: lateCount,
                        absentCount: absentCount + excusedCount,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _tr(
                                langCode,
                                ar: 'قائمة الطلاب (${_formatNum(students.length, langCode)} متاحون الآن)',
                                he: 'רשימת תלמידים (${students.length} זמינים כעת)',
                                en: 'Student Roster (${students.length} available now)',
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: _onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...students.map(
                        (student) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildStudentAttendanceCard(
                            context: context,
                            langCode: langCode,
                            student: student,
                            currentStatus:
                                _studentStatuses[student.studentId] ??
                                    student.defaultStatus,
                          ),
                        ),
                      ),
                    ],
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (context.canPop()) {
                                          context.pop();
                                        } else {
                                          context.go(
                                            '${AppRoutes.teacherGroupDetail}/$effectiveGroupId',
                                          );
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
                                        ar: 'رصد الحضور اليومي',
                                        he: 'רישום נוכחות יומי',
                                        en: 'Attendance Logging View',
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

            // Sticky Bottom Save Action Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _surface.withValues(alpha: 0.95),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 390),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: _isSaving
                                        ? null
                                        : () => _handleSaveAttendance(
                                              effectiveGroupId:
                                                  effectiveGroupId,
                                              students: students,
                                              langCode: langCode,
                                            ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _showSuccessBanner
                                          ? _tertiary
                                          : _primary,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: Icon(
                                      _isSaving
                                          ? Icons.sync_rounded
                                          : (_showSuccessBanner
                                              ? Icons.done_all_rounded
                                              : Icons.check_circle_rounded),
                                      size: 20,
                                    ),
                                    label: Text(
                                      _isSaving
                                          ? _tr(
                                              langCode,
                                              ar: 'جاري حفظ الحضور...',
                                              he: 'שומר נוכחות...',
                                              en: 'Saving attendance...',
                                            )
                                          : (_showSuccessBanner
                                              ? _tr(
                                                  langCode,
                                                  ar: 'تم الحفظ والاعتماد بنجاح',
                                                  he: 'נשמר ואושר בהצלחה',
                                                  en: 'Saved & Approved Successfully',
                                                )
                                              : _tr(
                                                  langCode,
                                                  ar: 'حفظ الحضور واعتماد السجل',
                                                  he: 'שמור נוכחות ואשר יומן',
                                                  en: 'Save & Approve Attendance',
                                                )),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSessionHeader({
    required BuildContext context,
    required String langCode,
    required String groupTitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _tr(
                    langCode,
                    ar: 'رصد الحضور اليومي السريع',
                    he: 'רישום נוכחות יומי מהיר',
                    en: 'Fast Daily Attendance Logging',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: _primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabs({
    required BuildContext context,
    required String langCode,
    required String effectiveGroupId,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.how_to_reg_rounded,
                    size: 18,
                    color: _primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _tr(
                      langCode,
                      ar: 'الحضور',
                      he: 'נוכחות',
                      en: 'Attendance',
                    ),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(
                    '${AppRoutes.teacherGroupDetail}/$effectiveGroupId',
                  );
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.assignment_outlined,
                      size: 18,
                      color: _onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _tr(
                        langCode,
                        ar: 'الواجبات والخطة',
                        he: 'מטלות ותוכנית',
                        en: 'Assignments & Plan',
                      ),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: _onSurfaceVariant,
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
    );
  }

  Widget _buildFilterAndModeRow({
    required BuildContext context,
    required String langCode,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Material(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          elevation: 0.5,
          child: InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: _primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateLabel(_selectedDate, langCode),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.expand_more_rounded,
                    size: 16,
                    color: _outline,
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => setState(() => _sessionMode = SessionMode.group),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _sessionMode == SessionMode.group
                        ? _primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _tr(langCode, ar: 'جماعي', he: 'קבוצתי', en: 'Group'),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: _sessionMode == SessionMode.group
                              ? Colors.white
                              : _onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              InkWell(
                onTap: () =>
                    setState(() => _sessionMode = SessionMode.oneOnOne),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _sessionMode == SessionMode.oneOnOne
                        ? _primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _tr(langCode, ar: 'فردي', he: 'פרטני', en: '1-on-1'),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: _sessionMode == SessionMode.oneOnOne
                              ? Colors.white
                              : _onSurfaceVariant,
                          fontWeight: FontWeight.w600,
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

  Widget _buildQuickActionAndStatsCard({
    required BuildContext context,
    required String langCode,
    required List<_StudentAttendanceRowItem> students,
    required int presentCount,
    required int lateCount,
    required int absentCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    size: 20,
                    color: _secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _tr(
                      langCode,
                      ar: 'إجراء سريع',
                      he: 'פעולה מהירה',
                      en: 'Quick Action',
                    ),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Material(
                color: _surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => _markAllPresent(students),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.done_all_rounded,
                          size: 16,
                          color: _primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _tr(
                            langCode,
                            ar: 'تحضير الكل حاضر',
                            he: 'סמן הכל כנוכח',
                            en: 'Mark All Present',
                          ),
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: _primary,
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricStatPill(
                  dotColor: _primary,
                  label: _tr(langCode, ar: 'حاضر', he: 'נוכח', en: 'Present'),
                  valueText: _formatNum(presentCount, langCode),
                  valueColor: _primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricStatPill(
                  dotColor: _secondary,
                  label: _tr(langCode, ar: 'متأخر', he: 'איחור', en: 'Late'),
                  valueText: _formatNum(lateCount, langCode),
                  valueColor: _secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricStatPill(
                  dotColor: _error,
                  label: _tr(langCode, ar: 'غائب/معذور', he: 'חיסור', en: 'Absent'),
                  valueText: _formatNum(absentCount, langCode),
                  valueColor: _error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentAttendanceCard({
    required BuildContext context,
    required String langCode,
    required _StudentAttendanceRowItem student,
    required AttendanceStatus currentStatus,
  }) {
    final isPresent = currentStatus == AttendanceStatus.present;
    final isLate = currentStatus == AttendanceStatus.late;
    final isAbsent = currentStatus == AttendanceStatus.absent;
    final isExcused = currentStatus == AttendanceStatus.excused;

    final avatarBg = isPresent
        ? _primary.withValues(alpha: 0.10)
        : (isLate ? _secondaryFixed : _errorContainer);
    final avatarFg = isPresent
        ? _primary
        : (isLate ? _onSecondaryFixed : _onErrorContainer);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
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
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: avatarBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        student.initial,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: avatarFg,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.fullName,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: _onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            student.subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: _onSurfaceVariant,
                                  fontSize: 11,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 4-Button Attendance Status Selector (حاضر / متأخر / غائب / معذور)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatusSegmentButton(
                    label: _tr(langCode, ar: 'حاضر', he: 'נוכח', en: 'Present'),
                    icon: Icons.check_rounded,
                    isActive: isPresent,
                    activeColor: _primary,
                    onTap: () => setState(() {
                      _studentStatuses[student.studentId] =
                          AttendanceStatus.present;
                    }),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _StatusSegmentButton(
                    label: _tr(langCode, ar: 'متأخر', he: 'איחור', en: 'Late'),
                    icon: Icons.schedule_rounded,
                    isActive: isLate,
                    activeColor: _secondary,
                    onTap: () => setState(() {
                      _studentStatuses[student.studentId] =
                          AttendanceStatus.late;
                    }),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _StatusSegmentButton(
                    label: _tr(langCode, ar: 'غائب', he: 'חיסור', en: 'Absent'),
                    icon: Icons.close_rounded,
                    isActive: isAbsent,
                    activeColor: _error,
                    onTap: () => setState(() {
                      _studentStatuses[student.studentId] =
                          AttendanceStatus.absent;
                    }),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _StatusSegmentButton(
                    label: _tr(langCode, ar: 'معذور', he: 'מוצדק', en: 'Excused'),
                    icon: Icons.verified_user_outlined,
                    isActive: isExcused,
                    activeColor: _tertiary,
                    onTap: () => setState(() {
                      _studentStatuses[student.studentId] =
                          AttendanceStatus.excused;
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricStatPill extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String valueText;
  final Color valueColor;

  const _MetricStatPill({
    required this.dotColor,
    required this.label,
    required this.valueText,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF3D4947),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          Text(
            valueText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusSegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _StatusSegmentButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? activeColor : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      elevation: isActive ? 0.5 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isActive) ...[
                Icon(
                  icon,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 3),
              ],
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF3D4947),
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.w500,
                        fontSize: 11.5,
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
}
