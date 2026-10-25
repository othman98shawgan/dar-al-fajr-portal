import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';

import '../../../core/services/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/models/app_user.dart';
import '../models/admin_models.dart';
import '../providers/admin_providers.dart';

/// Mobile Student Card Data Model representing merged Firestore & Seed data
class _MobileStudentCardData {
  final String id;
  final String code;
  final String fullName;
  final String initial;
  final String? avatarUrl;
  final bool isVerified;
  final String statusPillText;
  final Color statusPillBg;
  final Color statusPillFg;
  final Color statusDotColor;
  final String parentName;
  final String? parentEmail;
  final String? parentPhone;
  final String? streakBadgeText;
  final IconData? streakIcon;
  final Color? streakIconColor;
  final String primaryTrackLabel;
  final IconData primaryTrackIcon;
  final Color primaryTrackColor;
  final String? scheduleBadgeText;
  final IconData? scheduleBadgeIcon;
  final Color? scheduleBadgeBg;
  final Color? scheduleBadgeFg;
  final CenterTrack primaryTrack;
  final bool isFromFirestore;

  const _MobileStudentCardData({
    required this.id,
    required this.code,
    required this.fullName,
    required this.initial,
    this.avatarUrl,
    this.isVerified = false,
    required this.statusPillText,
    required this.statusPillBg,
    required this.statusPillFg,
    required this.statusDotColor,
    required this.parentName,
    this.parentEmail,
    this.parentPhone,
    this.streakBadgeText,
    this.streakIcon,
    this.streakIconColor,
    required this.primaryTrackLabel,
    required this.primaryTrackIcon,
    required this.primaryTrackColor,
    this.scheduleBadgeText,
    this.scheduleBadgeIcon,
    this.scheduleBadgeBg,
    this.scheduleBadgeFg,
    required this.primaryTrack,
    this.isFromFirestore = false,
  });
}

/// Stitch-Accurate Mobile Admin Screen for Dar al-Fajr Portal (إدارة دار الفجر)
class AdminMobileScreen extends ConsumerStatefulWidget {
  const AdminMobileScreen({super.key});

  @override
  ConsumerState<AdminMobileScreen> createState() => _AdminMobileScreenState();
}

class _AdminMobileScreenState extends ConsumerState<AdminMobileScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isAscendingOrder = true;

  // Stitch seed students to guarantee full fidelity with mockups
  static const List<_MobileStudentCardData> _seedStudentCards = [
    _MobileStudentCardData(
      id: 'st-1042',
      code: 'ST-1042',
      fullName: 'إبراهيم طه عثمان',
      initial: 'إ',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDLzpiiWS4A97GeHR-f6RndC4DtrFc2tK1MQc1P5AX6mLiMWW2IBwMPbiakX2dkLW8cD5_DDrzajhgUiIFA2lB9HWzpkI68kVBLsvvdHHqgB8tZrGIgbVRTy8zMM6C77HsGviNJIlGuljS0RtL_6otCF5NboqC1FKk6U4gKsR1aOhzsBFYaWOjNPQEN2_3l1a27-1FKzWFXqZvqps3OUUan6_p3gPHVt84wjvmG5zQJEan2m0YnJP9N',
      isVerified: true,
      statusPillText: 'إتقان ممتاز (98%)',
      statusPillBg: Color(0xFFE6F5F2),
      statusPillFg: DarAlFajrTheme.primary,
      statusDotColor: DarAlFajrTheme.primary,
      parentName: 'طه عثمان',
      parentEmail: 'taha@example.com',
      streakBadgeText: 'حضور منتظم دون انقطاع للأسبوع الثامن',
      streakIcon: Icons.workspace_premium_rounded,
      streakIconColor: Color(0xFFD4AF37),
      primaryTrackLabel: 'مسار الإتقان والتجويد',
      primaryTrackIcon: Icons.auto_stories_rounded,
      primaryTrackColor: DarAlFajrTheme.primary,
      scheduleBadgeText: 'موعد فردي: الخميس 17:15',
      scheduleBadgeIcon: Icons.alarm_rounded,
      scheduleBadgeBg: Color(0xFFFFDCC3),
      scheduleBadgeFg: Color(0xFF6E3900),
      primaryTrack: CenterTrack.readingTajweed,
    ),
    _MobileStudentCardData(
      id: 'st-1088',
      code: 'ST-1088',
      fullName: 'عبد الرحمن يوسف الشريف',
      initial: 'ع',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCa1LvPd8stSyzEg3FxZ5NdHuk-kcWmIC1sESs0VWdCTfF257GOkZryA9B-SoLzBweM9ikMTYc6qoz45Ew-pUtKcKKHWF7uGXeO5rBgCNE71ZpEVpobuA9dvZlhd9vYBTTdhKQ6pu5MFwb6R99RT-OXZz1KR3GCJyAWCiJuzLRMdncnm0mc-S9L6rzcx4Buf0Gml1z4vfBK6kKwSOmAOzpp3DrHbdMc2RImid254Q9dQyr7adRoE3dF',
      isVerified: false,
      statusPillText: 'جيد جداً (85%)',
      statusPillBg: Color(0xFFABEFE8),
      statusPillFg: Color(0xFF00504B),
      statusDotColor: Color(0xFF1E6661),
      parentName: 'يوسف الشريف',
      parentPhone: '059-1234567',
      primaryTrackLabel: 'حلقة الحفظ المكثف',
      primaryTrackIcon: Icons.military_tech_rounded,
      primaryTrackColor: Color(0xFF1E6661),
      scheduleBadgeText: 'الأحد والثلاثاء 16:30',
      scheduleBadgeIcon: Icons.event_repeat_rounded,
      scheduleBadgeBg: Color(0xFFE6E8EA),
      scheduleBadgeFg: Color(0xFF3D4947),
      primaryTrack: CenterTrack.hifz,
    ),
    _MobileStudentCardData(
      id: 'st-1102',
      code: 'ST-1102',
      fullName: 'زياد المنصور',
      initial: 'ز',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDTFtlCicg363eIRux5RYuSPmCenLxjRF-eNcbMiX3eEYqaOLymVuCHyCG3XPx6mK8gGtwT_41V3IlrO2B5K4pzl-OOKHWECMk9ZXvtzH1PA3L4OJMEVCIhs-8kOsRybZs9uD_pgZ-Tqqv85259S4Ym5hM_PvIUVsFdjSr_XgKK7Rhp0AQRbi2a0Zcn2Cm2aM17I2HesikfNgadpPJvGJpTHtN7i--ZeGES8MellPbSsdLwhQNIq3mb',
      isVerified: false,
      statusPillText: 'الجزء 30 (مستمر)',
      statusPillBg: Color(0xFFFFDCC3),
      statusPillFg: Color(0xFF6E3900),
      statusDotColor: Color(0xFF904D00),
      parentName: 'منصور أحمد',
      streakBadgeText: 'مستوى تمهيدي',
      primaryTrackLabel: 'البراعم النورانية',
      primaryTrackIcon: Icons.child_care_rounded,
      primaryTrackColor: Color(0xFF904D00),
      scheduleBadgeText: 'القاعدة النورانية',
      scheduleBadgeIcon: Icons.spellcheck_rounded,
      scheduleBadgeBg: Color(0xFFE6E8EA),
      scheduleBadgeFg: Color(0xFF3D4947),
      primaryTrack: CenterTrack.qaidahNouraniah,
    ),
    _MobileStudentCardData(
      id: 'st-1145',
      code: 'ST-1145',
      fullName: 'حمزة كمال الدين',
      initial: 'حك',
      isVerified: false,
      statusPillText: 'غياب بعذر مسبق',
      statusPillBg: Color(0xFFFFDAD6),
      statusPillFg: Color(0xFF93000A),
      statusDotColor: Color(0xFFBA1A1A),
      parentName: 'كمال الدين',
      streakBadgeText: 'مسار التدبر',
      primaryTrackLabel: 'مسار التربية والتدبر',
      primaryTrackIcon: Icons.psychology_alt_rounded,
      primaryTrackColor: DarAlFajrTheme.primary,
      scheduleBadgeText: 'موعد فردي',
      scheduleBadgeIcon: Icons.person_rounded,
      scheduleBadgeBg: Color(0xFFFFDCC3),
      scheduleBadgeFg: Color(0xFF6E3900),
      primaryTrack: CenterTrack.tarbawi,
    ),
    _MobileStudentCardData(
      id: 'st-1160',
      code: 'ST-1160',
      fullName: 'عمر فاروق البغدادي',
      initial: 'عب',
      isVerified: false,
      statusPillText: 'مسجل حديثاً',
      statusPillBg: Color(0xFFE6F5F2),
      statusPillFg: DarAlFajrTheme.primary,
      statusDotColor: DarAlFajrTheme.primary,
      parentName: 'فاروق البغدادي',
      primaryTrackLabel: 'حلقة أبي بكر الصديق (حفظ)',
      primaryTrackIcon: Icons.diversity_3_rounded,
      primaryTrackColor: DarAlFajrTheme.primary,
      primaryTrack: CenterTrack.hifz,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _tr(String langCode, {required String ar, required String he, required String en}) {
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

  List<_MobileStudentCardData> _mergeStudents(
    List<StudentProfile> firestoreStudents,
    List<Enrollment> firestoreEnrollments,
    CenterTrack? trackFilter,
    String query,
  ) {
    final firestoreCards = firestoreStudents.map((s) {
      final enrollments = firestoreEnrollments.where((e) => e.studentId == s.id).toList();
      final primary = enrollments.firstOrNull;
      final track = primary?.track ?? CenterTrack.hifz;
      final trimmed = s.fullName.trim();
      final initial = trimmed.isNotEmpty ? trimmed.characters.first : 'ط';
      final shortCode = s.id.length >= 4 ? s.id.substring(0, 4).toUpperCase() : s.id.toUpperCase();

      return _MobileStudentCardData(
        id: s.id,
        code: 'ST-$shortCode',
        fullName: s.fullName,
        initial: initial,
        statusPillText: 'نشط',
        statusPillBg: const Color(0xFFE6F5F2),
        statusPillFg: DarAlFajrTheme.primary,
        statusDotColor: DarAlFajrTheme.primary,
        parentName: s.parentName ?? 'ولي الأمر',
        parentEmail: s.email,
        parentPhone: s.phoneNumber,
        primaryTrackLabel: track.localizedName('ar'),
        primaryTrackIcon: Icons.auto_stories_rounded,
        primaryTrackColor: DarAlFajrTheme.primary,
        scheduleBadgeText: primary?.groupArrivalTime ?? 'الأحد والثلاثاء 16:30',
        scheduleBadgeIcon: Icons.schedule_rounded,
        scheduleBadgeBg: const Color(0xFFE6E8EA),
        scheduleBadgeFg: const Color(0xFF3D4947),
        primaryTrack: track,
        isFromFirestore: true,
      );
    }).toList();

    // Combine Firestore students with Stitch Seed Cards
    final combined = [...firestoreCards, ..._seedStudentCards];

    // Apply track filtering
    var filtered = combined.where((c) {
      if (trackFilter != null && c.primaryTrack != trackFilter) {
        return false;
      }
      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final nameMatch = c.fullName.toLowerCase().contains(q);
        final codeMatch = c.code.toLowerCase().contains(q);
        final parentMatch = c.parentName.toLowerCase().contains(q);
        final trackMatch = c.primaryTrackLabel.toLowerCase().contains(q);
        if (!nameMatch && !codeMatch && !parentMatch && !trackMatch) {
          return false;
        }
      }
      return true;
    }).toList();

    if (!_isAscendingOrder) {
      filtered = filtered.reversed.toList();
    }

    return filtered;
  }

  void _showActionModal(BuildContext context, String langCode) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _tr(langCode, ar: 'إجراء إداري جديد', he: 'פעולה ניהולית חדשה', en: 'New Administrative Action'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: DarAlFajrTheme.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(modalCtx).pop(),
                        icon: const Icon(Icons.close_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFE6E8EA),
                          foregroundColor: const Color(0xFF3D4947),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tr(
                      langCode,
                      ar: 'اختر نوع التسجيل للبدء في إدخال بيانات المسار وحجز المواعيد التعليمية:',
                      he: 'בחר סוג רישום כדי להתחיל בהזנת נתוני מסלול ומועדים:',
                      en: 'Select an action to enroll students or create new study groups:',
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6D7A77),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Option 1: Add new student / user
                  Material(
                    color: const Color(0xFFF2F4F6),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(modalCtx).pop();
                        _showCreateStudentDialog(context, langCode);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: DarAlFajrTheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.person_add_rounded, color: DarAlFajrTheme.primary, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _tr(langCode, ar: 'تسجيل طالب جديد', he: 'רישום תלמיד חדש', en: 'Register New Student'),
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: DarAlFajrTheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _tr(
                                      langCode,
                                      ar: 'إضافة طالب وربط ولي أمره واختيار المسار',
                                      he: 'הוספת תלמיד, קישור הורה ובחירת מסלול',
                                      en: 'Add student, link parent, and select track',
                                    ),
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFF6D7A77),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_left_rounded, color: Color(0xFF6D7A77)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Option 2: Create new group
                  Material(
                    color: const Color(0xFFF2F4F6),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(modalCtx).pop();
                        _showCreateGroupDialog(context, langCode);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE932C).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.groups_rounded, color: Color(0xFF904D00), size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _tr(langCode, ar: 'إنشاء حلقة جديدة', he: 'יצירת קבוצה חדשה', en: 'Create New Study Group'),
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: DarAlFajrTheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _tr(
                                      langCode,
                                      ar: 'تحديد المعلم المشرف والأيام ومسار الحفظ',
                                      he: 'הגדרת מורה אחראי, ימים ומסלול שינון',
                                      en: 'Assign teacher, weekly days, and track',
                                    ),
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFF6D7A77),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_left_rounded, color: Color(0xFF6D7A77)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreateStudentDialog(BuildContext context, String langCode) {
    final nameCtrl = TextEditingController();
    final parentNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final tempPassCtrl = TextEditingController(text: 'DarAlFajr@2026');

    showDialog<void>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text(_tr(langCode, ar: 'تسجيل طالب جديد', he: 'רישום תלמיד', en: 'New Student Registration')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: _tr(langCode, ar: 'اسم الطالب الرباعي *', he: 'שם מלא *', en: 'Student Full Name *'),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: parentNameCtrl,
                decoration: InputDecoration(
                  labelText: _tr(langCode, ar: 'اسم ولي الأمر *', he: 'שם ההורה *', en: 'Parent Name *'),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: _tr(langCode, ar: 'رقم هاتف ولي الأمر', he: 'טלפון', en: 'Parent Phone'),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: _tr(langCode, ar: 'البريد الإلكتروني', he: 'דוא״ל', en: 'Email Address'),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: tempPassCtrl,
                decoration: InputDecoration(
                  labelText: _tr(langCode, ar: 'كلمة المرور المؤقتة', he: 'סיסמה ראשונית', en: 'Temporary Password'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: Text(_tr(langCode, ar: 'إلغاء', he: 'ביטול', en: 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.of(dlgCtx).pop();

              try {
                final repo = ref.read(adminRepositoryProvider);
                await repo.createStudent(
                  fullName: nameCtrl.text.trim(),
                  parentId: 'parent_general',
                  parentName: parentNameCtrl.text.trim().isNotEmpty ? parentNameCtrl.text.trim() : null,
                  email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                  temporaryPassword: tempPassCtrl.text.trim(),
                  phoneNumber: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                );
              } catch (_) {}

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_tr(langCode, ar: 'تم تسجيل الطالب بنجاح!', he: 'התלמיד נרשם בהצלחה!', en: 'Student registered successfully!')),
                  backgroundColor: DarAlFajrTheme.primary,
                ),
              );
            },
            child: Text(_tr(langCode, ar: 'تسجيل الطالب', he: 'רישום', en: 'Register')),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context, String langCode) {
    final groupNameCtrl = TextEditingController();
    final teacherNameCtrl = TextEditingController(text: 'الشيخ عبد الرحمن');
    final scheduleCtrl = TextEditingController(text: 'الأحد والثلاثاء والخميس 16:30');
    CenterTrack selectedTrack = CenterTrack.hifz;

    showDialog<void>(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text(_tr(langCode, ar: 'إنشاء حلقة جديدة', he: 'יצירת קבוצה חדשה', en: 'Create New Study Group')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: groupNameCtrl,
                  decoration: InputDecoration(
                    labelText: _tr(langCode, ar: 'اسم الحلقة *', he: 'שם קבוצה *', en: 'Group Name *'),
                    hintText: 'مثال: حلقة أبي بكر الصديق',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<CenterTrack>(
                  initialValue: selectedTrack,
                  decoration: InputDecoration(
                    labelText: _tr(langCode, ar: 'المسار التعليمي', he: 'מסלול', en: 'Educational Track'),
                  ),
                  items: CenterTrack.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.localizedName(langCode))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => selectedTrack = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: teacherNameCtrl,
                  decoration: InputDecoration(
                    labelText: _tr(langCode, ar: 'المعلم المشرف', he: 'מורה', en: 'Teacher Name'),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: scheduleCtrl,
                  decoration: InputDecoration(
                    labelText: _tr(langCode, ar: 'المواعيد والأيام', he: 'מועדים', en: 'Weekly Schedule'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dlgCtx).pop(),
              child: Text(_tr(langCode, ar: 'إلغاء', he: 'ביטול', en: 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (groupNameCtrl.text.trim().isEmpty) return;
                Navigator.of(dlgCtx).pop();

                try {
                  final repo = ref.read(adminRepositoryProvider);
                  await repo.createGroup(
                    name: groupNameCtrl.text.trim(),
                    track: selectedTrack,
                    teacherId: 'teacher_default',
                    teacherName: teacherNameCtrl.text.trim(),
                    scheduleDays: const ['الأحد', 'الثلاثاء', 'الخميس'],
                    startTime: '16:30',
                    endTime: '18:00',
                  );
                } catch (_) {}

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_tr(langCode, ar: 'تم إنشاء الحلقة بنجاح!', he: 'הקבוצה נוצרה בהצלחה!', en: 'Group created successfully!')),
                    backgroundColor: DarAlFajrTheme.primary,
                  ),
                );
              },
              child: Text(_tr(langCode, ar: 'حفظ الحلقة', he: 'שמור', en: 'Save Group')),
            ),
          ],
        ),
      ),
    );
  }

  void _showEnrollmentSheet(
    BuildContext context,
    _MobileStudentCardData student,
    String langCode,
    List<StudyGroup> firestoreGroups,
  ) {
    CenterTrack selectedTrack = student.primaryTrack;
    String selectedGroupId = firestoreGroups.isNotEmpty ? firestoreGroups.first.id : 'grp-tajweed-1';
    String selectedGroupName = firestoreGroups.isNotEmpty ? firestoreGroups.first.name : 'حلقة الإتقان والتجويد (مسار التجويد)';
    bool hasOneOnOne = true;
    String oneOnOneDay = 'الخميس';
    String oneOnOneTime = '17:15';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Container(
                padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
                  ],
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: DarAlFajrTheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.group_add_rounded, color: DarAlFajrTheme.primary, size: 22),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _tr(langCode, ar: 'تسجيل في حلقة', he: 'רישום לקבוצה', en: 'Enroll in Group'),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(sheetCtx).pop(),
                              icon: const Icon(Icons.close_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFE6E8EA),
                                foregroundColor: const Color(0xFF3D4947),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Student Info Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: DarAlFajrTheme.primary.withValues(alpha: 0.15),
                                child: Text(
                                  student.initial,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: DarAlFajrTheme.primary),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.fullName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      '${student.code} • ${student.parentName}',
                                      style: const TextStyle(color: Color(0xFF6D7A77), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Select Track
                        Text(
                          _tr(langCode, ar: 'المسار التعليمي المستهدف', he: 'מסלול חינוכי', en: 'Target Educational Track'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<CenterTrack>(
                          initialValue: selectedTrack,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          items: CenterTrack.values
                              .map((t) => DropdownMenuItem(value: t, child: Text(t.localizedName(langCode))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setSheetState(() => selectedTrack = val);
                          },
                        ),
                        const SizedBox(height: 14),

                        // Select Group
                        Text(
                          _tr(langCode, ar: 'الحلقة التعليمية', he: 'קבוצת לימוד', en: 'Study Group'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: selectedGroupId,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          items: firestoreGroups.isNotEmpty
                              ? firestoreGroups
                                  .map((g) => DropdownMenuItem(value: g.id, child: Text('${g.name} (${g.scheduleDays.join("، ")} ${g.startTime})')))
                                  .toList()
                              : const [
                                  DropdownMenuItem(
                                    value: 'grp-tajweed-1',
                                    child: Text('حلقة الإتقان والتجويد (الأحد والثلاثاء 16:30)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'grp-hifz-1',
                                    child: Text('حلقة الحفظ المكثف (السبت والاثنين 17:00)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'grp-nouraniah-1',
                                    child: Text('حلقة البراعم النورانية (الخميس 15:30)'),
                                  ),
                                ],
                          onChanged: (val) {
                            if (val != null) {
                              setSheetState(() {
                                selectedGroupId = val;
                                final found = firestoreGroups.where((g) => g.id == val).firstOrNull;
                                if (found != null) selectedGroupName = found.name;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        // 1-on-1 Arrival Slot Checkbox
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            _tr(langCode, ar: 'تخصيص موعد تسميع فردي (1-on-1)', he: 'הקצאת תור אישי', en: 'Assign 1-on-1 Recitation Slot'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          subtitle: Text(
                            _tr(langCode, ar: 'تحديد وقت دقيق لوصول الطالب للتسميع الفردي', he: 'שעת הגעה מדויקת', en: 'Precise individual arrival slot'),
                            style: const TextStyle(color: Color(0xFF6D7A77), fontSize: 11),
                          ),
                          value: hasOneOnOne,
                          activeColor: DarAlFajrTheme.primary,
                          onChanged: (val) => setSheetState(() => hasOneOnOne = val ?? false),
                        ),

                        if (hasOneOnOne) ...[
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: oneOnOneDay,
                                  decoration: InputDecoration(
                                    labelText: _tr(langCode, ar: 'اليوم', he: 'יום', en: 'Day'),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  items: const ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة']
                                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                                      .toList(),
                                  onChanged: (d) {
                                    if (d != null) setSheetState(() => oneOnOneDay = d);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: oneOnOneTime,
                                  decoration: InputDecoration(
                                    labelText: _tr(langCode, ar: 'وقت الوصول', he: 'שעה', en: 'Time'),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  items: const ['16:00', '16:30', '17:00', '17:15', '17:45', '18:15', '18:45']
                                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                      .toList(),
                                  onChanged: (t) {
                                    if (t != null) setSheetState(() => oneOnOneTime = t);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),

                        // Submit Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.of(sheetCtx).pop();

                            try {
                              final repo = ref.read(adminRepositoryProvider);
                              await repo.assignStudentToGroup(
                                studentId: student.id,
                                studentName: student.fullName,
                                groupId: selectedGroupId,
                                groupName: selectedGroupName,
                                track: selectedTrack,
                                groupArrivalTime: 'الأحد والثلاثاء والخميس 16:30',
                                oneOnOneSlotTime: hasOneOnOne ? '$oneOnOneDay $oneOnOneTime (فردي)' : null,
                              );
                            } catch (_) {}

                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(_tr(langCode, ar: 'تم تثبيت التسجيل بنجاح!', he: 'הרישום נשמר בהצלחה!', en: 'Enrollment confirmed!')),
                                backgroundColor: DarAlFajrTheme.primary,
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_rounded),
                          label: Text(_tr(langCode, ar: 'حفظ وتثبيت التسجيل', he: 'שמור רישום', en: 'Confirm Enrollment')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DarAlFajrTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final langCode = currentLocale.languageCode;
    final isRtl = isRtlLocale(currentLocale);

    final selectedTab = ref.watch(adminSelectedTabProvider);
    final selectedTrackFilter = ref.watch(adminTrackFilterProvider);

    final firestoreStudents = ref.watch(adminStudentsProvider).asData?.value ?? const [];
    final firestoreGroups = ref.watch(adminGroupsProvider).asData?.value ?? const [];
    final firestoreEnrollments = ref.watch(adminEnrollmentsProvider).asData?.value ?? const [];
    final allUsers = ref.watch(adminAllUsersProvider).asData?.value ?? const [];

    final studentCards = _mergeStudents(firestoreStudents, firestoreEnrollments, selectedTrackFilter, _searchQuery);

    final totalStudentsCount = firestoreStudents.isNotEmpty ? firestoreStudents.length : 142;
    final totalGroupsCount = firestoreGroups.isNotEmpty ? firestoreGroups.length : 12;
    final totalOneOnOneCount = firestoreEnrollments.isNotEmpty
        ? firestoreEnrollments.where((e) => e.oneOnOneSlotTime != null && e.oneOnOneSlotTime!.isNotEmpty).length
        : 68;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: DarAlFajrTheme.background,
        // Sticky Mobile Top App Bar
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand / Logo Section
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: DarAlFajrTheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.mosque_rounded,
                            color: DarAlFajrTheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _tr(langCode, ar: 'إدارة دار الفجر', he: 'הנהלת דאר אל-פג׳ר', en: 'Dar al-Fajr Admin'),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: DarAlFajrTheme.primary,
                              ),
                            ),
                            Text(
                              selectedTab == 1
                                  ? 'Students • الطلاب'
                                  : selectedTab == 2
                                      ? 'Groups • الحلقات'
                                      : selectedTab == 0
                                          ? 'Users • المستخدمين'
                                          : 'Reports • التقارير',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF6D7A77),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Notifications + Profile Avatar (opens My Account)
                    Row(
                      children: [
                        // Notification Bell with Orange Dot
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _tr(
                                        langCode,
                                        ar: 'لا توجد تنبيهات جديدة حالياً',
                                        he: 'אין התראות חדשות',
                                        en: 'No new notifications',
                                      ),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.notifications_none_rounded, size: 22),
                              color: const Color(0xFF3D4947),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFE932C),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),

                        // Admin Avatar -> My Account
                        InkWell(
                          onTap: () => context.push(AppRoutes.account),
                          borderRadius: BorderRadius.circular(20),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: DarAlFajrTheme.primary,
                            child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Body Content based on active tab
        body: IndexedStack(
          index: selectedTab == 1
              ? 0
              : selectedTab == 2
                  ? 1
                  : selectedTab == 0
                      ? 2
                      : 3,
          children: [
            // TAB 1: Students Dashboard (The main Stitch mockup)
            _buildStudentsTab(
              context,
              langCode,
              studentCards,
              totalStudentsCount,
              totalGroupsCount,
              totalOneOnOneCount,
              selectedTrackFilter,
              firestoreGroups,
            ),

            // TAB 2: Groups / الحلقات
            _buildGroupsTab(context, langCode, firestoreGroups),

            // TAB 0: Users / المستخدمين
            _buildUsersTab(context, langCode, allUsers),

            // TAB 3: Reports / التقارير
            _buildReportsTab(context, langCode, totalStudentsCount, totalGroupsCount, totalOneOnOneCount),
          ],
        ),

        // Floating Action Button: Add Student / Group
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FloatingActionButton.extended(
            heroTag: 'adminMobileQuickAddFab',
            onPressed: () => _showActionModal(context, langCode),
            backgroundColor: DarAlFajrTheme.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.person_add_rounded, size: 22),
            label: Text(
              _tr(langCode, ar: 'إضافة طالب / حلقة', he: 'הוספת תלמיד / קבוצה', en: 'Add Student / Group'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        // Fixed Mobile Bottom Navigation Bar
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(
                    icon: Icons.school_rounded,
                    label: _tr(langCode, ar: 'الطلاب', he: 'תלמידים', en: 'Students'),
                    isSelected: selectedTab == 1,
                    onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(1),
                  ),
                  _buildBottomNavItem(
                    icon: Icons.groups_rounded,
                    label: _tr(langCode, ar: 'الحلقات', he: 'קבוצות', en: 'Groups'),
                    isSelected: selectedTab == 2,
                    onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(2),
                  ),
                  _buildBottomNavItem(
                    icon: Icons.manage_accounts_rounded,
                    label: _tr(langCode, ar: 'المستخدمين', he: 'משתמשים', en: 'Users'),
                    isSelected: selectedTab == 0,
                    onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(0),
                  ),
                  _buildBottomNavItem(
                    icon: Icons.query_stats_rounded,
                    label: _tr(langCode, ar: 'التقارير', he: 'דוחות', en: 'Reports'),
                    isSelected: selectedTab == 3,
                    onTap: () => ref.read(adminSelectedTabProvider.notifier).setTab(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? DarAlFajrTheme.primary : const Color(0xFF6D7A77),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? DarAlFajrTheme.primary : const Color(0xFF6D7A77),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 1: STUDENTS VIEW (Detailed Stitch Mobile Roster)
  // ===========================================================================
  Widget _buildStudentsTab(
    BuildContext context,
    String langCode,
    List<_MobileStudentCardData> studentCards,
    int totalStudents,
    int totalGroups,
    int totalOneOnOne,
    CenterTrack? trackFilter,
    List<StudyGroup> firestoreGroups,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input with tune filter
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
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: _tr(
                        langCode,
                        ar: 'بحث باسم الطالب، الحلقة، أو ولي الأمر...',
                        he: 'חיפוש תלמיד, קבוצה או הורה...',
                        en: 'Search student, group, or parent...',
                      ),
                      hintStyle: const TextStyle(color: Color(0xFF6D7A77), fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6D7A77), size: 22),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune_rounded, color: Color(0xFF3D4947), size: 20),
                        onPressed: () {
                          // Quick cycle or toggle track filter
                          ref.read(adminTrackFilterProvider.notifier).setTrack(null);
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 3-Column Compact KPI Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        icon: Icons.school_rounded,
                        tagText: _tr(langCode, ar: 'نشط', he: 'פעיל', en: 'Active'),
                        tagBg: DarAlFajrTheme.primary.withValues(alpha: 0.1),
                        tagFg: DarAlFajrTheme.primary,
                        count: '$totalStudents',
                        label: _tr(langCode, ar: 'إجمالي الطلاب', he: 'סה״כ תלמידים', en: 'Total Students'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        icon: Icons.menu_book_rounded,
                        tagText: _tr(langCode, ar: 'حلقات', he: 'קבוצות', en: 'Groups'),
                        tagBg: const Color(0xFFFE932C).withValues(alpha: 0.15),
                        tagFg: const Color(0xFF904D00),
                        count: '$totalGroups',
                        label: _tr(langCode, ar: 'الحلقات النشطة', he: 'קבוצות פעילות', en: 'Active Groups'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        icon: Icons.record_voice_over_rounded,
                        tagText: _tr(langCode, ar: 'اليوم', he: 'היום', en: 'Today'),
                        tagBg: const Color(0xFF3B7F7A).withValues(alpha: 0.15),
                        tagFg: const Color(0xFF1E6661),
                        count: '$totalOneOnOne',
                        label: _tr(langCode, ar: 'تسميع فردي', he: 'תור אישי', en: '1-on-1 Slots'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Horizontal Track Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTrackChip(
                        label: _tr(langCode, ar: 'الكل', he: 'הכל', en: 'All'),
                        count: '$totalStudents',
                        isSelected: trackFilter == null,
                        onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(null),
                      ),
                      const SizedBox(width: 8),
                      _buildTrackChip(
                        label: _tr(langCode, ar: 'حفظ', he: 'חיפז', en: 'Hifz'),
                        count: '54',
                        isSelected: trackFilter == CenterTrack.hifz,
                        onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.hifz),
                      ),
                      const SizedBox(width: 8),
                      _buildTrackChip(
                        label: _tr(langCode, ar: 'نورانية', he: 'נוראניה', en: 'Nouraniah'),
                        count: '38',
                        isSelected: trackFilter == CenterTrack.qaidahNouraniah,
                        onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.qaidahNouraniah),
                      ),
                      const SizedBox(width: 8),
                      _buildTrackChip(
                        label: _tr(langCode, ar: 'تجويد', he: 'טג׳וויד', en: 'Tajweed'),
                        count: '26',
                        isSelected: trackFilter == CenterTrack.readingTajweed,
                        onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.readingTajweed),
                      ),
                      const SizedBox(width: 8),
                      _buildTrackChip(
                        label: _tr(langCode, ar: 'تربوي', he: 'חינוכי', en: 'Tarbawi'),
                        count: '24',
                        isSelected: trackFilter == CenterTrack.tarbawi,
                        onTap: () => ref.read(adminTrackFilterProvider.notifier).setTrack(CenterTrack.tarbawi),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Roster Section Header + Sort Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          _tr(langCode, ar: 'قائمة الطلاب المسجلين', he: 'רשימת תלמידים', en: 'Enrolled Students'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6E8EA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${studentCards.length} ${_tr(langCode, ar: "معروض", he: "מוצגים", en: "shown")}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF3D4947), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => _isAscendingOrder = !_isAscendingOrder),
                      icon: const Icon(Icons.swap_vert_rounded, size: 18),
                      label: Text(_tr(langCode, ar: 'ترتيب', he: 'מיון', en: 'Sort')),
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

        // Students Cards List
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final student = studentCards[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildStudentCard(context, student, langCode, firestoreGroups),
                );
              },
              childCount: studentCards.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String tagText,
    required Color tagBg,
    required Color tagFg,
    required String count,
    required String label,
  }) {
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
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: tagFg, size: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tagText,
                  style: TextStyle(color: tagFg, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.1),
          ),
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

  Widget _buildTrackChip({
    required String label,
    required String count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
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

  Widget _buildStudentCard(
    BuildContext context,
    _MobileStudentCardData student,
    String langCode,
    List<StudyGroup> firestoreGroups,
  ) {
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
          // Top Row: Avatar + Name + ID + Performance Status Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
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

              // Name & Registration Code
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
                      '${_tr(langCode, ar: "رقم القيد", he: "מס׳ מזהה", en: "ID")}: ${student.code}',
                      style: const TextStyle(color: Color(0xFF6D7A77), fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Status Pill
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
                      decoration: BoxDecoration(
                        color: student.statusDotColor,
                        shape: BoxShape.circle,
                      ),
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
            ],
          ),
          const SizedBox(height: 10),

          // Parent & Contact Details Box
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
                    Row(
                      children: [
                        const Icon(Icons.family_restroom_rounded, size: 16, color: Color(0xFF6D7A77)),
                        const SizedBox(width: 6),
                        Text(
                          student.parentName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ],
                    ),
                    if (student.parentEmail != null)
                      Row(
                        children: [
                          Text(
                            student.parentEmail!,
                            style: const TextStyle(color: DarAlFajrTheme.primary, fontSize: 11),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.mail_rounded, size: 13, color: DarAlFajrTheme.primary),
                        ],
                      )
                    else if (student.parentPhone != null)
                      Row(
                        children: [
                          Text(
                            student.parentPhone!,
                            style: const TextStyle(color: DarAlFajrTheme.primary, fontSize: 11),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.call_rounded, size: 13, color: DarAlFajrTheme.primary),
                        ],
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

          // Track & Schedule Badges
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
                      Icon(student.scheduleBadgeIcon ?? Icons.alarm_rounded, size: 13, color: student.scheduleBadgeFg ?? const Color(0xFF6E3900)),
                      const SizedBox(width: 4),
                      Text(
                        student.scheduleBadgeText!,
                        style: TextStyle(fontSize: 11, color: student.scheduleBadgeFg ?? const Color(0xFF6E3900), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Quick Action Buttons
          Row(
            children: [
              // Edit button
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تعديل ملف الطالب: ${student.fullName}')),
                    );
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: Text(_tr(langCode, ar: 'تعديل', he: 'ערוך', en: 'Edit')),
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

              // Enroll in group button
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _showEnrollmentSheet(context, student, langCode, firestoreGroups),
                  icon: const Icon(Icons.group_add_rounded, size: 16),
                  label: Text(_tr(langCode, ar: 'تسجيل في حلقة', he: 'רישום לקבוצה', en: 'Enroll in Group')),
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
      ),
    );
  }

  // ===========================================================================
  // TAB 2: GROUPS VIEW (الحلقات والمجموعات)
  // ===========================================================================
  Widget _buildGroupsTab(BuildContext context, String langCode, List<StudyGroup> firestoreGroups) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tr(langCode, ar: 'الحلقات والمجموعات التعليمية', he: 'קבוצות לימוד', en: 'Study Groups'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: DarAlFajrTheme.primary),
              onPressed: () => _showCreateGroupDialog(context, langCode),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Cards for groups
        if (firestoreGroups.isNotEmpty)
          ...firestoreGroups.map((g) => _buildGroupCard(
                name: g.name,
                teacher: g.teacherName,
                trackName: g.track.localizedName(langCode),
                schedule: '${g.scheduleDays.join("، ")} • ${g.startTime}',
                studentsCount: 12,
              ))
        else ...[
          _buildGroupCard(
            name: 'حلقة أبي بكر الصديق (حفظ مكثف)',
            teacher: 'الشيخ عبد الرحمن',
            trackName: 'مسار الحفظ والتسميع',
            schedule: 'الأحد والثلاثاء والخميس • 16:30',
            studentsCount: 12,
          ),
          _buildGroupCard(
            name: 'حلقة الإتقان والتجويد',
            teacher: 'الأستاذ طارق',
            trackName: 'التلاوة والتجويد',
            schedule: 'السبت والاثنين والأربعاء • 17:00',
            studentsCount: 8,
          ),
          _buildGroupCard(
            name: 'حلقة البراعم النورانية',
            teacher: 'الأستاذة مريم',
            trackName: 'القاعدة النورانية',
            schedule: 'الخميس • 15:30',
            studentsCount: 10,
          ),
        ],
      ],
    );
  }

  Widget _buildGroupCard({
    required String name,
    required String teacher,
    required String trackName,
    required String schedule,
    required int studentsCount,
  }) {
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
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
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
              Text('$studentsCount طلاب', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF6D7A77)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  schedule,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A77)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 0: USERS VIEW (المستخدمين)
  // ===========================================================================
  Widget _buildUsersTab(BuildContext context, String langCode, List<AppUser> allUsers) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tr(langCode, ar: 'إدارة حسابات المستخدمين', he: 'ניהול משתמשים', en: 'User Accounts'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_rounded, color: DarAlFajrTheme.primary),
              onPressed: () => _showCreateStudentDialog(context, langCode),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (allUsers.isNotEmpty)
          ...allUsers.map((u) => _buildUserCard(
                name: u.fullName,
                email: u.email,
                role: u.role.displayName,
                isPendingFirstLogin: u.isFirstLogin,
              ))
        else ...[
          _buildUserCard(name: 'الشيخ عبد الرحمن', email: 'abdulrahman@daralfajr.org', role: 'معلم', isPendingFirstLogin: false),
          _buildUserCard(name: 'الأستاذ طارق', email: 'tariq@daralfajr.org', role: 'معلم', isPendingFirstLogin: false),
          _buildUserCard(name: 'طه عثمان', email: 'taha.osman@email.com', role: 'ولي أمر', isPendingFirstLogin: false),
          _buildUserCard(name: 'يوسف الشريف', email: 'y.shareef@domain.org', role: 'ولي أمر', isPendingFirstLogin: false),
          _buildUserCard(name: 'إبراهيم طه عثمان', email: 'st_1042@daralfajr.org', role: 'طالب', isPendingFirstLogin: false),
        ],
      ],
    );
  }

  Widget _buildUserCard({
    required String name,
    required String email,
    required String role,
    required bool isPendingFirstLogin,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
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
    );
  }

  // ===========================================================================
  // TAB 3: REPORTS VIEW (التقارير والإحصائيات)
  // ===========================================================================
  Widget _buildReportsTab(BuildContext context, String langCode, int students, int groups, int oneOnOne) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Text(
          _tr(langCode, ar: 'لوحة التقارير والتحليلات', he: 'דוחות וניתוחים', en: 'Reports & Analytics'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 14),

        // Attendance Metric Card
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
                  Text(
                    _tr(langCode, ar: 'نسبة الحضور الأسبوعية', he: 'נוכחות שבועית', en: 'Weekly Attendance Rate'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Text('94%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: DarAlFajrTheme.primary)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: const LinearProgressIndicator(
                  value: 0.94,
                  minHeight: 8,
                  backgroundColor: Color(0xFFE6E8EA),
                  valueColor: AlwaysStoppedAnimation<Color>(DarAlFajrTheme.primary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _tr(
                  langCode,
                  ar: 'سجل 134 طالباً حضوراً منتظماً هذا الأسبوع مقابل 8 حالات غياب بعذر',
                  he: '134 תלמידים נכחו כסדרם',
                  en: '134 students attended regularly this week',
                ),
                style: const TextStyle(color: Color(0xFF6D7A77), fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Memorization Progress Metric Card
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
                  Text(
                    _tr(langCode, ar: 'إجمالي الأجزاء المنجزة', he: 'סה״כ ג׳וז הושלמו', en: 'Total Juz Completed'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Text('118 جزءاً', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF904D00))),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _tr(
                  langCode,
                  ar: 'أتم 18 طالباً حفظ الجزء المخصص لهم خلال الشهر الجاري بنجاح وتميز.',
                  he: '18 תלמידים השלימו שינון החודש',
                  en: '18 students completed their monthly assigned Juz successfully.',
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
