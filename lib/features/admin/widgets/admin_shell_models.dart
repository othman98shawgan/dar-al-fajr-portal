import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/admin_models.dart';

class AdminRosterRowData {
  final String id;
  final String code;
  final String fullName;
  final String initial;
  final String parentName;
  final String parentEmail;
  final List<TrackBadgeData> trackBadges;
  final CenterTrack primaryTrack;
  final String groupSchedule;
  final String? oneOnOneSchedule;
  final bool isHighlighted;
  final bool isFromFirestore;

  const AdminRosterRowData({
    required this.id,
    required this.code,
    required this.fullName,
    required this.initial,
    required this.parentName,
    required this.parentEmail,
    required this.trackBadges,
    required this.primaryTrack,
    required this.groupSchedule,
    this.oneOnOneSchedule,
    this.isHighlighted = false,
    this.isFromFirestore = false,
  });
}

class TrackBadgeData {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const TrackBadgeData({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}

const List<String> adminWeekDaysAr = [
  'السبت',
  'الأحد',
  'الاثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
];

String formatAdminStudentCode(String studentId) {
  final trimmed = studentId.trim();
  if (trimmed.isEmpty) return '#ST-0000';
  if (trimmed.toLowerCase().startsWith('st-')) {
    return '#${trimmed.toUpperCase()}';
  }
  final shortId = trimmed.length >= 4 ? trimmed.substring(0, 4).toUpperCase() : trimmed.toUpperCase();
  return '#ST-$shortId';
}

const List<AdminRosterRowData> adminSeedRosterRows = [
  AdminRosterRowData(
    id: 'st-1042',
    code: '#ST-1042',
    fullName: 'إبراهيم طه عثمان',
    initial: 'إ',
    parentName: 'طه عثمان',
    parentEmail: 'taha.osman@email.com',
    primaryTrack: CenterTrack.qaidahNouraniah,
    trackBadges: [
      TrackBadgeData(label: 'قاعدة نورانية', backgroundColor: Color(0xFFABEFE8), textColor: Color(0xFF00201E)),
      TrackBadgeData(label: 'تجويد (معلق)', backgroundColor: Color(0xFFFFDCC3), textColor: Color(0xFF2F1500)),
    ],
    groupSchedule: 'الأحد والثلاثاء والخميس 16:30',
    oneOnOneSchedule: 'الخميس 17:15 (فردي)',
    isHighlighted: true,
  ),
  AdminRosterRowData(
    id: 'st-1088',
    code: '#ST-1088',
    fullName: 'عبد الرحمن يوسف الشريف',
    initial: 'ع',
    parentName: 'يوسف الشريف',
    parentEmail: 'y.shareef@domain.org',
    primaryTrack: CenterTrack.hifz,
    trackBadges: [
      TrackBadgeData(label: 'حفظ مكثف', backgroundColor: Color(0xFF89F5E7), textColor: Color(0xFF00201D)),
    ],
    groupSchedule: 'السبت والاثنين 17:00',
    oneOnOneSchedule: 'الاثنين 18:00 (فردي)',
  ),
  AdminRosterRowData(
    id: 'st-1102',
    code: '#ST-1102',
    fullName: 'زياد المنصور',
    initial: 'ز',
    parentName: 'سليمان المنصور',
    parentEmail: 'mansour.s@gmail.com',
    primaryTrack: CenterTrack.readingTajweed,
    trackBadges: [
      TrackBadgeData(label: 'تجويد وإتقان', backgroundColor: Color(0xFFFFDCC3), textColor: Color(0xFF2F1500)),
    ],
    groupSchedule: 'الأحد والأربعاء 16:00',
    oneOnOneSchedule: null,
  ),
  AdminRosterRowData(
    id: 'st-1115',
    code: '#ST-1115',
    fullName: 'حمزة كمال الدين',
    initial: 'ح',
    parentName: 'كمال الدين فؤاد',
    parentEmail: 'kamal.din@outlook.com',
    primaryTrack: CenterTrack.qaidahNouraniah,
    trackBadges: [
      TrackBadgeData(label: 'قاعدة نورانية', backgroundColor: Color(0xFFABEFE8), textColor: Color(0xFF00201E)),
    ],
    groupSchedule: 'السبت والخميس 15:30',
    oneOnOneSchedule: null,
  ),
  AdminRosterRowData(
    id: 'st-1130',
    code: '#ST-1130',
    fullName: 'عمر فاروق البغدادي',
    initial: 'ع',
    parentName: 'فاروق البغدادي',
    parentEmail: 'baghdadi.f@edu.org',
    primaryTrack: CenterTrack.tarbawi,
    trackBadges: [
      TrackBadgeData(label: 'تربوي وتدبر', backgroundColor: Color(0xFFE0E3E5), textColor: Color(0xFF3D4947)),
    ],
    groupSchedule: 'الجمعة 17:30',
    oneOnOneSchedule: 'الجمعة 19:00 (فردي)',
  ),
  AdminRosterRowData(
    id: 'st-1144',
    code: '#ST-1144',
    fullName: 'بلال سعد السبيعي',
    initial: 'ب',
    parentName: 'سعد السبيعي',
    parentEmail: 'saad.subaie@live.com',
    primaryTrack: CenterTrack.hifz,
    trackBadges: [
      TrackBadgeData(label: 'حفظ مكثف', backgroundColor: Color(0xFF89F5E7), textColor: Color(0xFF00201D)),
    ],
    groupSchedule: 'الأحد والثلاثاء والخميس 17:00',
    oneOnOneSchedule: null,
  ),
];

class AdminSidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AdminSidebarNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? DarAlFajrTheme.primaryDark : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : const Color(0xFF89F5E7)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isSelected ? Colors.white : const Color(0xFF89F5E7),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminStatSummaryCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color accentColor;

  const AdminStatSummaryCard({
    super.key,
    required this.width,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.clamp(200, 420),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DarAlFajrTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF6D7A77))),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF191C1E),
                          ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        unit,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 26, color: accentColor),
          ),
        ],
      ),
    );
  }
}

class AdminFilterChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AdminFilterChipButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? DarAlFajrTheme.primary : const Color(0xFFECEEF0),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected ? Colors.white : const Color(0xFF3D4947),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

class AdminPaginationButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const AdminPaginationButton({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? DarAlFajrTheme.primary : const Color(0xFFECEEF0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: icon != null
            ? Icon(icon, size: 18, color: const Color(0xFF3D4947))
            : Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected ? Colors.white : const Color(0xFF3D4947),
                      fontWeight: FontWeight.bold,
                    ),
              ),
      ),
    );
  }
}
