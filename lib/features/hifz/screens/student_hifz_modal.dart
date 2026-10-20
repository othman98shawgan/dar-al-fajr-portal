import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder for StudentHifzModal — awaiting Google Stitch UI code.
class StudentHifzModal extends ConsumerWidget {
  final String studentId;
  final String studentName;
  final String groupId;

  const StudentHifzModal({
    super.key,
    this.studentId = '',
    this.studentName = '',
    this.groupId = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}
