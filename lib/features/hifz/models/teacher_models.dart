import 'package:cloud_firestore/cloud_firestore.dart';

/// Multi-mode attendance status: Present (حاضر), Late (متأخر), Absent (غائب).
enum AttendanceStatus {
  present,
  late,
  absent;

  static AttendanceStatus fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'late':
      case 'متأخر':
        return AttendanceStatus.late;
      case 'absent':
      case 'غائب':
        return AttendanceStatus.absent;
      case 'present':
      case 'حاضر':
      default:
        return AttendanceStatus.present;
    }
  }

  String toJson() => name;

  String localizedName(String languageCode) {
    switch (this) {
      case AttendanceStatus.present:
        if (languageCode == 'he') return 'נוכח';
        if (languageCode == 'en') return 'Present';
        return 'حاضر';
      case AttendanceStatus.late:
        if (languageCode == 'he') return 'איחור';
        if (languageCode == 'en') return 'Late';
        return 'متأخر';
      case AttendanceStatus.absent:
        if (languageCode == 'he') return 'חיסור';
        if (languageCode == 'en') return 'Absent';
        return 'غائب';
    }
  }
}

/// Session mode for attendance logging: Group class or 1-on-1 individual slot.
enum SessionMode {
  group,
  oneOnOne;

  static SessionMode fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'one_on_one':
      case 'oneonone':
        return SessionMode.oneOnOne;
      case 'group':
      default:
        return SessionMode.group;
    }
  }

  String toJson() {
    switch (this) {
      case SessionMode.group:
        return 'group';
      case SessionMode.oneOnOne:
        return 'one_on_one';
    }
  }
}

/// Represents a record in the `attendance_logs` Firestore collection.
class AttendanceLog {
  final String id;
  final String groupId;
  final String studentId;
  final String studentName;
  final String teacherId;
  final DateTime sessionDate;
  final SessionMode sessionMode;
  final AttendanceStatus status;
  final String? notes;
  final DateTime? createdAt;

  const AttendanceLog({
    required this.id,
    required this.groupId,
    required this.studentId,
    this.studentName = '',
    required this.teacherId,
    required this.sessionDate,
    this.sessionMode = SessionMode.group,
    required this.status,
    this.notes,
    this.createdAt,
  });

  factory AttendanceLog.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return AttendanceLog.fromMap(data, id: doc.id);
  }

  factory AttendanceLog.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parseDate(dynamic raw) {
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      return DateTime.now();
    }

    return AttendanceLog(
      id: id ?? (map['id'] as String? ?? ''),
      groupId: (map['groupId'] ?? map['group_id'] ?? '') as String,
      studentId: (map['studentId'] ?? map['student_id'] ?? '') as String,
      studentName: (map['studentName'] ?? map['student_name'] ?? '') as String,
      teacherId: (map['teacherId'] ?? map['teacher_id'] ?? '') as String,
      sessionDate: parseDate(map['sessionDate'] ?? map['session_date']),
      sessionMode: SessionMode.fromString(
          (map['sessionMode'] ?? map['session_mode']) as String?),
      status: AttendanceStatus.fromString(map['status'] as String?),
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] != null ? parseDate(map['createdAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'studentId': studentId,
      'studentName': studentName,
      'teacherId': teacherId,
      'sessionDate': Timestamp.fromDate(sessionDate),
      'sessionMode': sessionMode.toJson(),
      'status': status.toJson(),
      'notes': notes,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}

/// Type of Quran assignment: New Hifz (حفظ جديد) or Revision (مراجعة).
enum AssignmentType {
  newHifz,
  revision;

  static AssignmentType fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'revision':
      case 'مراجعة':
        return AssignmentType.revision;
      case 'new_hifz':
      case 'newhifz':
      case 'حفظ جديد':
      default:
        return AssignmentType.newHifz;
    }
  }

  String toJson() {
    switch (this) {
      case AssignmentType.newHifz:
        return 'new_hifz';
      case AssignmentType.revision:
        return 'revision';
    }
  }

  String localizedName(String languageCode) {
    switch (this) {
      case AssignmentType.newHifz:
        if (languageCode == 'he') return 'שינון חדש (חיפז)';
        if (languageCode == 'en') return 'New Hifz';
        return 'حفظ جديد';
      case AssignmentType.revision:
        if (languageCode == 'he') return 'חזרה (מוראג׳עה)';
        if (languageCode == 'en') return 'Revision';
        return 'مراجعة';
    }
  }
}

/// Evaluation grade for a Hifz or Revision assignment.
enum EvaluationGrade {
  pending,
  excellent,
  good,
  needsRepeat;

  static EvaluationGrade fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'excellent':
      case 'ممتاز':
        return EvaluationGrade.excellent;
      case 'good':
      case 'جيد':
      case 'جيد جداً':
        return EvaluationGrade.good;
      case 'needs_repeat':
      case 'needsrepeat':
      case 'إعادة':
      case 'يحتاج إعادة':
        return EvaluationGrade.needsRepeat;
      case 'pending':
      default:
        return EvaluationGrade.pending;
    }
  }

  String toJson() {
    switch (this) {
      case EvaluationGrade.pending:
        return 'pending';
      case EvaluationGrade.excellent:
        return 'excellent';
      case EvaluationGrade.good:
        return 'good';
      case EvaluationGrade.needsRepeat:
        return 'needs_repeat';
    }
  }

  bool get isPassed =>
      this == EvaluationGrade.excellent || this == EvaluationGrade.good;

  String localizedName(String languageCode) {
    switch (this) {
      case EvaluationGrade.excellent:
        if (languageCode == 'he') return 'מצוין';
        if (languageCode == 'en') return 'Excellent';
        return 'ممتاز';
      case EvaluationGrade.good:
        if (languageCode == 'he') return 'טוב';
        if (languageCode == 'en') return 'Good';
        return 'جيد';
      case EvaluationGrade.needsRepeat:
        if (languageCode == 'he') return 'דורש חזרה';
        if (languageCode == 'en') return 'Needs Repeat';
        return 'يحتاج إعادة';
      case EvaluationGrade.pending:
        if (languageCode == 'he') return 'ממתין להערכה';
        if (languageCode == 'en') return 'Pending';
        return 'قيد التقييم';
    }
  }
}

/// Represents a weekly Hifz or Revision assignment in `hifz_assignments`.
class HifzAssignment {
  final String id;
  final String studentId;
  final String studentName;
  final String groupId;
  final String teacherId;
  final AssignmentType type;
  final int surahId;
  final String surahName;
  final int fromAyah;
  final int toAyah;
  final List<int> touchedPages;
  final List<int> touchedJuz;
  final EvaluationGrade grade;
  final String teacherNotes;
  final DateTime assignedAt;
  final DateTime? evaluatedAt;

  const HifzAssignment({
    required this.id,
    required this.studentId,
    this.studentName = '',
    required this.groupId,
    required this.teacherId,
    required this.type,
    required this.surahId,
    this.surahName = '',
    required this.fromAyah,
    required this.toAyah,
    this.touchedPages = const [],
    this.touchedJuz = const [],
    this.grade = EvaluationGrade.pending,
    this.teacherNotes = '',
    required this.assignedAt,
    this.evaluatedAt,
  });

  factory HifzAssignment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return HifzAssignment.fromMap(data, id: doc.id);
  }

  factory HifzAssignment.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parseDate(dynamic raw) {
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      return DateTime.now();
    }

    List<int> parseIntList(dynamic raw) {
      if (raw is List) {
        return raw.whereType<num>().map((e) => e.toInt()).toList();
      }
      return const [];
    }

    return HifzAssignment(
      id: id ?? (map['id'] as String? ?? ''),
      studentId: (map['studentId'] ?? map['student_id'] ?? '') as String,
      studentName: (map['studentName'] ?? map['student_name'] ?? '') as String,
      groupId: (map['groupId'] ?? map['group_id'] ?? '') as String,
      teacherId: (map['teacherId'] ?? map['teacher_id'] ?? '') as String,
      type: AssignmentType.fromString(map['type'] as String?),
      surahId: (map['surahId'] ?? map['surah_id'] ?? 1) as int,
      surahName: (map['surahName'] ?? map['surah_name'] ?? '') as String,
      fromAyah: (map['fromAyah'] ?? map['from_ayah'] ?? 1) as int,
      toAyah: (map['toAyah'] ?? map['to_ayah'] ?? 1) as int,
      touchedPages:
          parseIntList(map['touchedPages'] ?? map['touched_pages']),
      touchedJuz: parseIntList(map['touchedJuz'] ?? map['touched_juz']),
      grade: EvaluationGrade.fromString(map['grade'] as String?),
      teacherNotes:
          (map['teacherNotes'] ?? map['teacher_notes'] ?? '') as String,
      assignedAt: parseDate(map['assignedAt'] ?? map['assigned_at']),
      evaluatedAt:
          map['evaluatedAt'] != null ? parseDate(map['evaluatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'groupId': groupId,
      'teacherId': teacherId,
      'type': type.toJson(),
      'surahId': surahId,
      'surahName': surahName,
      'fromAyah': fromAyah,
      'toAyah': toAyah,
      'touchedPages': touchedPages,
      'touchedJuz': touchedJuz,
      'grade': grade.toJson(),
      'teacherNotes': teacherNotes,
      'assignedAt': Timestamp.fromDate(assignedAt),
      'evaluatedAt': evaluatedAt != null
          ? Timestamp.fromDate(evaluatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
