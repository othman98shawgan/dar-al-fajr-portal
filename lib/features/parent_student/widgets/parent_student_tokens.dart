import 'package:flutter/material.dart';

/// Shared visual design tokens and helpers for the Parent/Student portal.
abstract final class ParentStudentTokens {
  static const Color primary = Color(0xFF00685F);
  static const Color primaryContainer = Color(0xFF008378);
  static const Color primaryFixed = Color(0xFF89F5E7);
  static const Color onPrimaryFixed = Color(0xFF00201D);
  static const Color primaryFixedDim = Color(0xFF6BD8CB);
  static const Color secondary = Color(0xFF904D00);
  static const Color secondaryContainer = Color(0xFFFE932C);
  static const Color secondaryFixed = Color(0xFFFFDCC3);
  static const Color onSecondaryFixed = Color(0xFF2F1500);
  static const Color onSecondaryFixedVariant = Color(0xFF6E3900);
  static const Color tertiary = Color(0xFF1E6661);
  static const Color tertiaryContainer = Color(0xFF3B7F7A);
  static const Color tertiaryFixed = Color(0xFFABEFE8);
  static const Color onTertiaryFixed = Color(0xFF00201E);
  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E5);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF3D4947);
  static const Color outline = Color(0xFF6D7A77);
}

const List<String> _arMonths = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

const List<String> _heMonths = [
  'בינואר',
  'בפברואר',
  'במרץ',
  'באפריל',
  'במאי',
  'ביוני',
  'ביולי',
  'באוגוסט',
  'בספטמבר',
  'באוקטובר',
  'בנובמבר',
  'בדצמבר',
];

const List<String> _enMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Returns the Sunday at the start of the academic week containing [date].
DateTime parentWeekStartSunday(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final daysSinceSunday = normalized.weekday % 7;
  return normalized.subtract(Duration(days: daysSinceSunday));
}

/// Formats a single day inside the current academic week (e.g. `17 نوفمبر` / `Nov 17`).
String formatParentWeekDayLabel(
  DateTime referenceDate,
  int offsetFromSunday,
  String langCode,
) {
  final target =
      parentWeekStartSunday(referenceDate).add(Duration(days: offsetFromSunday));
  final monthIndex = target.month - 1;
  switch (langCode) {
    case 'he':
      return '${target.day} ${_heMonths[monthIndex]}';
    case 'en':
      return '${_enMonths[monthIndex]} ${target.day}';
    case 'ar':
    default:
      return '${target.day} ${_arMonths[monthIndex]}';
  }
}

/// Formats the current Sunday–Thursday academic week range dynamically from [referenceDate].
String formatParentAcademicWeekRange(
  DateTime referenceDate,
  String langCode,
) {
  final sunday = parentWeekStartSunday(referenceDate);
  final thursday = sunday.add(const Duration(days: 4));
  final sameMonth = sunday.month == thursday.month;

  switch (langCode) {
    case 'he':
      final range = sameMonth
          ? '${sunday.day} - ${thursday.day} ${_heMonths[thursday.month - 1]}'
          : '${sunday.day} ${_heMonths[sunday.month - 1]} - ${thursday.day} ${_heMonths[thursday.month - 1]}';
      return 'שבוע הלימודים הנוכחי ($range)';
    case 'en':
      final range = sameMonth
          ? '${_enMonths[sunday.month - 1]} ${sunday.day} - ${thursday.day}'
          : '${_enMonths[sunday.month - 1]} ${sunday.day} - ${_enMonths[thursday.month - 1]} ${thursday.day}';
      return 'Current Academic Week ($range)';
    case 'ar':
    default:
      final range = sameMonth
          ? '${sunday.day} - ${thursday.day} ${_arMonths[thursday.month - 1]}'
          : '${sunday.day} ${_arMonths[sunday.month - 1]} - ${thursday.day} ${_arMonths[thursday.month - 1]}';
      return 'الأسبوع الدراسي الحالي ($range)';
  }
}

/// Bottom navigation tab button shared by `ParentStudentHomeScreen`.
class ParentBottomNavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ParentBottomNavTab({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? ParentStudentTokens.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 140,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? ParentStudentTokens.primary
                    : ParentStudentTokens.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? ParentStudentTokens.primary
                      : ParentStudentTokens.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
