import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/admin_models.dart';

class MobileStudentCardData {
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

  const MobileStudentCardData({
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

const List<MobileStudentCardData> adminMobileSeedStudentCards = [
  MobileStudentCardData(
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
  MobileStudentCardData(
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
  MobileStudentCardData(
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
  MobileStudentCardData(
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
  MobileStudentCardData(
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

List<MobileStudentCardData> buildMobileStudentCards({
  required List<StudentProfile> firestoreStudents,
  required List<Enrollment> firestoreEnrollments,
  required CenterTrack? trackFilter,
  required String query,
  required bool isDemoMode,
  required bool isAscendingOrder,
}) {
  final firestoreCards = firestoreStudents.map((s) {
    final enrollments = firestoreEnrollments.where((e) => e.studentId == s.id).toList();
    final primary = enrollments.firstOrNull;
    final track = primary?.track ?? CenterTrack.hifz;
    final trimmed = s.fullName.trim();
    final initial = trimmed.isNotEmpty ? trimmed.characters.first : 'ط';
    final shortCode = s.id.length >= 4 ? s.id.substring(0, 4).toUpperCase() : s.id.toUpperCase();

    return MobileStudentCardData(
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
      scheduleBadgeText: primary?.groupArrivalTime ?? (isDemoMode ? 'الأحد والثلاثاء 16:30' : null),
      scheduleBadgeIcon: Icons.schedule_rounded,
      scheduleBadgeBg: const Color(0xFFE6E8EA),
      scheduleBadgeFg: const Color(0xFF3D4947),
      primaryTrack: track,
      isFromFirestore: true,
    );
  }).toList();

  final combined = isDemoMode ? [...firestoreCards, ...adminMobileSeedStudentCards] : firestoreCards;

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

  if (!isAscendingOrder) {
    filtered = filtered.reversed.toList();
  }

  return filtered;
}
