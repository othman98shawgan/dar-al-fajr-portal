import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../../auth/models/app_user.dart';
import '../models/admin_models.dart';
import '../providers/admin_providers.dart';
import 'admin_dialogs.dart';

class AdminUsersTab extends ConsumerWidget {
  final String langCode;
  final List<AppUser> users;
  final VoidCallback onAddUserPressed;

  const AdminUsersTab({
    super.key,
    required this.langCode,
    required this.users,
    required this.onAddUserPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trByLang(
                    langCode,
                    ar: 'إدارة المستخدمين والأدوار',
                    he: 'ניהול משתמשים ותפקידים',
                    en: 'Users & Roles Management',
                  ),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  trByLang(
                    langCode,
                    ar: 'عرض حسابات المعلمين وأولياء الأمور والطلاب والمشرفين',
                    he: 'צפייה בחשבונות מורים, הורים, תלמידים ומנהלים',
                    en: 'View teacher, parent, student, and administrator accounts',
                  ),
                  style: const TextStyle(color: Color(0xFF6D7A77)),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: onAddUserPressed,
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: Text(
                trByLang(langCode, ar: '+ إضافة مستخدم جديد', he: '+ הוסף משתמש חדש', en: '+ Add User'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (users.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: DarAlFajrTheme.surface, borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                trByLang(
                  langCode,
                  ar: 'لا يوجد مستخدمون حالياً في قاعدة البيانات.',
                  he: 'אין משתמשים רשומים כרגע.',
                  en: 'No users found in the database.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6D7A77)),
              ),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final u = users[index];
                return ListTile(
                  onTap: () => showAdminUserProfileModal(context, ref, u, langCode),
                  leading: CircleAvatar(
                    backgroundColor: DarAlFajrTheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      u.fullName.isNotEmpty ? u.fullName[0] : 'U',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${u.email} • ${u.phoneNumber ?? "—"}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: u.role == UserRole.admin
                          ? Colors.purple.withValues(alpha: 0.15)
                          : (u.role == UserRole.teacher
                                ? DarAlFajrTheme.primary.withValues(alpha: 0.15)
                                : Colors.amber.withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      u.role.localizedName(langCode),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: u.role == UserRole.admin
                            ? Colors.purple
                            : (u.role == UserRole.teacher ? DarAlFajrTheme.primary : Colors.amber.shade900),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class AdminGroupsTab extends ConsumerWidget {
  final String langCode;
  final List<StudyGroup> groups;
  final List<Enrollment> enrollments;
  final bool isDemoFallback;
  final VoidCallback onCreateGroupPressed;

  const AdminGroupsTab({
    super.key,
    required this.langCode,
    required this.groups,
    required this.enrollments,
    required this.isDemoFallback,
    required this.onCreateGroupPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trByLang(
                    langCode,
                    ar: 'الحلقات والمجموعات التعليمية',
                    he: 'קבוצות לימוד',
                    en: 'Study Groups & Circles',
                  ),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  trByLang(
                    langCode,
                    ar: 'إدارة الحلقات عبر المسارات الأربعة وتعيين الشيوخ والمعلمين',
                    he: 'ניהול קבוצות בארבעת המסלולים ושיבוץ מורים',
                    en: 'Manage study groups across the four tracks and assign teachers',
                  ),
                  style: const TextStyle(color: Color(0xFF6D7A77)),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: onCreateGroupPressed,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: Text(
                trByLang(
                  langCode,
                  ar: '+ إنشاء حلقة جديدة',
                  he: '+ קבוצה חדשה',
                  en: '+ Create Group',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (groups.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: DarAlFajrTheme.surface, borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                trByLang(
                  langCode,
                  ar: 'لا توجد حلقات حالياً. اضغط على "+ إنشاء حلقة جديدة".',
                  he: 'אין קבוצות כרגע. לחץ על "+ קבוצה חדשה".',
                  en: 'No study groups yet. Click "+ Create Group".',
                ),
                style: const TextStyle(color: Color(0xFF6D7A77)),
              ),
            ),
          )
        else
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: groups.map((g) {
              final enrolledCount = enrollments.where((e) => e.groupId == g.id).length;
              return Container(
                width: 340,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DarAlFajrTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                color: DarAlFajrTheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                g.track.localizedName(langCode),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: DarAlFajrTheme.primaryDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4F2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '$enrolledCount / ${g.capacity} ${trByLang(langCode, ar: 'مقعد', he: 'מקומות', en: 'seats')}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3D4947),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => showAdminEditGroupDialog(
                                context,
                                ref,
                                langCode,
                                group: g,
                                isDemoFallback: isDemoFallback,
                              ),
                              tooltip: trByLang(langCode, ar: 'تعديل الحلقة', he: 'ערוך קבוצה', en: 'Edit Group'),
                              icon: const Icon(Icons.edit_outlined, size: 18, color: DarAlFajrTheme.primary),
                            ),
                            IconButton(
                              onPressed: () async {
                                final confirmed = await confirmAdminDelete(
                                  context,
                                  langCode: langCode,
                                  title: trByLang(langCode, ar: 'حذف الحلقة', he: 'מחיקת קבוצה', en: 'Delete Group'),
                                  message: trByLang(
                                    langCode,
                                    ar: 'هل تريد حذف حلقة "${g.name}"؟',
                                    he: 'למחוק את הקבוצה "${g.name}"?',
                                    en: 'Delete study group "${g.name}"?',
                                  ),
                                );
                                if (confirmed) {
                                  await ref.read(adminRepositoryProvider).deleteGroup(g.id);
                                }
                              },
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFF6D7A77)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(g.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_rounded, size: 16, color: Color(0xFF6D7A77)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            g.teacherName.isNotEmpty ? g.teacherName : (isDemoFallback ? 'الشيخ عبد الرحمن' : '—'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF6D7A77)),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            g.formatScheduleSummary(langCode, multiline: true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class AdminEnrollmentsTab extends ConsumerWidget {
  final String langCode;
  final List<Enrollment> enrollments;
  final VoidCallback onOpenEnrollDrawer;

  const AdminEnrollmentsTab({
    super.key,
    required this.langCode,
    required this.enrollments,
    required this.onOpenEnrollDrawer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trByLang(
                    langCode,
                    ar: 'التسجيل والمواعيد الفردية (1-on-1)',
                    he: 'רישום ולו״ז מפגשים אישיים',
                    en: 'Enrollments & 1-on-1 Slots',
                  ),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  trByLang(
                    langCode,
                    ar: 'تتبع مواعيد الحضور الفردية وجداول الحلقات لكل طالب',
                    he: 'מעקב אחר זמני הגעה אישיים וקבוצתיים לכל תלמיד',
                    en: 'Track individual arrival slots and circle schedules per student',
                  ),
                  style: const TextStyle(color: Color(0xFF6D7A77)),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: onOpenEnrollDrawer,
              icon: const Icon(Icons.group_add_rounded, size: 18),
              label: Text(
                trByLang(langCode, ar: '+ تسجيل جديد في حلقة', he: '+ רישום לקבוצה', en: '+ New Enrollment'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: enrollments.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      trByLang(langCode, ar: 'لا توجد تسجيلات حالياً.', he: 'אין רישומים כרגע.', en: 'No enrollments yet.'),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: enrollments.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final e = enrollments[idx];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.how_to_reg_rounded)),
                      title: Text(e.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${e.groupName} • ${e.groupArrivalTime ?? "—"}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (e.oneOnOneSlotTime != null)
                            Chip(avatar: const Icon(Icons.stars_rounded, size: 16), label: Text(e.oneOnOneSlotTime!))
                          else
                            Text(
                              trByLang(langCode, ar: 'بدون موعد فردي', he: 'ללא תור אישי', en: 'No 1-on-1 slot'),
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A77)),
                            ),
                          const SizedBox(width: 6),
                          IconButton(
                            onPressed: () async {
                              final confirmed = await confirmAdminDelete(
                                context,
                                langCode: langCode,
                                title: trByLang(langCode, ar: 'إلغاء التسجيل', he: 'הסרת רישום', en: 'Remove Enrollment'),
                                message: trByLang(
                                  langCode,
                                  ar: 'هل تريد إزالة "${e.studentName}" من "${e.groupName}"؟',
                                  he: 'להסיר את "${e.studentName}" מהקבוצה "${e.groupName}"?',
                                  en: 'Remove "${e.studentName}" from "${e.groupName}"?',
                                ),
                              );
                              if (confirmed) {
                                await ref.read(adminRepositoryProvider).deleteEnrollment(e.id);
                              }
                            },
                            tooltip: trByLang(langCode, ar: 'إلغاء التسجيل', he: 'הסר רישום', en: 'Remove Enrollment'),
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFF6D7A77)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
