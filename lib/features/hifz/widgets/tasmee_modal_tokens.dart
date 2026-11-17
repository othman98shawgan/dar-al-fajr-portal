import 'package:flutter/material.dart';

class TasmeeModalTokens {
  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceVariant = Color(0xFFE0E3E5);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF3D4947);
  static const Color outline = Color(0xFF6D7A77);
  static const Color primary = Color(0xFF00685F);
  static const Color primaryFixed = Color(0xFF89F5E7);
  static const Color onPrimaryFixed = Color(0xFF00201D);
  static const Color secondary = Color(0xFF904D00);
  static const Color secondaryFixed = Color(0xFFFFDCC3);
  static const Color tertiary = Color(0xFF1E6661);
  static const Color error = Color(0xFFBA1A1A);
}

String formatTasmeeNum(int number, String langCode) {
  if (langCode != 'ar') return '$number';
  const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  var result = number.toString();
  for (var i = 0; i < western.length; i++) {
    result = result.replaceAll(western[i], eastern[i]);
  }
  return result;
}

class MistakeCounterTile extends StatelessWidget {
  final String label;
  final String penaltyLabel;
  final int count;
  final Color color;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const MistakeCounterTile({
    super.key,
    required this.label,
    required this.penaltyLabel,
    required this.count,
    required this.color,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: count > 0 ? color.withValues(alpha: 0.5) : const Color(0xFFE6E8EA),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191C1E),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '($penaltyLabel)',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: onDecrement,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.remove_rounded, size: 16),
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: count > 0 ? color : const Color(0xFF191C1E),
                ),
              ),
              InkWell(
                onTap: onIncrement,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.add_rounded, size: 16, color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
