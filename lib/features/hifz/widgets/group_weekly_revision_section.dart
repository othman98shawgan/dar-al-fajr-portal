import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/surah_page_map.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../../admin/models/admin_models.dart';
import '../models/teacher_models.dart';
import '../providers/teacher_providers.dart';
import '../repositories/teacher_repository.dart';
import 'group_detail_models.dart';

class GroupWeeklyRevisionSection extends ConsumerStatefulWidget {
  final String langCode;
  final String effectiveGroupId;
  final List<({String id, String name, String parentName})> resolvedStudents;
  final bool isLiveFirebase;

  const GroupWeeklyRevisionSection({
    super.key,
    required this.langCode,
    required this.effectiveGroupId,
    required this.resolvedStudents,
    required this.isLiveFirebase,
  });

  @override
  ConsumerState<GroupWeeklyRevisionSection> createState() => _GroupWeeklyRevisionSectionState();
}

class _GroupWeeklyRevisionSectionState extends ConsumerState<GroupWeeklyRevisionSection> {
  String _selectedRevisionStudentId = '';
  List<DailyRevisionTask> _draftRevisionTasks = [];
  bool _revisionTasksInitialized = false;
  bool _isSavingRevisionPlan = false;

  @override
  void initState() {
    super.initState();
    _initDefaultDraftRevisionTasks();
  }

  void _initDefaultDraftRevisionTasks() {
    _draftRevisionTasks = List<DailyRevisionTask>.generate(7, (dayIndex) {
      if (dayIndex == 5 || dayIndex == 6) {
        return DailyRevisionTask(dayIndex: dayIndex, isRestDay: true);
      }
      return DailyRevisionTask(
        dayIndex: dayIndex,
        isRestDay: false,
        targetType: RevisionTargetType.juz,
        juzNumber: (30 - dayIndex).clamp(1, 30),
        status: dayIndex < 2 ? RevisionTaskStatus.doneOnTime : RevisionTaskStatus.pending,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final langCode = widget.langCode;
    final uniqueStudents = <String, String>{};
    if (!widget.isLiveFirebase) {
      uniqueStudents['st-1042'] = 'إبراهيم طه عثمان';
      uniqueStudents['st-1088'] = 'عبد الرحمن يوسف الشريف';
      uniqueStudents['st-1102'] = 'زياد المنصور';
    }
    for (final st in widget.resolvedStudents) {
      uniqueStudents[st.id] = st.name;
    }

    if (uniqueStudents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: GroupDetailTokens.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          trByLang(
            langCode,
            ar: 'لا يوجد طلاب مسجلون في هذه الحلقة لإنشاء خطة مراجعة.',
            he: 'אין תלמידים רשומים בקבוצה זו ליצירת תוכנית חזרה.',
            en: 'No students enrolled in this group to create a revision plan.',
          ),
          style: const TextStyle(color: GroupDetailTokens.onSurfaceVariant),
        ),
      );
    }

    if (!uniqueStudents.containsKey(_selectedRevisionStudentId)) {
      _selectedRevisionStudentId = uniqueStudents.keys.first;
    }
    final selectedStudentName = uniqueStudents[_selectedRevisionStudentId] ?? uniqueStudents.values.first;

    final studentsMap = ref.watch(allStudentsMapProvider).asData?.value ?? const {};
    final studentProfile = studentsMap[_selectedRevisionStudentId] ??
        (widget.isLiveFirebase
            ? StudentProfile(id: _selectedRevisionStudentId, fullName: selectedStudentName, parentId: '')
            : StudentProfile(
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
              ));

    final lruQueue = TeacherRepository.computeRevisionPriorityQueueForStudent(studentProfile);
    final studentPlans = ref.watch(studentWeeklyPlansProvider(_selectedRevisionStudentId)).asData?.value ?? const [];
    if (!_revisionTasksInitialized && studentPlans.isNotEmpty) {
      _draftRevisionTasks = List<DailyRevisionTask>.from(studentPlans.first.dailyTasks);
      _revisionTasksInitialized = true;
    }

    const dayNamesAr = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GroupDetailTokens.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_rounded, color: GroupDetailTokens.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    trByLang(langCode, ar: 'الطالب:', he: 'תלמיד:', en: 'Student:'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: _selectedRevisionStudentId,
                items: uniqueStudents.entries
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: GroupDetailTokens.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GroupDetailTokens.primary.withValues(alpha: 0.25)),
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
                          trByLang(
                            langCode,
                            ar: 'أولوية المراجعة (الأبعد عهداً بالمراجعة)',
                            he: 'עדיפות חזרה (הזמן הארוך ביותר ללא חזרה)',
                            en: 'Revision Priority Queue (Least Recently Revised)',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: GroupDetailTokens.primary,
                          ),
                        ),
                        Text(
                          trByLang(
                            langCode,
                            ar: 'مرتبة تلقائياً من الأجزاء التي لم يراجعها الطالب منذ أطول فترة',
                            he: 'מדורג אוטומטית מהג׳וזים שלא נחזרו הכי הרבה זמן',
                            en: 'Sorted by longest days since last revision',
                          ),
                          style: const TextStyle(fontSize: 11, color: GroupDetailTokens.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: autoSuggestFromLruQueue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GroupDetailTokens.primaryFixed,
                      foregroundColor: GroupDetailTokens.onPrimaryFixed,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(Icons.auto_awesome_rounded, size: 15),
                    label: Text(
                      trByLang(langCode, ar: 'توليد تلقائي', he: 'מילוי אוטומטי', en: 'Auto-Fill'),
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isUrgent
                            ? GroupDetailTokens.secondaryFixed.withValues(alpha: 0.7)
                            : GroupDetailTokens.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                trByLang(
                                  langCode,
                                  ar: 'الجزء ${formatGroupNum(item.juzNumber, langCode)}',
                                  he: 'ג׳וז ${item.juzNumber}',
                                  en: 'Juz ${item.juzNumber}',
                                ),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item.juzStatus.localizedName(langCode),
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: GroupDetailTokens.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.daysSinceLastRevision >= 900
                                ? trByLang(langCode, ar: 'لم يُراجع بعد', he: 'טרם נערך סבב חזרה', en: 'Never revised yet')
                                : trByLang(
                                    langCode,
                                    ar: 'منذ ${formatGroupNum(item.daysSinceLastRevision, langCode)} يوم',
                                    he: 'לפני ${item.daysSinceLastRevision} ימים',
                                    en: '${item.daysSinceLastRevision} days ago',
                                  ),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isUrgent ? GroupDetailTokens.secondary : GroupDetailTokens.onSurfaceVariant,
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
        ...List.generate(_draftRevisionTasks.length, (idx) {
          final task = _draftRevisionTasks[idx];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: task.isRestDay ? GroupDetailTokens.surfaceContainerLow : GroupDetailTokens.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: task.isRestDay
                    ? GroupDetailTokens.surfaceContainerHigh
                    : GroupDetailTokens.primary.withValues(alpha: 0.2),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: task.isRestDay ? GroupDetailTokens.surfaceContainerHigh : GroupDetailTokens.primaryFixed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            getDayName(task.dayIndex),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: task.isRestDay
                                  ? GroupDetailTokens.onSurfaceVariant
                                  : GroupDetailTokens.onPrimaryFixed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!task.isRestDay)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: task.status == RevisionTaskStatus.doneOnTime
                                  ? GroupDetailTokens.primary.withValues(alpha: 0.12)
                                  : (task.status == RevisionTaskStatus.doneLate
                                      ? GroupDetailTokens.secondaryFixed
                                      : GroupDetailTokens.surfaceContainerLow),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              task.status.localizedName(langCode),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: task.status == RevisionTaskStatus.doneOnTime
                                    ? GroupDetailTokens.primary
                                    : (task.status == RevisionTaskStatus.doneLate
                                        ? GroupDetailTokens.secondary
                                        : GroupDetailTokens.onSurfaceVariant),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          trByLang(langCode, ar: 'يوم فارغ / راحة', he: 'יום מנוחה', en: 'Empty / Rest Day'),
                          style: const TextStyle(fontSize: 11, color: GroupDetailTokens.onSurfaceVariant),
                        ),
                        Switch(
                          value: task.isRestDay,
                          activeThumbColor: GroupDetailTokens.secondary,
                          onChanged: (val) {
                            setState(() {
                              _draftRevisionTasks[idx] = task.copyWith(isRestDay: val);
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
                              trByLang(langCode, ar: 'جزء كامل', he: 'ג׳וז מלא', en: 'Whole Juz'),
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          ),
                          DropdownMenuItem(
                            value: RevisionTargetType.surah,
                            child: Text(
                              trByLang(langCode, ar: 'سورة', he: 'סורה', en: 'Surah'),
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
                                    trByLang(langCode, ar: 'الجزء ${formatGroupNum(j, langCode)}', he: 'ג׳וז $j', en: 'Juz $j'),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (j) {
                            if (j != null) {
                              setState(() {
                                _draftRevisionTasks[idx] = task.copyWith(juzNumber: j);
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
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
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
                    final weekStart = now.subtract(Duration(days: now.weekday % 7));
                    await ref.read(teacherControllerProvider.notifier).saveWeeklyRevisionPlan(
                          existingPlanId: studentPlans.firstOrNull?.id,
                          studentId: _selectedRevisionStudentId,
                          studentName: selectedStudentName,
                          groupId: widget.effectiveGroupId,
                          weekStartDate: DateTime(weekStart.year, weekStart.month, weekStart.day),
                          dailyTasks: _draftRevisionTasks,
                        );
                    if (!context.mounted) return;
                    setState(() => _isSavingRevisionPlan = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          trByLang(
                            langCode,
                            ar: 'تم حفظ خطة المراجعة الأسبوعية للطالب ($selectedStudentName) بنجاح!',
                            he: 'תוכנית החזרה השבועית נשמרה בהצלחה!',
                            en: 'Weekly revision plan saved successfully!',
                          ),
                        ),
                        backgroundColor: GroupDetailTokens.tertiary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: GroupDetailTokens.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.save_rounded),
            label: Text(
              trByLang(langCode, ar: 'حفظ خطة المراجعة الأسبوعية', he: 'שמור תוכנית חזרה שבועית', en: 'Save Weekly Revision Plan'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
