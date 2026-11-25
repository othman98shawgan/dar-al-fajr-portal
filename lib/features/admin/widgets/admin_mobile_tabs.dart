import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../../auth/models/app_user.dart';
import '../../hifz/models/teacher_models.dart';
import '../models/admin_models.dart';
import '../providers/admin_providers.dart';
import 'admin_dialogs.dart';
import 'admin_mobile_dialogs.dart';
import 'admin_mobile_models.dart';

class AdminMobileStudentsTab extends ConsumerWidget {
  final String langCode;
  final TextEditingController searchController;
  final List<MobileStudentCardData> studentCards;
  final int totalStudents;
  final int totalGroups;
  final int totalOneOnOne;
  final CenterTrack? trackFilter;
  final List<StudyGroup> firestoreGroups;
  final List<StudentProfile> firestoreStudents;
  final List<Enrollment> firestoreEnrollments;
  final bool isDemoMode;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onToggleSortOrder;

  const AdminMobileStudentsTab({
    super.key,
    required this.langCode,
    required this.searchController,
    required this.studentCards,
    required this.totalStudents,
    required this.totalGroups,
    required this.totalOneOnOne,
    required this.trackFilter,
    required this.firestoreGroups,
    required this.firestoreStudents,
    required this.firestoreEnrollments,
    required this.isDemoMode,
    required this.onSearchChanged,
    required this.onToggleSortOrder,
  });

  int _trackCount(CenterTrack track) {
    if (isDemoMode) {
      return switch (track) {
        CenterTrack.hifz => 54,
        CenterTrack.qaidahNouraniah => 38,
        CenterTrack.readingTajweed => 26,
        CenterTrack.tarbawi => 24,
      };
    }
    return firestoreStudents.where((s) {
      final primary = firestoreEnrollments.where((e) => e.studentId == s.id).firstOrNull;
      final studentTrack = primary?.track ?? CenterTrack.hifz;
      return studentTrack == track;
    }).length;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: trByLang(
                        langCode,
                        ar: 'بحث باسم الطالب، الحلقة، أو ولي الأمر...',
                        he: 'חיפוש תלמיד, קבוצה או הורה...',
                        en: 'Search student, group, or parent...',
                      ),
                      hintStyle: const TextStyle(color: Color(0xFF6D7A77), fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6D7A77), size: 22),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune_rounded, color: Color(0xFF3D4947), size: 20),
                        onPressed: () => ref.read(adminTrackFilterProvider.notifier).setTrack(null),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MobileKpiCard(
                        icon: Icons.school_rounded,
                        tagText: trByLang(langCode, ar: 'نشط', he: 'פעיל', en: 'Active'),
                        tagBg: DarAlFajrTheme.primary.withValues(alpha: 0.1),
                        tagFg: DarAlFajrTheme.primary,
                        count: '$totalStudents',
                        label: trByLang(langCode, ar: 'إجمالي الطلاب', he: 'סה״כ תלמידים', en: 'Total Students'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MobileKpiCard(
                        icon: Icons.menu_book_rounded,
                        tagText: trByLang(langCode, ar: 'حلقات', he: 'קבוצות', en: 'Groups'),
                        tagBg: const Color(0xFFFE932C).withValues(alpha: 0.15),
                        tagFg: const Color(0xFF904D00),
                        count: '$totalGroups',
                        label: trByLang(langCode, ar: 'الحلقات النشطة', he: 'קבוצות פעילות', en: 'Active Groups'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MobileKpiCard(
                        icon: Icons.record_voice_over_rounded,
                        tagText: trByLang(langCode, ar: 'اليوم', he: 'היום', en: 'Today'),
                        tagBg: const Color(0xFF3B7F7A).withValues(alpha: 0.15),
                        tagFg: const Color(0xFF1E6661),
                        count: '$totalOneOnOne',
                        label: trByLang(langCode, ar: 'تسميع فردي', he: 'תור אישי', en: '1-on-1 Slots'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _MobileTrackChip(
                        label: trByLang(langCode, ar: 'الكل', he: 'הכל', en: 'All'),
                        count: '$totalStudents',
                        isSelected: trackFilter == null,
                        onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(null),
                      ),
                      const SizedBox(width: 8),
                      _MobileTrackChip(
                        label: trByLang(langCode, ar: 'حفظ', he: 'חיפז', en: 'Hifz'),
                        count: '${_trackCount(CenterTrack.hifz)}',
                        isSelected: trackFilter == CenterTrack.hifz,
                        onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.hifz),
                      ),
                      const SizedBox(width: 8),
                      _MobileTrackChip(
                        label: trByLang(langCode, ar: 'نورانية', he: 'נוראניה', en: 'Nouraniah'),
                        count: '${_trackCount(CenterTrack.qaidahNouraniah)}',
                        isSelected: trackFilter == CenterTrack.qaidahNouraniah,
                        onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.qaidahNouraniah),
                      ),
                      const SizedBox(width: 8),
                      _MobileTrackChip(
                        label: trByLang(langCode, ar: 'تجويد', he: 'טג׳וויד', en: 'Tajweed'),
                        count: '${_trackCount(CenterTrack.readingTajweed)}',
                        isSelected: trackFilter == CenterTrack.readingTajweed,
                        onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.readingTajweed),
                      ),
                      const SizedBox(width: 8),
                      _MobileTrackChip(
                        label: trByLang(langCode, ar: 'تربوي', he: 'חינוכי', en: 'Tarbawi'),
                        count: '${_trackCount(CenterTrack.tarbawi)}',
                        isSelected: trackFilter == CenterTrack.tarbawi,
                        onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.tarbawi),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              trByLang(langCode, ar: 'قائمة الطلاب المسجلين', he: 'רשימת תלמידים', en: 'Enrolled Students'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6E8EA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${studentCards.length} ${trByLang(langCode, ar: "معروض", he: "מוצגים", en: "shown")}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF3D4947), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onToggleSortOrder,
                      icon: const Icon(Icons.swap_vert_rounded, size: 18),
                      label: Text(trByLang(langCode, ar: 'ترتيب', he: 'מיון', en: 'Sort')),
                      style: TextButton.styleFrom(
                        foregroundColor: DarAlFajrTheme.primary,
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final student = studentCards[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MobileStudentCard(
                    student: student,
                    langCode: langCode,
                    onEdit: () {
                      final liveStudents = ref.read(adminStudentsProvider).value ?? const <StudentProfile>[];
                      final profile = liveStudents.where((s) => s.id == student.id).firstOrNull ??
                          StudentProfile(
                            id: student.id,
                            fullName: student.fullName,
                            parentId: 'parent-default',
                            parentName: student.parentName,
                            email: student.parentEmail,
                            phoneNumber: student.parentPhone,
                          );
                      showAdminAddStudentOrUserDialog(
                        context,
                        ref,
                        langCode,
                        existingStudent: profile,
                      );
                    },
                    onEnroll: () => showMobileEnrollmentSheet(
                      context,
                      ref,
                      student,
                      langCode,
                      firestoreGroups,
                      isDemoMode: isDemoMode,
                    ),
                  ),
                );
              },
              childCount: studentCards.length,
            ),
          ),
        ),
      ],
    );
  }
}

class AdminMobileGroupsTab extends ConsumerWidget {
  final String langCode;
  final List<StudyGroup> firestoreGroups;
  final List<Enrollment> firestoreEnrollments;
  final bool isDemoMode;

  const AdminMobileGroupsTab({
    super.key,
    required this.langCode,
    required this.firestoreGroups,
    required this.firestoreEnrollments,
    required this.isDemoMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                trByLang(langCode, ar: 'الحلقات والمجموعات التعليمية', he: 'קבוצות לימוד', en: 'Study Groups'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: DarAlFajrTheme.primary),
              onPressed: () => showMobileCreateGroupDialog(context, ref, langCode, isDemoMode: isDemoMode),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (firestoreGroups.isNotEmpty)
          ...firestoreGroups.map(
            (g) => _MobileGroupCard(
              name: g.name,
              teacher: g.teacherName.isNotEmpty ? g.teacherName : '—',
              trackName: g.track.localizedName(langCode),
              schedule: g.formatScheduleSummary(langCode),
              studentsCount: firestoreEnrollments.where((e) => e.groupId == g.id).length,
              capacity: g.capacity,
              onEdit: () => showAdminEditGroupDialog(
                context,
                ref,
                langCode,
                group: g,
                isDemoFallback: isDemoMode,
              ),
            ),
          )
        else if (isDemoMode) ...[
          const _MobileGroupCard(
            name: 'حلقة أبي بكر الصديق (حفظ مكثف)',
            teacher: 'الشيخ عبد الرحمن',
            trackName: 'مسار الحفظ والتسميع',
            schedule: 'الأحد والثلاثاء والخميس • 16:30',
            studentsCount: 12,
          ),
          const _MobileGroupCard(
            name: 'حلقة الإتقان والتجويد',
            teacher: 'الأستاذ طارق',
            trackName: 'التلاوة والتجويد',
            schedule: 'السبت والاثنين والأربعاء • 17:00',
            studentsCount: 8,
          ),
          const _MobileGroupCard(
            name: 'حلقة البراعم النورانية',
            teacher: 'الأستاذة مريم',
            trackName: 'القاعدة النورانية',
            schedule: 'الخميس • 15:30',
            studentsCount: 10,
          ),
        ] else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                trByLang(langCode, ar: 'لا توجد حلقات مسجلة بعد', he: 'אין קבוצות רשומות עדיין', en: 'No study groups registered yet'),
                style: const TextStyle(color: Color(0xFF6D7A77), fontSize: 13),
              ),
            ),
          ),
      ],
    );
  }
}

class AdminMobileUsersTab extends ConsumerWidget {
  final String langCode;
  final List<AppUser> allUsers;
  final bool isDemoMode;

  const AdminMobileUsersTab({
    super.key,
    required this.langCode,
    required this.allUsers,
    required this.isDemoMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                trByLang(langCode, ar: 'إدارة حسابات المستخدمين', he: 'ניהול משתמשים', en: 'User Accounts'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_rounded, color: DarAlFajrTheme.primary),
              onPressed: () => showAdminAddStudentOrUserDialog(
                context,
                ref,
                langCode,
                initialRole: UserRole.teacher,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (allUsers.isNotEmpty)
          ...allUsers.map(
            (u) => _MobileUserCard(
              name: u.fullName,
              email: u.email,
              role: u.role.localizedName(langCode),
              isPendingFirstLogin: u.isFirstLogin,
              onTap: () => showAdminUserProfileModal(context, ref, u, langCode),
            ),
          )
        else if (isDemoMode) ...[
          const _MobileUserCard(name: 'الشيخ عبد الرحمن', email: 'abdulrahman@daralfajr.org', role: 'معلم', isPendingFirstLogin: false),
          const _MobileUserCard(name: 'الأستاذ طارق', email: 'tariq@daralfajr.org', role: 'معلم', isPendingFirstLogin: false),
          const _MobileUserCard(name: 'طه عثمان', email: 'taha.osman@email.com', role: 'ولي أمر', isPendingFirstLogin: false),
          const _MobileUserCard(name: 'يوسف الشريف', email: 'y.shareef@domain.org', role: 'ولي أمر', isPendingFirstLogin: false),
          const _MobileUserCard(name: 'إبراهيم طه عثمان', email: 'st_1042@daralfajr.org', role: 'طالب', isPendingFirstLogin: false),
        ] else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                trByLang(langCode, ar: 'لا يوجد مستخدمون مسجلون بعد', he: 'אין משתמשים רשומים עדיין', en: 'No users registered yet'),
                style: const TextStyle(color: Color(0xFF6D7A77), fontSize: 13),
              ),
            ),
          ),
      ],
    );
  }
}

class AdminMobileReportsTab extends ConsumerWidget {
  final String langCode;
  final List<StudentProfile> students;
  final List<Enrollment> enrollments;
  final bool isDemoMode;

  const AdminMobileReportsTab({
    super.key,
    required this.langCode,
    required this.students,
    required this.enrollments,
    required this.isDemoMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(adminAttendanceLogsProvider).asData?.value ?? const <AttendanceLog>[];
    final assignments = ref.watch(adminHifzAssignmentsProvider).asData?.value ?? const <HifzAssignment>[];

    final attendedLogsCount =
        logs.where((l) => l.status == AttendanceStatus.present || l.status == AttendanceStatus.late).length;
    final absentLogsCount = logs.where((l) => l.status == AttendanceStatus.absent).length;
    final attendancePercent = logs.isNotEmpty
        ? ((attendedLogsCount / logs.length) * 100).round()
        : (isDemoMode ? 94 : 0);

    final totalJuzCompleted = isDemoMode ? 118 : students.fold<int>(0, (sum, s) => sum + s.completedJuz.length);
    final totalPagesMemorized =
        isDemoMode ? 134 : students.fold<int>(0, (sum, s) => sum + s.memorizedCenterPagesCount);

    final gradedAssignments = assignments.where((a) => a.grade != EvaluationGrade.pending).toList();
    final passedAssignments = gradedAssignments
        .where((a) => a.grade == EvaluationGrade.excellent || a.grade == EvaluationGrade.good)
        .length;
    final masteryPercent = gradedAssignments.isNotEmpty
        ? ((passedAssignments / gradedAssignments.length) * 100).round()
        : (isDemoMode ? 88 : 0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Text(
          trByLang(langCode, ar: 'لوحة التقارير والتحليلات', he: 'דוחות וניתוחים', en: 'Reports & Analytics'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      trByLang(langCode, ar: 'نسبة الحضور الأسبوعية', he: 'נוכחות שבועית', en: 'Weekly Attendance Rate'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$attendancePercent%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: DarAlFajrTheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (attendancePercent / 100).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE6E8EA),
                  valueColor: const AlwaysStoppedAnimation<Color>(DarAlFajrTheme.primary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isDemoMode
                    ? trByLang(
                        langCode,
                        ar: 'سجل 134 طالباً حضوراً منتظماً هذا الأسبوع مقابل 8 حالات غياب بعذر',
                        he: '134 תלמידים נכחו כסדרם',
                        en: '134 students attended regularly this week',
                      )
                    : trByLang(
                        langCode,
                        ar: '$attendedLogsCount سجل حضور مقابل $absentLogsCount غياب من أصل ${logs.length}',
                        he: '$attendedLogsCount רשומות נוכחות מול $absentLogsCount היעדרות מתוך ${logs.length}',
                        en: '$attendedLogsCount attended vs $absentLogsCount absent out of ${logs.length} logs',
                      ),
                style: const TextStyle(color: Color(0xFF6D7A77), fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      trByLang(langCode, ar: 'إجمالي الأجزاء المنجزة', he: 'סה״כ ג׳וז הושלמו', en: 'Total Juz Completed'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isDemoMode
                        ? '118 جزءاً'
                        : '$totalJuzCompleted ${trByLang(langCode, ar: 'جزءاً', he: 'ג׳וז', en: 'Juz')}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF904D00)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isDemoMode
                    ? trByLang(
                        langCode,
                        ar: 'أتم 18 طالباً حفظ الجزء المخصص لهم خلال الشهر الجاري بنجاح وتميز.',
                        he: '18 תלמידים השלימו שינון החודש',
                        en: '18 students completed their monthly assigned Juz successfully.',
                      )
                    : trByLang(
                        langCode,
                        ar: '$totalPagesMemorized صفحة محفوظة • نسبة الإتقان $masteryPercent% (${enrollments.length} تسجيل)',
                        he: '$totalPagesMemorized עמודים נלמדו • הצלחה $masteryPercent% (${enrollments.length} רישומים)',
                        en: '$totalPagesMemorized pages memorized • Mastery rate $masteryPercent% (${enrollments.length} enrollments)',
                      ),
                style: const TextStyle(color: Color(0xFF6D7A77), fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileKpiCard extends StatelessWidget {
  final IconData icon;
  final String tagText;
  final Color tagBg;
  final Color tagFg;
  final String count;
  final String label;

  const _MobileKpiCard({
    required this.icon,
    required this.tagText,
    required this.tagBg,
    required this.tagFg,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: tagFg, size: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(10)),
                child: Text(tagText, style: TextStyle(color: tagFg, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.1)),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6D7A77), fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MobileTrackChip extends StatelessWidget {
  final String label;
  final String count;
  final bool isSelected;
  final VoidCallback onTap;

  const _MobileTrackChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? DarAlFajrTheme.primary : const Color(0xFFE6E8EA),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: DarAlFajrTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF3D4947),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFD8DADC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF3D4947),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileStudentCard extends StatefulWidget {
  final MobileStudentCardData student;
  final String langCode;
  final VoidCallback onEdit;
  final VoidCallback onEnroll;

  const _MobileStudentCard({
    required this.student,
    required this.langCode,
    required this.onEdit,
    required this.onEnroll,
  });

  @override
  State<_MobileStudentCard> createState() => _MobileStudentCardState();
}

class _MobileStudentCardState extends State<_MobileStudentCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final langCode = widget.langCode;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E8EA),
                      borderRadius: BorderRadius.circular(12),
                      image: student.avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(student.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: student.avatarUrl == null
                        ? Text(
                            student.initial,
                            style: const TextStyle(
                              color: DarAlFajrTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                  if (student.isVerified)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: DarAlFajrTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 10),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${trByLang(langCode, ar: "رقم القيد", he: "מס׳ מזהה", en: "ID")}: ${student.code}',
                      style: const TextStyle(color: Color(0xFF6D7A77), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: student.statusPillBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: student.statusDotColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      student.statusPillText,
                      style: TextStyle(
                        color: student.statusPillFg,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                color: const Color(0xFF6D7A77),
                size: 20,
              ),
            ],
          ),
          ),
          if (_isExpanded) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.family_restroom_rounded, size: 16, color: Color(0xFF6D7A77)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              student.parentName,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (student.parentEmail != null)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                student.parentEmail!,
                                style: const TextStyle(color: DarAlFajrTheme.primary, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.mail_rounded, size: 13, color: DarAlFajrTheme.primary),
                          ],
                        ),
                      )
                    else if (student.parentPhone != null)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                student.parentPhone!,
                                style: const TextStyle(color: DarAlFajrTheme.primary, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.call_rounded, size: 13, color: DarAlFajrTheme.primary),
                          ],
                        ),
                      ),
                  ],
                ),
                if (student.streakBadgeText != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        student.streakIcon ?? Icons.workspace_premium_rounded,
                        size: 15,
                        color: student.streakIconColor ?? const Color(0xFFFE932C),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          student.streakBadgeText!,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF3D4947)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E8EA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(student.primaryTrackIcon, size: 13, color: student.primaryTrackColor),
                    const SizedBox(width: 4),
                    Text(
                      student.primaryTrackLabel,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF3D4947), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              if (student.scheduleBadgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: student.scheduleBadgeBg ?? const Color(0xFFFFDCC3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        student.scheduleBadgeIcon ?? Icons.alarm_rounded,
                        size: 13,
                        color: student.scheduleBadgeFg ?? const Color(0xFF6E3900),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        student.scheduleBadgeText!,
                        style: TextStyle(
                          fontSize: 11,
                          color: student.scheduleBadgeFg ?? const Color(0xFF6E3900),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: widget.onEdit,
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: Text(trByLang(langCode, ar: 'تعديل', he: 'ערוך', en: 'Edit')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3D4947),
                    backgroundColor: const Color(0xFFE6E8EA),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: widget.onEnroll,
                  icon: const Icon(Icons.group_add_rounded, size: 16),
                  label: Text(trByLang(langCode, ar: 'تسجيل في حلقة', he: 'רישום לקבוצה', en: 'Enroll in Group')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DarAlFajrTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    visualDensity: VisualDensity.compact,
                    elevation: 1,
                  ),
                ),
              ),
            ],
          ),
          ],
        ],
      ),
    );
  }
}

class _MobileGroupCard extends StatelessWidget {
  final String name;
  final String teacher;
  final String trackName;
  final String schedule;
  final int studentsCount;
  final int? capacity;
  final VoidCallback? onEdit;

  const _MobileGroupCard({
    required this.name,
    required this.teacher,
    required this.trackName,
    required this.schedule,
    required this.studentsCount,
    this.capacity,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18, color: DarAlFajrTheme.primary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: DarAlFajrTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trackName,
                  style: const TextStyle(color: DarAlFajrTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_rounded, size: 16, color: Color(0xFF6D7A77)),
              const SizedBox(width: 6),
              Text(teacher, style: const TextStyle(fontSize: 12, color: Color(0xFF3D4947))),
              const Spacer(),
              const Icon(Icons.school_rounded, size: 16, color: Color(0xFF6D7A77)),
              const SizedBox(width: 4),
              Text(
                capacity != null ? '$studentsCount / $capacity' : '$studentsCount طلاب',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF6D7A77)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  schedule,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A77), height: 1.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileUserCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final bool isPendingFirstLogin;
  final VoidCallback? onTap;

  const _MobileUserCard({
    required this.name,
    required this.email,
    required this.role,
    required this.isPendingFirstLogin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: DarAlFajrTheme.primary.withValues(alpha: 0.1),
            child: Text(
              name.isNotEmpty ? name.characters.first : 'م',
              style: const TextStyle(color: DarAlFajrTheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(email, style: const TextStyle(color: Color(0xFF6D7A77), fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E8EA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(role, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              if (isPendingFirstLogin)
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    'دخول أول',
                    style: TextStyle(color: Color(0xFFFE932C), fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ],
      ),
          ),
        ),
      ),
    );
  }
}
