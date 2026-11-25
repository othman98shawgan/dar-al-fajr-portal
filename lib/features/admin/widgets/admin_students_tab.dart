import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../models/admin_models.dart';
import '../providers/admin_providers.dart';
import 'admin_dialogs.dart';
import 'admin_shell_models.dart';

class AdminStudentsTab extends ConsumerWidget {
  final String langCode;
  final TextEditingController subSearchController;
  final List<AdminRosterRowData> rosterRows;
  final int totalStudentsCount;
  final int totalGroupsCount;
  final int totalOneOnOneCount;
  final CenterTrack? selectedTrackFilter;
  final String selectedStudentId;
  final bool isDemoFallback;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddStudentPressed;
  final VoidCallback onOpenEnrollDrawer;
  final ValueChanged<AdminRosterRowData> onSelectStudentRow;

  const AdminStudentsTab({
    super.key,
    required this.langCode,
    required this.subSearchController,
    required this.rosterRows,
    required this.totalStudentsCount,
    required this.totalGroupsCount,
    required this.totalOneOnOneCount,
    required this.selectedTrackFilter,
    required this.selectedStudentId,
    required this.isDemoFallback,
    required this.onSearchChanged,
    required this.onAddStudentPressed,
    required this.onOpenEnrollDrawer,
    required this.onSelectStudentRow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Sub-Header with search & action buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: DarAlFajrTheme.surface,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 3, offset: const Offset(0, 1)),
            ],
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 340,
                    height: 38,
                    child: TextField(
                      controller: subSearchController,
                      onChanged: onSearchChanged,
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF2F4F6),
                        hintText: trByLang(
                          langCode,
                          ar: 'البحث عن طالب، ولي أمر، أو رقم هاتف...',
                          he: 'חפש תלמיד, הורה או טלפון...',
                          en: 'Search student, parent, or phone...',
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF6D7A77)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                    builder: (ctx) {
                      final showArchived = ref.watch(adminShowArchivedProvider);
                      final archivedCount = (ref.watch(adminStudentsProvider).asData?.value ?? const [])
                          .where((s) => s.isArchived)
                          .length;
                      if (archivedCount == 0 && !showArchived) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: FilterChip(
                          label: Text(
                            trByLang(langCode, ar: 'المؤرشف ($archivedCount)', he: 'ארכיון ($archivedCount)', en: 'Archived ($archivedCount)'),
                          ),
                          selected: showArchived,
                          onSelected: (v) => ref.read(adminShowArchivedProvider.notifier).setShowArchived(v),
                        ),
                      );
                    },
                  ),
                  OutlinedButton.icon(
                    onPressed: onAddStudentPressed,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFECEEF0),
                      foregroundColor: const Color(0xFF191C1E),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: Text(trByLang(langCode, ar: '+ إضافة طالب', he: '+ הוסף תלמיד', en: '+ Add Student')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onOpenEnrollDrawer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DarAlFajrTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.group_add_rounded, size: 18),
                    label: Text(trByLang(langCode, ar: '+ تسجيل في حلقة', he: '+ רישום לקבוצה', en: '+ Enroll in Group')),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Main Padded Content
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 4-Card Stats Summary Ribbon
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      AdminStatSummaryCard(
                        width: (constraints.maxWidth - 48) / 4,
                        title: trByLang(
                          langCode,
                          ar: 'إجمالي الطلاب المسجلين',
                          he: 'סה״כ תלמידים רשומים',
                          en: 'Total Enrolled Students',
                        ),
                        value: '$totalStudentsCount',
                        unit: trByLang(langCode, ar: 'طالب نشط', he: 'תלמיד פעיל', en: 'Active students'),
                        icon: Icons.school_rounded,
                        accentColor: DarAlFajrTheme.primary,
                      ),
                      AdminStatSummaryCard(
                        width: (constraints.maxWidth - 48) / 4,
                        title: trByLang(langCode, ar: 'الحلقات الفعالة', he: 'קבוצות פעילות', en: 'Active Groups'),
                        value: '$totalGroupsCount',
                        unit: trByLang(langCode, ar: 'حلقة ومقرأة', he: 'קבוצות לימוד', en: 'Study circles'),
                        icon: Icons.groups_rounded,
                        accentColor: DarAlFajrTheme.primary,
                      ),
                      AdminStatSummaryCard(
                        width: (constraints.maxWidth - 48) / 4,
                        title: trByLang(
                          langCode,
                          ar: 'الجلسات الفردية المجدولة',
                          he: 'מפגשים אישיים מתוזמנים',
                          en: 'Scheduled 1-on-1 Slots',
                        ),
                        value: '$totalOneOnOneCount',
                        unit: trByLang(langCode, ar: 'موعد أسبوعي', he: 'מפגש שבועי', en: 'Weekly slots'),
                        icon: Icons.record_voice_over_rounded,
                        accentColor: DarAlFajrTheme.accent,
                      ),
                      Builder(
                        builder: (context) {
                          final groups = ref.watch(adminGroupsProvider).value ?? [];
                          final enrollments = ref.watch(adminEnrollmentsProvider).value ?? [];
                          final totalCapacity = groups.fold<int>(0, (sum, g) => sum + g.capacity);
                          final openSeatsValue = (isDemoFallback && groups.isEmpty)
                              ? '18'
                              : '${(totalCapacity - enrollments.length).clamp(0, 9999)}';
                          return AdminStatSummaryCard(
                            width: (constraints.maxWidth - 48) / 4,
                            title: trByLang(langCode, ar: 'المقاعد المتاحة', he: 'מקומות פנויים', en: 'Available Seats'),
                            value: openSeatsValue,
                            unit: trByLang(langCode, ar: 'مقعد متاح', he: 'מקום פנוי', en: 'Open seats'),
                            icon: Icons.event_seat_rounded,
                            accentColor: const Color(0xFF3D4947),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Main Data Table Card
              Container(
                decoration: BoxDecoration(
                  color: DarAlFajrTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table Header Bar & Track Filters
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trByLang(
                                      langCode,
                                      ar: 'قائمة الطلاب المسجلين',
                                      he: 'רשימת תלמידים רשומים',
                                      en: 'Enrolled Students Roster',
                                    ),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    trByLang(
                                      langCode,
                                      ar: 'إدارة الجلسات الجماعية والفردية وتتبع المقاعد',
                                      he: 'ניהול מפגשים קבוצתיים ואישיים ומעקב מקומות',
                                      en: 'Manage group & 1-on-1 sessions and seat allocation',
                                    ),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6D7A77)),
                                  ),
                                ],
                              ),
                              Container(height: 24, width: 1, color: const Color(0xFFE6E8EA)),
                              AdminFilterChipButton(
                                label: trByLang(
                                  langCode,
                                  ar: 'الكل ($totalStudentsCount)',
                                  he: 'הכל ($totalStudentsCount)',
                                  en: 'All ($totalStudentsCount)',
                                ),
                                isSelected: selectedTrackFilter == null,
                                onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(null),
                              ),
                              AdminFilterChipButton(
                                label: trByLang(langCode, ar: 'مسار الحفظ', he: 'מסלול חיפז', en: 'Hifz'),
                                isSelected: selectedTrackFilter == CenterTrack.hifz,
                                onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.hifz),
                              ),
                              AdminFilterChipButton(
                                label: trByLang(langCode, ar: 'النورانية', he: 'נוראניה', en: 'Nouraniah'),
                                isSelected: selectedTrackFilter == CenterTrack.qaidahNouraniah,
                                onTap: () =>
                                    ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.qaidahNouraniah),
                              ),
                              AdminFilterChipButton(
                                label: trByLang(langCode, ar: 'التجويد', he: 'טג׳וויד', en: 'Tajweed'),
                                isSelected: selectedTrackFilter == CenterTrack.readingTajweed,
                                onTap: () =>
                                    ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.readingTajweed),
                              ),
                              AdminFilterChipButton(
                                label: trByLang(langCode, ar: 'التربوي', he: 'חינוכי', en: 'Tarbawi'),
                                isSelected: selectedTrackFilter == CenterTrack.tarbawi,
                                onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.tarbawi),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم تصدير ملف Excel بنجاح!'),
                                      backgroundColor: DarAlFajrTheme.primary,
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF2F4F6),
                                  foregroundColor: const Color(0xFF191C1E),
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.file_download_outlined, size: 16),
                                label: Text(trByLang(langCode, ar: 'تصدير Excel', he: 'ייצוא Excel', en: 'Export Excel')),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {},
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFF2F4F6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.filter_list_rounded, size: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Horizontal scroll wrapper for table
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final tableWidth = constraints.maxWidth > 860 ? constraints.maxWidth : 860.0;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: tableWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Roster Table Header
                                Container(
                                  color: const Color(0xFFF2F4F6),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          trByLang(
                                            langCode,
                                            ar: 'اسم الطالب والرقم',
                                            he: 'שם התלמיד ומספר',
                                            en: 'Student Name & ID',
                                          ),
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                color: const Color(0xFF6D7A77),
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          trByLang(
                                            langCode,
                                            ar: 'ولي الأمر والاتصال',
                                            he: 'הורה ויצירת קשר',
                                            en: 'Parent & Contact',
                                          ),
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                color: const Color(0xFF6D7A77),
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          trByLang(langCode, ar: 'المسار المعتمد', he: 'מסלול לימוד', en: 'Assigned Track'),
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                color: const Color(0xFF6D7A77),
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          trByLang(
                                            langCode,
                                            ar: 'مواعيد الحلقة الجماعية',
                                            he: 'לו״ז קבוצתי',
                                            en: 'Group Schedule',
                                          ),
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                color: const Color(0xFF6D7A77),
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          trByLang(
                                            langCode,
                                            ar: 'الموعد الفردي (1-on-1)',
                                            he: 'מועד אישי (1-on-1)',
                                            en: '1-on-1 Slot',
                                          ),
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                color: const Color(0xFF6D7A77),
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Text(
                                          trByLang(langCode, ar: 'الإجراءات', he: 'פעולות', en: 'Actions'),
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                color: const Color(0xFF6D7A77),
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Roster Table Rows
                                ...rosterRows.map((row) {
                                  final isSelectedInDrawer = row.id == selectedStudentId;
                                  return InkWell(
                                    onTap: () => onSelectStudentRow(row),
                                    child: Container(
                                      color: (row.isHighlighted || isSelectedInDrawer)
                                          ? DarAlFajrTheme.primary.withValues(alpha: 0.05)
                                          : Colors.transparent,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: (row.isHighlighted || isSelectedInDrawer)
                                                        ? DarAlFajrTheme.primary
                                                        : const Color(0xFFE6E8EA),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    row.initial,
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                          color: (row.isHighlighted || isSelectedInDrawer)
                                                              ? Colors.white
                                                              : const Color(0xFF191C1E),
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        row.fullName,
                                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                              fontWeight: FontWeight.bold,
                                                              color: const Color(0xFF191C1E),
                                                            ),
                                                      ),
                                                      Text(
                                                        row.code,
                                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                              color: (row.isHighlighted || isSelectedInDrawer)
                                                                  ? DarAlFajrTheme.primary
                                                                  : const Color(0xFF6D7A77),
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  row.parentName,
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                        color: const Color(0xFF191C1E),
                                                      ),
                                                ),
                                                Text(
                                                  row.parentEmail,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(color: const Color(0xFF6D7A77)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              children: row.trackBadges
                                                  .map(
                                                    (b) => Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: b.backgroundColor,
                                                        borderRadius: BorderRadius.circular(999),
                                                      ),
                                                      child: Text(
                                                        b.label,
                                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                              color: b.textColor,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              children: [
                                                const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF6D7A77)),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    row.groupSchedule,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(color: const Color(0xFF191C1E)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: row.oneOnOneSchedule != null
                                                ? Align(
                                                    alignment: AlignmentDirectional.centerStart,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: DarAlFajrTheme.accent.withValues(alpha: 0.16),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Icon(
                                                            Icons.stars_rounded,
                                                            size: 14,
                                                            color: Color(0xFF904D00),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Flexible(
                                                            child: Text(
                                                              row.oneOnOneSchedule!,
                                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                                    color: const Color(0xFF904D00),
                                                                    fontWeight: FontWeight.w600,
                                                                  ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Text(
                                                    '—',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium
                                                        ?.copyWith(color: const Color(0xFF6D7A77)),
                                                  ),
                                          ),
                                          SizedBox(
                                            width: 80,
                                            child: Center(
                                              child: IconButton(
                                                visualDensity: VisualDensity.compact,
                                                padding: const EdgeInsets.all(4),
                                                constraints: const BoxConstraints(),
                                                onPressed: row.isFromFirestore
                                                    ? () {
                                                        final liveStudents =
                                                            ref.read(adminStudentsProvider).value ??
                                                                const <StudentProfile>[];
                                                        final profile = liveStudents
                                                                .where((s) => s.id == row.id)
                                                                .firstOrNull ??
                                                            StudentProfile(
                                                              id: row.id,
                                                              fullName: row.fullName,
                                                              parentId: 'parent-default',
                                                              parentName: row.parentName,
                                                              email: row.parentEmail,
                                                            );
                                                        showAdminAddStudentOrUserDialog(
                                                          context,
                                                          ref,
                                                          langCode,
                                                          existingStudent: profile,
                                                        );
                                                      }
                                                    : () => onSelectStudentRow(row),
                                                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF3D4947)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Pagination Footer
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6D7A77)),
                              children: [
                                TextSpan(
                                  text: trByLang(langCode, ar: 'عرض ', he: 'מציג ', en: 'Showing '),
                                ),
                                TextSpan(
                                  text: '1 - ${rosterRows.length}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF191C1E)),
                                ),
                                TextSpan(
                                  text: trByLang(langCode, ar: ' من أصل ', he: ' מתוך ', en: ' of '),
                                ),
                                TextSpan(
                                  text: '$totalStudentsCount',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF191C1E)),
                                ),
                                TextSpan(
                                  text: trByLang(langCode, ar: ' طالب', he: ' תלמידים', en: ' students'),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AdminPaginationButton(label: '', icon: Icons.chevron_left_rounded, onTap: () {}),
                              const SizedBox(width: 4),
                              AdminPaginationButton(label: '1', isSelected: true, onTap: () {}),
                              const SizedBox(width: 4),
                              AdminPaginationButton(label: '2', onTap: () {}),
                              const SizedBox(width: 4),
                              AdminPaginationButton(label: '3', onTap: () {}),
                              const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('...')),
                              AdminPaginationButton(label: '42', onTap: () {}),
                              const SizedBox(width: 4),
                              AdminPaginationButton(label: '', icon: Icons.chevron_right_rounded, onTap: () {}),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
