import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/surah_page_map.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/services/locale_provider.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../../admin/models/admin_models.dart';
import '../models/teacher_models.dart';
import '../providers/teacher_providers.dart';
import '../repositories/teacher_repository.dart';
import '../widgets/group_detail_models.dart';
import 'student_hifz_modal.dart';

class TeacherStudentProfileScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String studentId;
  final String initialStudentName;

  const TeacherStudentProfileScreen({
    super.key,
    required this.groupId,
    required this.studentId,
    this.initialStudentName = '',
  });

  @override
  ConsumerState<TeacherStudentProfileScreen> createState() =>
      _TeacherStudentProfileScreenState();
}

class _TeacherStudentProfileScreenState
    extends ConsumerState<TeacherStudentProfileScreen> {
  AssignmentType? _historyFilter;

  bool _isLiveMode() {
    if (Firebase.apps.isNotEmpty) return true;
    final profile = ref.read(studentProfileByIdProvider(widget.studentId)).asData?.value;
    final assignments = ref.read(studentAssignmentsProvider(widget.studentId)).asData?.value ?? const [];
    final plans = ref.read(studentWeeklyPlansProvider(widget.studentId)).asData?.value ?? const [];
    final allStudents = ref.read(allStudentsMapProvider).asData?.value ?? const {};
    final allGroups = ref.read(allGroupsStreamProvider).asData?.value ?? const [];
    return profile != null ||
        assignments.isNotEmpty ||
        plans.isNotEmpty ||
        allStudents.isNotEmpty ||
        allGroups.isNotEmpty;
  }

  String _formatDate(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }

  String _dayName(int dayIndex, String langCode) {
    const ar = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    const en = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const he = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת'];
    if (langCode == 'he') return he[dayIndex % 7];
    if (langCode == 'en') return en[dayIndex % 7];
    return ar[dayIndex % 7];
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final langCode = currentLocale.languageCode;
    final isRtl = isRtlLocale(currentLocale);

    final watchedProfile = ref.watch(studentProfileByIdProvider(widget.studentId)).asData?.value;
    final allStudentsMap = ref.watch(allStudentsMapProvider).asData?.value ?? const {};
    final watchedAssignments =
        ref.watch(studentAssignmentsProvider(widget.studentId)).asData?.value ?? const <HifzAssignment>[];
    final watchedPlans =
        ref.watch(studentWeeklyPlansProvider(widget.studentId)).asData?.value ?? const <WeeklyRevisionPlan>[];
    final groupLogs =
        ref.watch(groupAttendanceProvider(widget.groupId)).asData?.value ?? const <AttendanceLog>[];
    final allGroups = ref.watch(allGroupsStreamProvider).asData?.value ?? const <StudyGroup>[];

    final isLive = _isLiveMode();
    final matchedGroup = allGroups.where((g) => g.id == widget.groupId).firstOrNull;
    final groupTitle = matchedGroup?.name.isNotEmpty == true
        ? matchedGroup!.name
        : (isLive
            ? trByLang(langCode, ar: 'الحلقة التعليمية', he: 'קבוצת לימוד', en: 'Study Group')
            : 'حلقة أبي بكر الصديق');

    final profile = watchedProfile ??
        allStudentsMap[widget.studentId] ??
        (isLive
            ? StudentProfile(
                id: widget.studentId,
                fullName: widget.initialStudentName.isNotEmpty
                    ? widget.initialStudentName
                    : trByLang(langCode, ar: 'ملف الطالب', he: 'פרופיל תלמיד', en: 'Student Profile'),
                parentId: '',
              )
            : StudentProfile(
                id: widget.studentId,
                fullName: widget.initialStudentName.isNotEmpty ? widget.initialStudentName : 'إبراهيم طه عثمان',
                parentId: 'parent-1',
                parentName: 'طه عثمان',
                memorizedPages: const [1, 2, 3, 4, 5, 582, 583, 584, 585, 586, 587],
                completedSurahs: List.generate(37, (i) => 78 + i),
                completedJuz: const [30, 29],
                juzStatuses: const {
                  30: 'passed_exam',
                  29: 'ready_for_exam',
                  28: 'in_progress',
                },
                lastRevisedJuzDates: {
                  30: DateTime.now().subtract(const Duration(days: 3)),
                  29: DateTime.now().subtract(const Duration(days: 15)),
                },
              ));

    final sortedAssignments = List<HifzAssignment>.from(
      watchedAssignments.isNotEmpty || isLive
          ? watchedAssignments
          : _demoSeedAssignments(widget.studentId, profile.fullName, widget.groupId),
    )..sort((a, b) => b.assignedAt.compareTo(a.assignedAt));

    final filteredAssignments = _historyFilter == null
        ? sortedAssignments
        : sortedAssignments.where((a) => a.type == _historyFilter).toList();

    final sortedPlans = List<WeeklyRevisionPlan>.from(watchedPlans)
      ..sort((a, b) => b.weekStartDate.compareTo(a.weekStartDate));
    final activePlan = sortedPlans.firstOrNull ??
        (isLive ? null : _demoSeedWeeklyPlan(widget.studentId, profile.fullName, widget.groupId));

    final studentLogs = groupLogs.where((l) => l.studentId == widget.studentId).toList();
    final totalSessions = studentLogs.isNotEmpty || isLive ? studentLogs.length : 12;
    final attendedSessions = studentLogs.isNotEmpty || isLive
        ? studentLogs
            .where((l) => l.status == AttendanceStatus.present || l.status == AttendanceStatus.late)
            .length
        : 11;
    final attendancePercent =
        totalSessions > 0 ? ((attendedSessions / totalSessions) * 100).round() : (isLive ? 0 : 92);

    final lruQueue = TeacherRepository.computeRevisionPriorityQueueForStudent(profile);
    final topPadding = MediaQuery.paddingOf(context).top + 64 + 12;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 28;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: GroupDetailTokens.surface,
        body: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: ListView(
                    padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding, left: 16, right: 16),
                    children: [
                      // 1. Header & KPI Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: GroupDetailTokens.surfaceContainerLowest,
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
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: GroupDetailTokens.primaryFixed,
                                  child: Text(
                                    profile.fullName.isNotEmpty ? profile.fullName.characters.first : 'ط',
                                    style: const TextStyle(
                                      color: GroupDetailTokens.onPrimaryFixed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.fullName,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: GroupDetailTokens.onSurface,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        groupTitle,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: GroupDetailTokens.primary,
                                        ),
                                      ),
                                      if (profile.parentName != null && profile.parentName!.trim().isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '${trByLang(langCode, ar: 'ولي الأمر:', he: 'הורה:', en: 'Parent:')} ${profile.parentName}${profile.phoneNumber != null && profile.phoneNumber!.trim().isNotEmpty ? ' • ${profile.phoneNumber}' : ''}',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: GroupDetailTokens.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: GroupStatKpiBox(
                                    label: trByLang(langCode, ar: 'صفحات المركز', he: 'עמודי מרכז', en: 'Center Pages'),
                                    value:
                                        '${formatGroupNum(profile.memorizedCenterPagesCount, langCode)} / ${formatGroupNum(CenterQuranMap.totalCenterPages, langCode)}',
                                    color: GroupDetailTokens.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GroupStatKpiBox(
                                    label: trByLang(langCode, ar: 'السور المنجزة', he: 'סורות שהושלמו', en: 'Surahs Done'),
                                    value: '${formatGroupNum(profile.completedSurahs.length, langCode)} / ${formatGroupNum(114, langCode)}',
                                    color: GroupDetailTokens.tertiary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GroupStatKpiBox(
                                    label: trByLang(langCode, ar: 'نسبة الحضور', he: 'נוכחות', en: 'Attendance'),
                                    value: '${formatGroupNum(attendancePercent, langCode)}%',
                                    color: GroupDetailTokens.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 2. Current Revision Plan Section
                      _SectionHeader(
                        icon: Icons.calendar_view_week_rounded,
                        color: GroupDetailTokens.primary,
                        title: trByLang(
                          langCode,
                          ar: 'خطة المراجعة الأسبوعية الحالية',
                          he: 'תוכנית החזרה השבועית הנוכחית',
                          en: 'Current Weekly Revision Plan',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: GroupDetailTokens.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (lruQueue.isNotEmpty) ...[
                              Text(
                                trByLang(
                                  langCode,
                                  ar: 'أولوية المراجعة (الأبعد عهداً):',
                                  he: 'עדיפות חזרה:',
                                  en: 'Revision Priority (LRU):',
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: GroupDetailTokens.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: lruQueue.take(6).map((item) {
                                    final isUrgent = item.daysSinceLastRevision >= 14;
                                    return Container(
                                      margin: const EdgeInsetsDirectional.only(end: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isUrgent
                                            ? GroupDetailTokens.secondaryFixed.withValues(alpha: 0.75)
                                            : GroupDetailTokens.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${trByLang(langCode, ar: 'جزء ${formatGroupNum(item.juzNumber, langCode)}', he: 'ג׳וז ${item.juzNumber}', en: 'Juz ${item.juzNumber}')} • ${item.daysSinceLastRevision >= 900 ? trByLang(langCode, ar: 'جديد', he: 'חדש', en: 'New') : trByLang(langCode, ar: '${formatGroupNum(item.daysSinceLastRevision, langCode)}ي', he: '${item.daysSinceLastRevision}י׳', en: '${item.daysSinceLastRevision}d')}',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: isUrgent ? GroupDetailTokens.secondary : GroupDetailTokens.onSurface,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            if (activePlan == null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  trByLang(
                                    langCode,
                                    ar: 'لا توجد خطة مراجعة أسبوعية مسجلة لهذا الطالب حالياً.',
                                    he: 'אין תוכנית חזרה שבועית פעילה לתלמיד זה.',
                                    en: 'No active weekly revision plan assigned to this student yet.',
                                  ),
                                  style: const TextStyle(color: GroupDetailTokens.onSurfaceVariant, fontSize: 13),
                                ),
                              )
                            else ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${trByLang(langCode, ar: 'أسبوع:', he: 'שבוע:', en: 'Week of:')} ${_formatDate(activePlan.weekStartDate)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: GroupDetailTokens.primary,
                                    ),
                                  ),
                                  Text(
                                    '${formatGroupNum(activePlan.completedDaysCount, langCode)} / ${formatGroupNum(activePlan.activeDaysCount, langCode)} ${trByLang(langCode, ar: 'منجز', he: 'הושלמו', en: 'done')}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: GroupDetailTokens.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...activePlan.dailyTasks.map((task) {
                                final isDone = task.status == RevisionTaskStatus.doneOnTime ||
                                    task.status == RevisionTaskStatus.doneLate;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: task.isRestDay
                                        ? GroupDetailTokens.surfaceContainerLow
                                        : GroupDetailTokens.surface,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 68,
                                        child: Text(
                                          _dayName(task.dayIndex, langCode),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          task.displaySummary(langCode),
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: task.isRestDay
                                                ? GroupDetailTokens.onSurfaceVariant
                                                : GroupDetailTokens.onSurface,
                                            fontWeight: task.isRestDay ? FontWeight.normal : FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (!task.isRestDay)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isDone
                                                ? GroupDetailTokens.primaryFixed
                                                : GroupDetailTokens.surfaceContainerHigh,
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            task.status.localizedName(langCode),
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: isDone
                                                  ? GroupDetailTokens.onPrimaryFixed
                                                  : GroupDetailTokens.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Past & Current Assignments History
                      _SectionHeader(
                        icon: Icons.history_edu_rounded,
                        color: GroupDetailTokens.secondary,
                        title: trByLang(
                          langCode,
                          ar: 'سجل الواجبات والتسميعات (${formatGroupNum(filteredAssignments.length, langCode)})',
                          he: 'היסטוריית משימות ושינון (${filteredAssignments.length})',
                          en: 'Assignments History (${filteredAssignments.length})',
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _HistoryFilterChip(
                              label: trByLang(langCode, ar: 'الكل', he: 'הכל', en: 'All'),
                              isSelected: _historyFilter == null,
                              onTap: () => setState(() => _historyFilter = null),
                            ),
                            const SizedBox(width: 8),
                            _HistoryFilterChip(
                              label: AssignmentType.newHifz.localizedName(langCode),
                              isSelected: _historyFilter == AssignmentType.newHifz,
                              onTap: () => setState(() => _historyFilter = AssignmentType.newHifz),
                            ),
                            const SizedBox(width: 8),
                            _HistoryFilterChip(
                              label: AssignmentType.revision.localizedName(langCode),
                              isSelected: _historyFilter == AssignmentType.revision,
                              onTap: () => setState(() => _historyFilter = AssignmentType.revision),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (filteredAssignments.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: GroupDetailTokens.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            trByLang(
                              langCode,
                              ar: 'لا توجد تكليفات أو تسميعات مسجلة بعد.',
                              he: 'אין עדיין משימות או הערכות רשומות.',
                              en: 'No assignments or evaluations recorded yet.',
                            ),
                            style: const TextStyle(color: GroupDetailTokens.onSurfaceVariant),
                          ),
                        )
                      else
                        ...filteredAssignments.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _AssignmentHistoryCard(
                                langCode: langCode,
                                assignment: item,
                                formattedDate: _formatDate(item.assignedAt),
                                onTap: () => StudentHifzModal.show(
                                  context,
                                  existingAssignmentId: item.id.startsWith('seed-') ? null : item.id,
                                  groupId: widget.groupId.isNotEmpty ? widget.groupId : item.groupId,
                                  groupTitle: groupTitle,
                                  studentId: profile.id,
                                  studentName: profile.fullName,
                                  currentType: item.type,
                                  currentSurahId: item.surahId,
                                  currentSurahName: item.surahName,
                                  currentFromAyah: item.fromAyah,
                                  currentToAyah: item.toAyah,
                                  currentTargetPage: item.targetPage,
                                  currentJuzNumber: item.juzNumber,
                                  initialGrade: item.grade,
                                  initialNotes: item.teacherNotes,
                                ),
                              ),
                            )),

                      const SizedBox(height: 14),

                      // 4. 30-Juz Progression Overview
                      _SectionHeader(
                        icon: Icons.auto_stories_rounded,
                        color: GroupDetailTokens.tertiary,
                        title: trByLang(
                          langCode,
                          ar: 'حالة الأجزاء واختبارات الأجزاء',
                          he: 'סטטוס ג׳וזים ומבחנים',
                          en: 'Juz Progression & Exams',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: GroupDetailTokens.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(30, (idx) {
                            final juz = 30 - idx;
                            final rawStatus = profile.juzStatuses[juz] ??
                                (profile.completedJuz.contains(juz) ? 'passed_exam' : null);
                            final status = rawStatus != null ? JuzProgressStatus.fromString(rawStatus) : null;

                            final bgColor = switch (status) {
                              JuzProgressStatus.passedExam => GroupDetailTokens.primaryFixed,
                              JuzProgressStatus.readyForExam => GroupDetailTokens.secondaryFixed,
                              JuzProgressStatus.inProgress => GroupDetailTokens.primary.withValues(alpha: 0.08),
                              null => GroupDetailTokens.surfaceContainerLow,
                            };
                            final textColor = switch (status) {
                              JuzProgressStatus.passedExam => GroupDetailTokens.onPrimaryFixed,
                              JuzProgressStatus.readyForExam => GroupDetailTokens.onSecondaryFixed,
                              JuzProgressStatus.inProgress => GroupDetailTokens.primary,
                              null => GroupDetailTokens.onSurfaceVariant,
                            };

                            return Container(
                              width: 96,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Text(
                                    trByLang(
                                      langCode,
                                      ar: 'الجزء ${formatGroupNum(juz, langCode)}',
                                      he: 'ג׳וז $juz',
                                      en: 'Juz $juz',
                                    ),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    status != null
                                        ? status.localizedName(langCode)
                                        : trByLang(langCode, ar: 'لم يبدأ', he: 'טרם התחיל', en: 'Not Started'),
                                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: textColor),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          }),
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
                      color: GroupDetailTokens.surface.withValues(alpha: 0.88),
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
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: Container(
                            height: 64,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    final router = GoRouter.maybeOf(context);
                                    if (router != null) {
                                      if (router.canPop()) {
                                        router.pop();
                                      } else {
                                        router.go(AppRoutes.teacher);
                                      }
                                    } else {
                                      Navigator.of(context).maybePop();
                                    }
                                  },
                                  tooltip: trByLang(langCode, ar: 'العودة للخلف', he: 'חזור', en: 'Back'),
                                  icon: const Icon(Icons.arrow_back_rounded, color: GroupDetailTokens.onSurface),
                                ),
                                Expanded(
                                  child: Text(
                                    trByLang(langCode, ar: 'ملف الطالب', he: 'פרופיל תלמיד', en: 'Student Profile'),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: GroupDetailTokens.onSurface,
                                        ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => StudentHifzModal.show(
                                    context,
                                    groupId: widget.groupId,
                                    groupTitle: groupTitle,
                                    studentId: profile.id,
                                    studentName: profile.fullName,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: GroupDetailTokens.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.mic_rounded, size: 16),
                                  label: Text(
                                    trByLang(langCode, ar: 'تسميع', he: 'שינון', en: 'Tasmee'),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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

  List<HifzAssignment> _demoSeedAssignments(String studentId, String studentName, String groupId) {
    final now = DateTime.now();
    return [
      HifzAssignment(
        id: 'seed-hist-1',
        studentId: studentId,
        studentName: studentName,
        groupId: groupId,
        teacherId: 'teacher-1',
        type: AssignmentType.newHifz,
        surahId: 17,
        surahName: 'الإسراء',
        fromAyah: 1,
        toAyah: 15,
        targetPage: 282,
        juzNumber: 15,
        grade: EvaluationGrade.excellent,
        score: 97,
        lafziCount: 1,
        teacherNotes: 'إتقان متين لأحكام النون الساكنة والمد المتصل.',
        assignedAt: now.subtract(const Duration(days: 1)),
        evaluatedAt: now.subtract(const Duration(days: 1)),
      ),
      HifzAssignment(
        id: 'seed-hist-2',
        studentId: studentId,
        studentName: studentName,
        groupId: groupId,
        teacherId: 'teacher-1',
        type: AssignmentType.revision,
        surahId: 78,
        surahName: 'النبأ',
        fromAyah: 1,
        toAyah: 40,
        juzNumber: 30,
        isJuzExam: true,
        grade: EvaluationGrade.good,
        score: 88,
        lafziCount: 2,
        fathCount: 2,
        teacherNotes: 'تنبيه لموضع القلقلة في سورة البروج.',
        assignedAt: now.subtract(const Duration(days: 6)),
        evaluatedAt: now.subtract(const Duration(days: 6)),
      ),
    ];
  }

  WeeklyRevisionPlan _demoSeedWeeklyPlan(String studentId, String studentName, String groupId) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday % 7));
    return WeeklyRevisionPlan(
      id: 'seed-plan-$studentId',
      studentId: studentId,
      studentName: studentName,
      groupId: groupId,
      teacherId: 'teacher-1',
      weekStartDate: weekStart,
      updatedAt: now,
      dailyTasks: [
        const DailyRevisionTask(dayIndex: 0, targetType: RevisionTargetType.juz, juzNumber: 30, status: RevisionTaskStatus.doneOnTime),
        const DailyRevisionTask(dayIndex: 1, targetType: RevisionTargetType.juz, juzNumber: 29, status: RevisionTaskStatus.doneOnTime),
        const DailyRevisionTask(dayIndex: 2, targetType: RevisionTargetType.surah, surahId: 67, surahName: 'الملك', status: RevisionTaskStatus.pending),
        const DailyRevisionTask(dayIndex: 3, targetType: RevisionTargetType.juz, juzNumber: 28, status: RevisionTaskStatus.pending),
        const DailyRevisionTask(dayIndex: 4, targetType: RevisionTargetType.juz, juzNumber: 27, status: RevisionTaskStatus.pending),
        const DailyRevisionTask(dayIndex: 5, isRestDay: true),
        const DailyRevisionTask(dayIndex: 6, isRestDay: true),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: GroupDetailTokens.onSurface,
                ),
          ),
        ),
      ],
    );
  }
}

class _HistoryFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _HistoryFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: GroupDetailTokens.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : GroupDetailTokens.onSurfaceVariant,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

class _AssignmentHistoryCard extends StatelessWidget {
  final String langCode;
  final HifzAssignment assignment;
  final String formattedDate;
  final VoidCallback onTap;

  const _AssignmentHistoryCard({
    required this.langCode,
    required this.assignment,
    required this.formattedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = assignment.grade == EvaluationGrade.pending && !assignment.isPartialRead;
    final isNeedsRepeat = assignment.grade == EvaluationGrade.needsRepeat || assignment.forceRepeat;
    final statusColor = isNeedsRepeat
        ? Colors.red.shade700
        : (isPending ? GroupDetailTokens.secondary : GroupDetailTokens.primary);

    final surahLabel = assignment.surahName.isNotEmpty
        ? assignment.surahName
        : CenterQuranMap.getSurahById(assignment.surahId).localizedName(langCode);
    final pageSuffix = assignment.targetPage != null
        ? ' • ${trByLang(langCode, ar: 'ص ${formatGroupNum(assignment.targetPage!, langCode)}', he: 'עמ׳ ${assignment.targetPage}', en: 'p.${assignment.targetPage}')}'
        : '';
    final rangeTitle = assignment.isJuzExam && assignment.juzNumber != null
        ? trByLang(
            langCode,
            ar: 'اختبار ومراجعة الجزء ${formatGroupNum(assignment.juzNumber!, langCode)}',
            he: 'מבחן וחזרת ג׳וז ${assignment.juzNumber}',
            en: 'Juz ${assignment.juzNumber} Exam / Revision',
          )
        : '$surahLabel$pageSuffix (${formatGroupNum(assignment.fromAyah, langCode)} - ${formatGroupNum(assignment.toAyah, langCode)})';

    final gradeText = assignment.isPartialRead
        ? RecitationUnitType.partialRead.localizedName(langCode)
        : (assignment.score != null && !isPending
            ? '${formatGroupNum(assignment.score!, langCode)} / ${formatGroupNum(100, langCode)} • ${assignment.grade.localizedName(langCode)}'
            : assignment.grade.localizedName(langCode));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: GroupDetailTokens.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 6,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: assignment.type == AssignmentType.revision
                            ? GroupDetailTokens.secondaryFixed
                            : GroupDetailTokens.primaryFixed,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        assignment.type.localizedName(langCode),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: assignment.type == AssignmentType.revision
                              ? GroupDetailTokens.onSecondaryFixed
                              : GroupDetailTokens.onPrimaryFixed,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 11.5, color: GroupDetailTokens.onSurfaceVariant),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    gradeText,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              rangeTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: GroupDetailTokens.onSurface,
              ),
            ),
            if (!isPending &&
                !assignment.isPartialRead &&
                (assignment.lafziCount > 0 || assignment.fathCount > 0 || assignment.tataaCount > 0)) ...[
              const SizedBox(height: 6),
              Text(
                trByLang(
                  langCode,
                  ar: 'لفظي: ${formatGroupNum(assignment.lafziCount, langCode)} • فتح: ${formatGroupNum(assignment.fathCount, langCode)} • تعتعة: ${formatGroupNum(assignment.tataaCount, langCode)}',
                  he: 'הגייה: ${assignment.lafziCount} • פתיחה: ${assignment.fathCount} • תיקון: ${assignment.tataaCount}',
                  en: 'Lafzi: ${assignment.lafziCount} • Fath: ${assignment.fathCount} • Tataa: ${assignment.tataaCount}',
                ),
                style: const TextStyle(fontSize: 11.5, color: GroupDetailTokens.onSurfaceVariant),
              ),
            ],
            if (assignment.teacherNotes.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                assignment.teacherNotes.trim(),
                style: const TextStyle(fontSize: 12, color: GroupDetailTokens.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
