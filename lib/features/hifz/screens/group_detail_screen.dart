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
import '../widgets/group_assignment_card.dart';
import '../widgets/group_detail_models.dart';
import '../widgets/group_monthly_attendance_section.dart';
import '../widgets/group_non_hifz_roster_section.dart';
import '../widgets/group_summary_header.dart';
import '../widgets/group_weekly_revision_section.dart';
import 'student_hifz_modal.dart';
import 'teacher_student_profile_screen.dart';

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
  GroupModuleTab _activeModuleTab = GroupModuleTab.studentsRoster;
  bool _orderByDate = false;
  AssignmentFilterTab _activeFilter = AssignmentFilterTab.all;
  bool _showSearchField = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isLiveMode([String? groupId]) {
    if (Firebase.apps.isNotEmpty) return true;
    final String selected = ref.read(selectedGroupIdProvider);
    final String resolvedId = (groupId != null && groupId.isNotEmpty)
        ? groupId
        : (widget.groupId.isNotEmpty ? widget.groupId : (selected.isNotEmpty ? selected : 'grp-hifz-1'));
    final allGroups =
        ref.read(allGroupsStreamProvider).asData?.value ?? ref.read(teacherGroupsProvider).asData?.value ?? const [];
    final enrollments = ref.read(groupEnrollmentsProvider(resolvedId)).asData?.value ?? const [];
    final assignments = ref.read(groupAssignmentsProvider(resolvedId)).asData?.value ?? const [];
    final attendance = ref.read(groupAttendanceProvider(resolvedId)).asData?.value ?? const [];
    final students = ref.read(allStudentsMapProvider).asData?.value ?? const {};
    return allGroups.isNotEmpty ||
        enrollments.isNotEmpty ||
        assignments.isNotEmpty ||
        attendance.isNotEmpty ||
        students.isNotEmpty;
  }

  List<AssignmentCardItem> _buildAssignmentCards(
    List<HifzAssignment> firestoreAssignments,
    String langCode, {
    required bool isLiveMode,
  }) {
    final mappedFirestore = firestoreAssignments.map((item) {
      final trimmed = item.studentName.trim();
      final initial = trimmed.isNotEmpty ? trimmed.characters.first : 'ط';
      final isPending = item.grade == EvaluationGrade.pending && !item.isPartialRead;
      final isExcellent = item.grade == EvaluationGrade.excellent;
      final isGood = item.grade == EvaluationGrade.good;

      String gradeBadge;
      if (item.isPartialRead) {
        gradeBadge = trByLang(
          langCode,
          ar: 'قراءة جزئية (ملاحظة فقط)',
          he: 'קריאה חלקית (הערה)',
          en: 'Partial Read (Note Only)',
        );
      } else if (item.score != null && !isPending) {
        final sText = formatGroupNum(item.score!, langCode);
        final gText = item.grade.localizedName(langCode);
        gradeBadge = '$sText / ${formatGroupNum(100, langCode)} • $gText';
      } else {
        gradeBadge = switch (item.grade) {
          EvaluationGrade.excellent => trByLang(langCode, ar: 'ممتاز (٩٨ / ١٠٠)', he: 'מצוין (98/100)', en: 'Excellent (98/100)'),
          EvaluationGrade.good => trByLang(langCode, ar: 'جيد جداً (٨٥ / ١٠٠)', he: 'טוב מאוד (85/100)', en: 'Very Good (85/100)'),
          EvaluationGrade.needsRepeat => trByLang(langCode, ar: 'يحتاج إعادة', he: 'דורש חזרה', en: 'Needs Repeat'),
          EvaluationGrade.pending => trByLang(langCode, ar: 'في الانتظار', he: 'ממתין', en: 'Pending'),
        };
      }

      final pageLabel = item.targetPage != null ? ' • ص ${formatGroupNum(item.targetPage!, langCode)}' : '';
      final rangeTitle = item.isJuzExam && item.juzNumber != null
          ? 'اختبار ومراجعة الجزء ${formatGroupNum(item.juzNumber!, langCode)} كاملاً'
          : 'سورة ${item.surahName}$pageLabel (الآية ${item.fromAyah} إلى ${item.toAyah})';

      return AssignmentCardItem(
        id: item.id,
        studentId: item.studentId,
        studentName: item.studentName.isNotEmpty ? item.studentName : 'طالب الحلقة',
        initial: initial,
        timeSubtitle: isPending
            ? trByLang(langCode, ar: 'في الانتظار • جاهز للتسميع', he: 'ממתין לשינון', en: 'Pending Recitation')
            : trByLang(langCode, ar: 'تم التسميع اليوم ✓', he: 'נבחן היום ✓', en: 'Evaluated Today ✓'),
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
            : (isExcellent ? 1.0 : (isGood ? 0.85 : (isPending ? 0.20 : 0.45))),
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

    final combined = isLiveMode ? mappedFirestore : [...mappedFirestore, ...groupDetailSeedCards];

    final filtered = combined.where((card) {
      if (_activeFilter == AssignmentFilterTab.newHifz && card.assignmentType != AssignmentType.newHifz) {
        return false;
      }
      if (_activeFilter == AssignmentFilterTab.revision && card.assignmentType != AssignmentType.revision) {
        return false;
      }
      if (_activeFilter == AssignmentFilterTab.pending && card.grade != EvaluationGrade.pending) {
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
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push('${AppRoutes.teacherAttendance}/$effectiveGroupId');
    }
  }

  void _openStudentProfile(String effectiveGroupId, String studentId, String studentName) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push('${AppRoutes.teacherStudentProfile}/$effectiveGroupId/$studentId');
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TeacherStudentProfileScreen(
            groupId: effectiveGroupId,
            studentId: studentId,
            initialStudentName: studentName,
          ),
        ),
      );
    }
  }

  List<({String id, String name, String parentName})> _resolveGroupStudents({
    required String effectiveGroupId,
    required List<AssignmentCardItem> cards,
    List<AttendanceLog> extraLogs = const [],
    bool watchProviders = true,
  }) {
    final isLiveFirebase = _isLiveMode(effectiveGroupId);
    final enrollments = (watchProviders
                ? ref.watch(groupEnrollmentsProvider(effectiveGroupId))
                : ref.read(groupEnrollmentsProvider(effectiveGroupId)))
            .asData
            ?.value ??
        const [];
    final allStudents =
        (watchProviders ? ref.watch(allStudentsMapProvider) : ref.read(allStudentsMapProvider)).asData?.value ??
            const {};

    final result = <({String id, String name, String parentName})>[];
    final seen = <String>{};

    if (enrollments.isNotEmpty) {
      for (final e in enrollments) {
        if (seen.contains(e.studentId)) continue;
        seen.add(e.studentId);
        final profile = allStudents[e.studentId];
        final name =
            profile?.fullName.isNotEmpty == true ? profile!.fullName : (e.studentName.isNotEmpty ? e.studentName : 'طالب');
        result.add((id: e.studentId, name: name, parentName: profile?.parentName ?? ''));
      }
      return result;
    }

    for (final c in cards) {
      if (!seen.contains(c.studentId)) {
        seen.add(c.studentId);
        final profile = allStudents[c.studentId];
        result.add((
          id: c.studentId,
          name: profile?.fullName.isNotEmpty == true ? profile!.fullName : c.studentName,
          parentName: profile?.parentName ?? '',
        ));
      }
    }
    for (final l in extraLogs) {
      if (!seen.contains(l.studentId) && l.studentName.trim().isNotEmpty) {
        seen.add(l.studentId);
        final profile = allStudents[l.studentId];
        result.add((
          id: l.studentId,
          name: profile?.fullName.isNotEmpty == true ? profile!.fullName : l.studentName,
          parentName: profile?.parentName ?? '',
        ));
      }
    }

    if (!isLiveFirebase && !seen.contains('st-1115')) {
      result.add((id: 'st-1115', name: 'حمزة كمال الدين', parentName: 'كمال الدين'));
    }
    return result;
  }

  Future<void> _showAssignmentEvaluationModal({
    required BuildContext context,
    required String langCode,
    required String effectiveGroupId,
    AssignmentCardItem? existingCard,
    bool assignOnlyMode = false,
  }) async {
    final isLiveFirebase = _isLiveMode(effectiveGroupId);
    final teacherGroups = ref.read(teacherGroupsProvider).asData?.value ?? const [];
    final matchedGroup = teacherGroups.where((g) => g.id == effectiveGroupId).firstOrNull;
    final groupTitle = matchedGroup?.name.isNotEmpty == true
        ? matchedGroup!.name
        : (isLiveFirebase
            ? trByLang(langCode, ar: 'الحلقة التعليمية', he: 'קבוצת לימוד', en: 'Study Group')
            : 'حلقة أبي بكر الصديق');

    String targetStudentId = existingCard?.studentId ?? (isLiveFirebase ? '' : 'st-1042');
    String targetStudentName = existingCard?.studentName ?? (isLiveFirebase ? '' : 'إبراهيم طه عثمان');

    if (existingCard == null && isLiveFirebase) {
      final groupStudents = _resolveGroupStudents(
        effectiveGroupId: effectiveGroupId,
        cards: const [],
        watchProviders: false,
      );
      if (groupStudents.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              trByLang(
                langCode,
                ar: 'لا يوجد طلاب مسجلون في هذه الحلقة حالياً',
                he: 'אין תלמידים רשומים לקבוצה זו כעת',
                en: 'No students enrolled in this group yet',
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      } else if (groupStudents.length == 1) {
        targetStudentId = groupStudents.first.id;
        targetStudentName = groupStudents.first.name;
      } else {
        if (!context.mounted) return;
        final picked = await showModalBottomSheet<({String id, String name})>(
          context: context,
          backgroundColor: GroupDetailTokens.surfaceContainerLowest,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (sheetCtx) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      trByLang(
                        langCode,
                        ar: 'اختر الطالب لإضافة التكليف',
                        he: 'בחר תלמיד להוספת משימה',
                        en: 'Select Student for Assignment',
                      ),
                      style: Theme.of(sheetCtx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: GroupDetailTokens.onSurface,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 360),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: groupStudents.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (_, idx) {
                          final st = groupStudents[idx];
                          return ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            tileColor: GroupDetailTokens.surfaceContainerLow,
                            leading: CircleAvatar(
                              backgroundColor: GroupDetailTokens.primaryFixed,
                              child: Text(
                                st.name.characters.first,
                                style: const TextStyle(
                                  color: GroupDetailTokens.onPrimaryFixed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(st.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            onTap: () => Navigator.of(sheetCtx).pop((id: st.id, name: st.name)),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        if (picked == null || !context.mounted) return;
        targetStudentId = picked.id;
        targetStudentName = picked.name;
      }
    }

    if (!context.mounted) return;
    return StudentHifzModal.show(
      context,
      existingAssignmentId: existingCard?.isFromFirestore == true ? existingCard!.id : null,
      groupId: effectiveGroupId,
      groupTitle: groupTitle,
      studentId: targetStudentId,
      studentName: targetStudentName,
      currentType: existingCard?.assignmentType ?? AssignmentType.newHifz,
      currentSurahId: existingCard?.surahId ?? 16,
      currentSurahName: existingCard?.surahName ?? 'النحل',
      currentFromAyah: existingCard?.fromAyah ?? 1,
      currentToAyah: existingCard?.toAyah ?? 128,
      currentTargetPage: existingCard?.targetPage,
      currentJuzNumber: existingCard?.juzNumber,
      initialGrade: existingCard?.grade ?? EvaluationGrade.excellent,
      initialNotes: existingCard != null && existingCard.grade != EvaluationGrade.pending
          ? existingCard.feedbackText
          : '',
      assignOnlyMode: assignOnlyMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final langCode = currentLocale.languageCode;
    final isRtl = isRtlLocale(currentLocale);

    final selectedGroupId = ref.watch(selectedGroupIdProvider);
    final effectiveGroupId =
        widget.groupId.isNotEmpty ? widget.groupId : (selectedGroupId.isNotEmpty ? selectedGroupId : 'grp-hifz-1');

    final allGroups =
        ref.watch(allGroupsStreamProvider).asData?.value ?? ref.watch(teacherGroupsProvider).asData?.value ?? const [];
    final matchedGroup = allGroups.where((g) => g.id == effectiveGroupId).firstOrNull;

    final isHifzGroup = matchedGroup == null
        ? !effectiveGroupId.contains('qaidah') &&
            !effectiveGroupId.contains('tajweed') &&
            !effectiveGroupId.contains('tarbawi')
        : matchedGroup.track == CenterTrack.hifz;

    final effectiveTab = isHifzGroup
        ? _activeModuleTab
        : (_activeModuleTab == GroupModuleTab.assignments || _activeModuleTab == GroupModuleTab.weeklyRevision
            ? GroupModuleTab.studentsRoster
            : _activeModuleTab);

    ref.watch(groupEnrollmentsProvider(effectiveGroupId));
    ref.watch(allStudentsMapProvider);
    final isLiveFirebase = _isLiveMode(effectiveGroupId);

    final groupTitle = matchedGroup?.name.isNotEmpty == true
        ? matchedGroup!.name
        : (isLiveFirebase
            ? trByLang(langCode, ar: 'الحلقة التعليمية', he: 'קבוצת לימוד', en: 'Study Group')
            : trByLang(langCode, ar: 'حلقة أبي بكر الصديق', he: 'קבוצת אבו בכר אל-סידיק', en: 'Abu Bakr As-Siddiq Circle'));

    final groupTrackSubtitle = matchedGroup != null
        ? matchedGroup.track.localizedName(langCode)
        : (isLiveFirebase
            ? ''
            : trByLang(
                langCode,
                ar: 'مسار الحفظ والتسميع • المستوى المتقدم',
                he: 'מסלול חיפז ושינון • רמה מתקדמת',
                en: 'Hifz & Memorization Track',
              ));

    final firestoreAssignments = ref.watch(groupAssignmentsProvider(effectiveGroupId)).asData?.value ?? const [];
    final groupAttendanceLogs = ref.watch(groupAttendanceProvider(effectiveGroupId)).asData?.value ?? const [];

    final cards = _buildAssignmentCards(firestoreAssignments, langCode, isLiveMode: isLiveFirebase);

    final totalCount = isLiveFirebase ? firestoreAssignments.length : firestoreAssignments.length + groupDetailSeedCards.length;
    final newHifzCount = isLiveFirebase
        ? firestoreAssignments.where((a) => a.type == AssignmentType.newHifz).length
        : firestoreAssignments.where((a) => a.type == AssignmentType.newHifz).length + 2;
    final revisionCount = isLiveFirebase
        ? firestoreAssignments.where((a) => a.type == AssignmentType.revision).length
        : firestoreAssignments.where((a) => a.type == AssignmentType.revision).length + 1;
    final pendingCount = isLiveFirebase
        ? firestoreAssignments.where((a) => a.grade == EvaluationGrade.pending).length
        : firestoreAssignments.where((a) => a.grade == EvaluationGrade.pending).length + 1;

    final topPadding = MediaQuery.paddingOf(context).top + 64 + 8;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 96;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: GroupDetailTokens.surface,
        body: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding, left: 16, right: 16),
                    children: [
                      GroupSummaryHeader(
                        langCode: langCode,
                        groupTitle: groupTitle,
                        groupTrackSubtitle: groupTrackSubtitle,
                        isHifzGroup: isHifzGroup,
                        effectiveTab: effectiveTab,
                        onToggleSearch: () => setState(() => _showSearchField = !_showSearchField),
                        onTabSelected: (tab) => setState(() => _activeModuleTab = tab),
                      ),
                      const SizedBox(height: 16),
                      if (effectiveTab == GroupModuleTab.assignments) ...[
                        if (_showSearchField) ...[
                          TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: trByLang(
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
                        GroupFilterAndOrderingControls(
                          langCode: langCode,
                          totalCount: totalCount,
                          newHifzCount: newHifzCount,
                          revisionCount: revisionCount,
                          pendingCount: pendingCount,
                          orderByDate: _orderByDate,
                          activeFilter: _activeFilter,
                          onOrderChanged: (val) => setState(() => _orderByDate = val),
                          onFilterSelected: (filter) => setState(() => _activeFilter = filter),
                        ),
                        const SizedBox(height: 16),
                        if (cards.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.assignment_outlined,
                                    size: 52,
                                    color: GroupDetailTokens.onSurfaceVariant.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    trByLang(
                                      langCode,
                                      ar: 'لا توجد تكليفات حفظ أو مراجعة في هذه الحلقة حالياً',
                                      he: 'אין משימות שינון או חזרה בקבוצה זו כעת',
                                      en: 'No Hifz or revision assignments found for this group',
                                    ),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: GroupDetailTokens.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...cards.map(
                            (card) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GroupAssignmentCard(
                                langCode: langCode,
                                card: card,
                                onShowStats: () => showGroupStudentStatsBottomSheet(
                                  context: context,
                                  ref: ref,
                                  langCode: langCode,
                                  studentId: card.studentId,
                                  studentName: card.studentName,
                                  groupAttendanceLogs: groupAttendanceLogs,
                                  isLiveFirebase: isLiveFirebase,
                                ),
                                onEditHomework: () => _showAssignmentEvaluationModal(
                                  context: context,
                                  langCode: langCode,
                                  effectiveGroupId: effectiveGroupId,
                                  existingCard: card,
                                  assignOnlyMode: true,
                                ),
                                onEvaluateNow: () => _showAssignmentEvaluationModal(
                                  context: context,
                                  langCode: langCode,
                                  effectiveGroupId: effectiveGroupId,
                                  existingCard: card,
                                  assignOnlyMode: false,
                                ),
                              ),
                            ),
                          ),
                      ] else if (effectiveTab == GroupModuleTab.studentsRoster) ...[
                        if (_showSearchField) ...[
                          TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: trByLang(
                                langCode,
                                ar: 'ابحث باسم الطالب...',
                                he: 'חפש לפי שם תלמיד...',
                                en: 'Search by student name...',
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
                        GroupNonHifzRosterSection(
                          langCode: langCode,
                          filteredStudents: _resolveGroupStudents(effectiveGroupId: effectiveGroupId, cards: cards)
                              .where((s) => _searchQuery.trim().isEmpty || s.name.toLowerCase().contains(_searchQuery.trim().toLowerCase()))
                              .toList(),
                          groupAttendanceLogs: groupAttendanceLogs,
                          isLiveFirebase: isLiveFirebase,
                          onLogAttendance: () => _openAttendanceView(effectiveGroupId),
                          onShowStudentStats: (stId, stName) => showGroupStudentStatsBottomSheet(
                            context: context,
                            ref: ref,
                            langCode: langCode,
                            studentId: stId,
                            studentName: stName,
                            groupAttendanceLogs: groupAttendanceLogs,
                            isLiveFirebase: isLiveFirebase,
                          ),
                          onOpenStudentProfile: (stId, stName) =>
                              _openStudentProfile(effectiveGroupId, stId, stName),
                        ),
                      ] else if (effectiveTab == GroupModuleTab.weeklyRevision) ...[
                        GroupWeeklyRevisionSection(
                          langCode: langCode,
                          effectiveGroupId: effectiveGroupId,
                          resolvedStudents: _resolveGroupStudents(effectiveGroupId: effectiveGroupId, cards: cards),
                          isLiveFirebase: isLiveFirebase,
                        ),
                      ] else ...[
                        GroupMonthlyAttendanceSection(
                          langCode: langCode,
                          groupAttendanceLogs: groupAttendanceLogs,
                          resolveStudents: (extraLogs) => _resolveGroupStudents(
                            effectiveGroupId: effectiveGroupId,
                            cards: cards,
                            extraLogs: extraLogs,
                          ),
                          isLiveFirebase: isLiveFirebase,
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
                      color: GroupDetailTokens.surface.withValues(alpha: 0.85),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 1)),
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
                                IconButton(
                                  onPressed: () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go(AppRoutes.teacher);
                                    }
                                  },
                                  tooltip: trByLang(langCode, ar: 'العودة للخلف', he: 'חזור', en: 'Back'),
                                  icon: const Icon(Icons.arrow_back_rounded, color: GroupDetailTokens.onSurface, size: 24),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _openAttendanceView(effectiveGroupId),
                                  icon: const Icon(Icons.how_to_reg_rounded, size: 16),
                                  label: Text(
                                    trByLang(langCode, ar: 'تحضير اليوم', he: 'נוכחות היום', en: 'Log Today'),
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

            if (effectiveTab == GroupModuleTab.assignments)
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
                          backgroundColor: GroupDetailTokens.primary,
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: GroupDetailTokens.primary.withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 22),
                        label: Text(
                          trByLang(
                            langCode,
                            ar: 'تحديد واجب فردي لطالب',
                            he: 'קבע מטלה אישית לתלמיד',
                            en: 'Assign Individual Student Homework',
                          ),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else if (effectiveTab == GroupModuleTab.studentsRoster)
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
                        onPressed: () => _openAttendanceView(effectiveGroupId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GroupDetailTokens.primary,
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: GroupDetailTokens.primary.withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.how_to_reg_rounded, size: 22),
                        label: Text(
                          trByLang(
                            langCode,
                            ar: 'رصد الحضور للحلقة اليوم',
                            he: 'רישום נוכחות לקבוצה היום',
                            en: 'Log Group Attendance Today',
                          ),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
}
