import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/services/locale_provider.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../../admin/models/admin_models.dart';
import '../models/teacher_models.dart';
import '../providers/teacher_providers.dart';

class _StudentAttendanceRowItem {
  final String studentId;
  final String fullName;
  final String initial;
  final AttendanceStatus defaultStatus;

  const _StudentAttendanceRowItem({
    required this.studentId,
    required this.fullName,
    required this.initial,
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
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _showSuccessBanner = false;

  final Map<String, Map<String, AttendanceStatus>> _editedStatusesByDate = {};

  // Color tokens mapped from Stitch
  static const Color _surface = Color(0xFFF7F9FB);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLow = Color(0xFFF2F4F6);
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
      defaultStatus: AttendanceStatus.present,
    ),
    _StudentAttendanceRowItem(
      studentId: 'st-1088',
      fullName: 'عبد الرحمن يوسف الشريف',
      initial: 'ع',
      defaultStatus: AttendanceStatus.present,
    ),
    _StudentAttendanceRowItem(
      studentId: 'st-1102',
      fullName: 'زياد المنصور',
      initial: 'ز',
      defaultStatus: AttendanceStatus.late,
    ),
    _StudentAttendanceRowItem(
      studentId: 'st-1115',
      fullName: 'حمزة كمال الدين',
      initial: 'ح',
      defaultStatus: AttendanceStatus.excused,
    ),
    _StudentAttendanceRowItem(
      studentId: 'st-1120',
      fullName: 'عمر فاروق البغدادي',
      initial: 'ع',
      defaultStatus: AttendanceStatus.present,
    ),
    _StudentAttendanceRowItem(
      studentId: 'st-1125',
      fullName: 'محمد أنس رضوان',
      initial: 'م',
      defaultStatus: AttendanceStatus.present,
    ),
    _StudentAttendanceRowItem(
      studentId: 'st-1130',
      fullName: 'خالد بن وليد التميمي',
      initial: 'خ',
      defaultStatus: AttendanceStatus.present,
    ),
    _StudentAttendanceRowItem(
      studentId: 'st-1135',
      fullName: 'بلال سعد السبيعي',
      initial: 'ب',
      defaultStatus: AttendanceStatus.present,
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isFutureDate(DateTime date) {
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final candidate = DateTime(date.year, date.month, date.day);
    return candidate.isAfter(todayOnly);
  }

  void _stepDate(int deltaDays) {
    final nextDate = _selectedDate.add(Duration(days: deltaDays));
    if (_isFutureDate(nextDate)) return;
    setState(() {
      _selectedDate = nextDate;
      _showSuccessBanner = false;
    });
  }

  void _setStudentStatus(String studentId, AttendanceStatus status) {
    final key = _dateKey(_selectedDate);
    setState(() {
      _editedStatusesByDate.putIfAbsent(key, () => <String, AttendanceStatus>{})[studentId] =
          status;
    });
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
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final initial = _isFutureDate(_selectedDate) ? todayOnly : _selectedDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: todayOnly,
    );
    if (picked != null && !_isFutureDate(picked) && mounted) {
      setState(() {
        _selectedDate = picked;
        _showSuccessBanner = false;
      });
    }
  }

  void _markAllPresent(List<_StudentAttendanceRowItem> students) {
    final key = _dateKey(_selectedDate);
    setState(() {
      final map = _editedStatusesByDate.putIfAbsent(key, () => <String, AttendanceStatus>{});
      for (final s in students) {
        map[s.studentId] = AttendanceStatus.present;
      }
    });
  }

  Future<void> _handleSaveAttendance({
    required String effectiveGroupId,
    required StudyGroup? matchedGroup,
    required List<_StudentAttendanceRowItem> students,
    required Map<String, AttendanceStatus> effectiveStatuses,
    required bool isUpdatingExisting,
    required String langCode,
  }) async {
    if (_isSaving) return;

    if (_isFutureDate(_selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            trByLang(
              langCode,
              ar: 'لا يمكن تسجيل الحضور لتاريخ مستقبلي',
              he: 'לא ניתן לרשום נוכחות לתאריך עתידי',
              en: 'Cannot record attendance for a future date',
            ),
          ),
          backgroundColor: _error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final scheduledSlots = matchedGroup?.effectiveScheduleSlots ?? const <GroupScheduleSlot>[];
    if (scheduledSlots.isNotEmpty &&
        matchedGroup!.slotsForWeekday(_selectedDate.weekday).isEmpty) {
      final selectedDayName =
          ScheduleDayHelper.localizedDayName(_selectedDate.weekday, langCode);
      final scheduledDaysText = scheduledSlots
          .map(
            (s) => s.weekday != null
                ? ScheduleDayHelper.localizedDayName(s.weekday!, langCode)
                : s.day,
          )
          .toSet()
          .join(' • ');

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dlgCtx) => AlertDialog(
          title: Text(
            trByLang(
              langCode,
              ar: 'يوم خارج جدول الحلقة',
              he: 'יום מחוץ למערכת הקבוצה',
              en: 'Non-Scheduled Group Day',
            ),
          ),
          content: Text(
            trByLang(
              langCode,
              ar: 'يوم $selectedDayName ليس ضمن الأيام المجدولة لهذه الحلقة ($scheduledDaysText). هل تريد المتابعة وتسجيل الحضور على أي حال؟',
              he: 'יום $selectedDayName אינו בימי הקבוצה הקבועים ($scheduledDaysText). האם להמשיך ולרשום נוכחות?',
              en: '$selectedDayName is not one of this group\'s scheduled days ($scheduledDaysText). Do you want to record attendance anyway?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dlgCtx).pop(false),
              child: Text(trByLang(langCode, ar: 'إلغاء', he: 'ביטול', en: 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dlgCtx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                trByLang(langCode, ar: 'تأكيد وحفظ', he: 'אשר ושמור', en: 'Confirm & Save'),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() {
      _isSaving = true;
    });

    final statusesToSave = <String, AttendanceStatus>{};
    final namesToSave = <String, String>{};
    for (final s in students) {
      statusesToSave[s.studentId] =
          effectiveStatuses[s.studentId] ?? s.defaultStatus;
      namesToSave[s.studentId] = s.fullName;
    }

    final ok = await ref
        .read(teacherControllerProvider.notifier)
        .saveBatchAttendance(
          groupId: effectiveGroupId,
          studentStatuses: statusesToSave,
          studentNames: namesToSave,
          sessionMode: SessionMode.group,
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
              ? (isUpdatingExisting
                  ? trByLang(
                      langCode,
                      ar: 'تم تحديث سجل الحضور بنجاح (${students.length} طلاب)',
                      he: 'יומן הנוכחות עודכן בהצלחה (${students.length} תלמידים)',
                      en: 'Attendance log updated (${students.length} students)',
                    )
                  : trByLang(
                      langCode,
                      ar: 'تم حفظ الحضور واعتماد السجل بنجاح (${students.length} طلاب)',
                      he: 'נוכחות נשמרה ואושרה בהצלחה (${students.length} תלמידים)',
                      en: 'Attendance saved and approved (${students.length} students)',
                    ))
              : trByLang(
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
    final allGroups =
        ref.watch(allGroupsStreamProvider).asData?.value ?? const [];
    final matchedGroup = teacherGroups
            .where((g) => g.id == effectiveGroupId)
            .firstOrNull ??
        allGroups.where((g) => g.id == effectiveGroupId).firstOrNull;

    final groupTitle = matchedGroup?.name.isNotEmpty == true
        ? matchedGroup!.name
        : trByLang(
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

    final allStudents = ref.watch(allStudentsMapProvider).asData?.value ?? const {};
    final groupLogs =
        ref.watch(groupAttendanceProvider(effectiveGroupId)).asData?.value ??
            const <AttendanceLog>[];
    final isLiveFirebase = Firebase.apps.isNotEmpty || enrollments.isNotEmpty;
    final students = <_StudentAttendanceRowItem>[];
    final seenStudentIds = <String>{};

    if (isLiveFirebase) {
      for (final enrollment in enrollments) {
        if (seenStudentIds.contains(enrollment.studentId)) continue;
        final profile = allStudents[enrollment.studentId];
        final resolvedName = profile?.fullName.trim().isNotEmpty == true
            ? profile!.fullName.trim()
            : enrollment.studentName.trim();
        if (resolvedName.isEmpty) continue;
        seenStudentIds.add(enrollment.studentId);
        students.add(
          _StudentAttendanceRowItem(
            studentId: enrollment.studentId,
            fullName: resolvedName,
            initial: resolvedName.characters.first,
            defaultStatus: AttendanceStatus.present,
          ),
        );
      }
    } else {
      students.addAll(_seedStudents);
    }

    // Load previously saved logs for `_selectedDate` (if any), keeping latest per student.
    final savedLogsForDate = <String, AttendanceLog>{};
    for (final log in groupLogs) {
      if (log.sessionMode == SessionMode.group &&
          _isSameDay(log.sessionDate, _selectedDate)) {
        final prev = savedLogsForDate[log.studentId];
        if (prev == null ||
            (log.createdAt ?? log.sessionDate)
                .isAfter(prev.createdAt ?? prev.sessionDate)) {
          savedLogsForDate[log.studentId] = log;
        }
      }
    }
    final hasExistingLogsForDate = savedLogsForDate.isNotEmpty;
    final manualEdits = _editedStatusesByDate[_dateKey(_selectedDate)] ?? const {};
    final effectiveStatuses = <String, AttendanceStatus>{};
    for (final s in students) {
      effectiveStatuses[s.studentId] =
          manualEdits[s.studentId] ??
          savedLogsForDate[s.studentId]?.status ??
          s.defaultStatus;
    }

    int presentCount = 0;
    int lateCount = 0;
    int absentCount = 0;
    int excusedCount = 0;
    for (final s in students) {
      final st = effectiveStatuses[s.studentId] ?? s.defaultStatus;
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
                      const SizedBox(height: 16),
                      _buildDateSelectorRow(
                        context: context,
                        langCode: langCode,
                        hasExistingLogsForDate: hasExistingLogsForDate,
                      ),
                      if (hasExistingLogsForDate) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 16, color: _primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  trByLang(
                                    langCode,
                                    ar: 'تم رصد حضور هذا اليوم مسبقاً — عند الحفظ سيتم تحديث السجل الحالي',
                                    he: 'נוכחות ליום זה כבר נרשמה — שמירה תעדכן את הרישום הקיים',
                                    en: 'Attendance already logged for this day — saving updates the existing log',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: _primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                              trByLang(
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
                      if (students.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people_outline_rounded,
                                  size: 48,
                                  color: _onSurfaceVariant.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  trByLang(
                                    langCode,
                                    ar: 'لا يوجد طلاب مسجلون في هذه الحلقة حالياً',
                                    he: 'אין תלמידים רשומים לקבוצה זו כעת',
                                    en: 'No students enrolled in this group yet',
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: _onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...students.map(
                          (student) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildStudentAttendanceCard(
                              context: context,
                              langCode: langCode,
                              student: student,
                              currentStatus:
                                  effectiveStatuses[student.studentId] ??
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
                                      tooltip: trByLang(
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
                                      trByLang(
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
                                              matchedGroup: matchedGroup,
                                              students: students,
                                              effectiveStatuses:
                                                  effectiveStatuses,
                                              isUpdatingExisting:
                                                  hasExistingLogsForDate,
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
                                          ? trByLang(
                                              langCode,
                                              ar: 'جاري حفظ الحضور...',
                                              he: 'שומר נוכחות...',
                                              en: 'Saving attendance...',
                                            )
                                          : (_showSuccessBanner
                                              ? trByLang(
                                                  langCode,
                                                  ar: 'تم الحفظ والاعتماد بنجاح',
                                                  he: 'נשמר ואושר בהצלחה',
                                                  en: 'Saved & Approved Successfully',
                                                )
                                              : (hasExistingLogsForDate
                                                  ? trByLang(
                                                      langCode,
                                                      ar: 'تحديث سجل الحضور',
                                                      he: 'עדכן יומן נוכחות',
                                                      en: 'Update Attendance Log',
                                                    )
                                                  : trByLang(
                                                      langCode,
                                                      ar: 'حفظ الحضور واعتماد السجل',
                                                      he: 'שמור נוכחות ואשר יומן',
                                                      en: 'Save & Approve Attendance',
                                                    ))),
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
                  trByLang(
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

  Widget _buildDateSelectorRow({
    required BuildContext context,
    required String langCode,
    required bool hasExistingLogsForDate,
  }) {
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    final canGoNext = !_isFutureDate(_selectedDate.add(const Duration(days: 1)));
    final dayLabel = ScheduleDayHelper.localizedDayName(_selectedDate.weekday, langCode);
    final dateText = _formatDateLabel(_selectedDate, langCode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _primary.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: _surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            child: IconButton(
              onPressed: () => _stepDate(-1),
              tooltip: trByLang(langCode, ar: 'اليوم السابق', he: 'יום קודם', en: 'Previous Day'),
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: _primary,
                size: 22,
              ),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 20,
                      color: _primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  dayLabel,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: _primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isToday) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _primary,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    trByLang(langCode, ar: 'اليوم', he: 'היום', en: 'Today'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateText,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: _onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            hasExistingLogsForDate
                                ? trByLang(
                                    langCode,
                                    ar: 'مسجل مسبقاً • اضغط للتغيير',
                                    he: 'נרשם בעבר • לחץ לשינוי',
                                    en: 'Logged • Tap to change',
                                  )
                                : trByLang(
                                    langCode,
                                    ar: 'اضغط لاختيار تاريخ من التقويم',
                                    he: 'לחץ לבחירת תאריך מהיומן',
                                    en: 'Tap to pick date from calendar',
                                  ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: _outline,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: _primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: _surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            child: IconButton(
              onPressed: canGoNext ? () => _stepDate(1) : null,
              tooltip: trByLang(langCode, ar: 'اليوم التالي', he: 'יום הבא', en: 'Next Day'),
              icon: Icon(
                Icons.chevron_right_rounded,
                color: canGoNext ? _primary : _outline.withValues(alpha: 0.4),
                size: 22,
              ),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
        ],
      ),
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
                    trByLang(
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
                          trByLang(
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
                  label: trByLang(langCode, ar: 'حاضر', he: 'נוכח', en: 'Present'),
                  valueText: _formatNum(presentCount, langCode),
                  valueColor: _primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricStatPill(
                  dotColor: _secondary,
                  label: trByLang(langCode, ar: 'متأخر', he: 'איחור', en: 'Late'),
                  valueText: _formatNum(lateCount, langCode),
                  valueColor: _secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricStatPill(
                  dotColor: _error,
                  label: trByLang(langCode, ar: 'غائب/معذور', he: 'חיסור', en: 'Absent'),
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
                      child: Text(
                        student.fullName,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: _onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
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
                    label: trByLang(langCode, ar: 'حاضر', he: 'נוכח', en: 'Present'),
                    icon: Icons.check_rounded,
                    isActive: isPresent,
                    activeColor: _primary,
                    onTap: () => _setStudentStatus(
                      student.studentId,
                      AttendanceStatus.present,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _StatusSegmentButton(
                    label: trByLang(langCode, ar: 'متأخر', he: 'איחור', en: 'Late'),
                    icon: Icons.schedule_rounded,
                    isActive: isLate,
                    activeColor: _secondary,
                    onTap: () => _setStudentStatus(
                      student.studentId,
                      AttendanceStatus.late,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _StatusSegmentButton(
                    label: trByLang(langCode, ar: 'غائب', he: 'חיסור', en: 'Absent'),
                    icon: Icons.close_rounded,
                    isActive: isAbsent,
                    activeColor: _error,
                    onTap: () => _setStudentStatus(
                      student.studentId,
                      AttendanceStatus.absent,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _StatusSegmentButton(
                    label: trByLang(langCode, ar: 'معذور', he: 'מוצדק', en: 'Excused'),
                    icon: Icons.verified_user_outlined,
                    isActive: isExcused,
                    activeColor: _tertiary,
                    onTap: () => _setStudentStatus(
                      student.studentId,
                      AttendanceStatus.excused,
                    ),
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
