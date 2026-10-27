import 'package:cloud_firestore/cloud_firestore.dart';

/// Multi-mode attendance status: Present (حاضر), Late (متأخر), Absent (غائب), Excused (معذور).
enum AttendanceStatus {
  present,
  late,
  absent,
  excused;

  static AttendanceStatus fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'late':
      case 'متأخر':
        return AttendanceStatus.late;
      case 'absent':
      case 'غائب':
        return AttendanceStatus.absent;
      case 'excused':
      case 'معذور':
        return AttendanceStatus.excused;
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
      case AttendanceStatus.excused:
        if (languageCode == 'he') return 'מוצדק';
        if (languageCode == 'en') return 'Excused';
        return 'معذور';
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

/// Admin-configurable grading penalties and passing thresholds.
class GradingPenaltyConfig {
  final int lafziPenalty;
  final int fathPenalty;
  final int tataaPenalty;
  final int pagePassingThreshold;
  final int juzExamPassingThreshold;

  const GradingPenaltyConfig({
    this.lafziPenalty = 3,
    this.fathPenalty = 3,
    this.tataaPenalty = 0,
    this.pagePassingThreshold = 94,
    this.juzExamPassingThreshold = 79,
  });

  int calculateScore({
    required int lafziCount,
    required int fathCount,
    required int tataaCount,
  }) {
    final deduction = (lafziCount * lafziPenalty) +
        (fathCount * fathPenalty) +
        (tataaCount * tataaPenalty);
    return (100 - deduction).clamp(0, 100);
  }

  bool isPassingScore({
    required int score,
    required bool isJuzExam,
    bool forceRepeat = false,
  }) {
    if (forceRepeat) return false;
    final threshold =
        isJuzExam ? juzExamPassingThreshold : pagePassingThreshold;
    return score >= threshold;
  }

  EvaluationGrade evaluateGrade({
    required int score,
    required bool isJuzExam,
    bool forceRepeat = false,
  }) {
    if (!isPassingScore(
      score: score,
      isJuzExam: isJuzExam,
      forceRepeat: forceRepeat,
    )) {
      return EvaluationGrade.needsRepeat;
    }
    if (isJuzExam) {
      return score >= 90 ? EvaluationGrade.excellent : EvaluationGrade.good;
    }
    return score >= 97 ? EvaluationGrade.excellent : EvaluationGrade.good;
  }

  factory GradingPenaltyConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const GradingPenaltyConfig();
    return GradingPenaltyConfig(
      lafziPenalty: (map['lafziPenalty'] as num?)?.toInt() ?? 3,
      fathPenalty: (map['fathPenalty'] as num?)?.toInt() ?? 3,
      tataaPenalty: (map['tataaPenalty'] as num?)?.toInt() ?? 0,
      pagePassingThreshold:
          (map['pagePassingThreshold'] as num?)?.toInt() ?? 94,
      juzExamPassingThreshold:
          (map['juzExamPassingThreshold'] as num?)?.toInt() ?? 79,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lafziPenalty': lafziPenalty,
      'fathPenalty': fathPenalty,
      'tataaPenalty': tataaPenalty,
      'pagePassingThreshold': pagePassingThreshold,
      'juzExamPassingThreshold': juzExamPassingThreshold,
    };
  }
}

/// Lifecycle state for a student's Juz' progression.
enum JuzProgressStatus {
  inProgress,
  readyForExam,
  passedExam;

  static JuzProgressStatus fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'ready_for_exam':
      case 'readyforexam':
        return JuzProgressStatus.readyForExam;
      case 'passed_exam':
      case 'passedexam':
        return JuzProgressStatus.passedExam;
      case 'in_progress':
      case 'inprogress':
      default:
        return JuzProgressStatus.inProgress;
    }
  }

  String toJson() {
    switch (this) {
      case JuzProgressStatus.inProgress:
        return 'in_progress';
      case JuzProgressStatus.readyForExam:
        return 'ready_for_exam';
      case JuzProgressStatus.passedExam:
        return 'passed_exam';
    }
  }

  String localizedName(String languageCode) {
    switch (this) {
      case JuzProgressStatus.inProgress:
        if (languageCode == 'he') return 'בתהליך שינון';
        if (languageCode == 'en') return 'Memorizing Pages';
        return 'قيد حفظ الصفحات';
      case JuzProgressStatus.readyForExam:
        if (languageCode == 'he') return 'מוכן למבחן ג׳וז';
        if (languageCode == 'en') return 'Ready for Juz Exam';
        return 'مؤهل لاختبار الجزء';
      case JuzProgressStatus.passedExam:
        if (languageCode == 'he') return 'עבר מבחן ג׳וז';
        if (languageCode == 'en') return 'Passed Juz Exam';
        return 'مجتاز اختبار الجزء';
    }
  }
}

/// Type of unit recited in a Tasmee' sitting.
enum RecitationUnitType {
  page,
  surah,
  juzExam,
  partialRead;

  static RecitationUnitType fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'surah':
        return RecitationUnitType.surah;
      case 'juz_exam':
      case 'juzexam':
        return RecitationUnitType.juzExam;
      case 'partial_read':
      case 'partialread':
        return RecitationUnitType.partialRead;
      case 'page':
      default:
        return RecitationUnitType.page;
    }
  }

  String toJson() {
    switch (this) {
      case RecitationUnitType.page:
        return 'page';
      case RecitationUnitType.surah:
        return 'surah';
      case RecitationUnitType.juzExam:
        return 'juz_exam';
      case RecitationUnitType.partialRead:
        return 'partial_read';
    }
  }

  String localizedName(String languageCode) {
    switch (this) {
      case RecitationUnitType.page:
        if (languageCode == 'he') return 'עמוד מלא';
        if (languageCode == 'en') return 'Whole Page';
        return 'صفحة كاملة';
      case RecitationUnitType.surah:
        if (languageCode == 'he') return 'סורה מלאה';
        if (languageCode == 'en') return 'Whole Surah';
        return 'سورة كاملة';
      case RecitationUnitType.juzExam:
        if (languageCode == 'he') return 'מבחן / חזרת ג׳וז מלא';
        if (languageCode == 'en') return 'Whole Juz Exam / Revision';
        return 'مراجعة / اختبار جزء كامل';
      case RecitationUnitType.partialRead:
        if (languageCode == 'he') return 'קריאה חלקית (הערה בלבד)';
        if (languageCode == 'en') return 'Partial Read (Note Only)';
        return 'قراءة جزئية (ملاحظة فقط)';
    }
  }
}

/// Represents a single evaluated unit in a multi-unit Tasmee' session.
class TasmeeRecitationUnit {
  final RecitationUnitType unitType;
  final int surahId;
  final String surahName;
  final int? pageNumber;
  final int? juzNumber;
  final int fromAyah;
  final int toAyah;
  final int lafziCount;
  final int fathCount;
  final int tataaCount;
  final int? manualScoreOverride;
  final bool forceRepeat;
  final String notes;

  const TasmeeRecitationUnit({
    required this.unitType,
    this.surahId = 1,
    this.surahName = '',
    this.pageNumber,
    this.juzNumber,
    this.fromAyah = 1,
    this.toAyah = 7,
    this.lafziCount = 0,
    this.fathCount = 0,
    this.tataaCount = 0,
    this.manualScoreOverride,
    this.forceRepeat = false,
    this.notes = '',
  });

  bool get isGraded => unitType != RecitationUnitType.partialRead;

  int? computedScore(GradingPenaltyConfig config) {
    if (!isGraded) return null;
    if (manualScoreOverride != null) {
      return manualScoreOverride!.clamp(0, 100);
    }
    return config.calculateScore(
      lafziCount: lafziCount,
      fathCount: fathCount,
      tataaCount: tataaCount,
    );
  }

  bool isPassed(GradingPenaltyConfig config) {
    if (!isGraded) return false;
    final s = computedScore(config) ?? 0;
    return config.isPassingScore(
      score: s,
      isJuzExam: unitType == RecitationUnitType.juzExam,
      forceRepeat: forceRepeat,
    );
  }

  TasmeeRecitationUnit copyWith({
    RecitationUnitType? unitType,
    int? surahId,
    String? surahName,
    int? pageNumber,
    int? juzNumber,
    int? fromAyah,
    int? toAyah,
    int? lafziCount,
    int? fathCount,
    int? tataaCount,
    int? manualScoreOverride,
    bool clearManualScore = false,
    bool? forceRepeat,
    String? notes,
  }) {
    return TasmeeRecitationUnit(
      unitType: unitType ?? this.unitType,
      surahId: surahId ?? this.surahId,
      surahName: surahName ?? this.surahName,
      pageNumber: pageNumber ?? this.pageNumber,
      juzNumber: juzNumber ?? this.juzNumber,
      fromAyah: fromAyah ?? this.fromAyah,
      toAyah: toAyah ?? this.toAyah,
      lafziCount: lafziCount ?? this.lafziCount,
      fathCount: fathCount ?? this.fathCount,
      tataaCount: tataaCount ?? this.tataaCount,
      manualScoreOverride: clearManualScore
          ? null
          : (manualScoreOverride ?? this.manualScoreOverride),
      forceRepeat: forceRepeat ?? this.forceRepeat,
      notes: notes ?? this.notes,
    );
  }

  factory TasmeeRecitationUnit.fromMap(Map<String, dynamic> map) {
    return TasmeeRecitationUnit(
      unitType: RecitationUnitType.fromString(map['unitType'] as String?),
      surahId: (map['surahId'] as num?)?.toInt() ?? 1,
      surahName: (map['surahName'] ?? '') as String,
      pageNumber: (map['pageNumber'] as num?)?.toInt(),
      juzNumber: (map['juzNumber'] as num?)?.toInt(),
      fromAyah: (map['fromAyah'] as num?)?.toInt() ?? 1,
      toAyah: (map['toAyah'] as num?)?.toInt() ?? 1,
      lafziCount: (map['lafziCount'] as num?)?.toInt() ?? 0,
      fathCount: (map['fathCount'] as num?)?.toInt() ?? 0,
      tataaCount: (map['tataaCount'] as num?)?.toInt() ?? 0,
      manualScoreOverride: (map['manualScoreOverride'] as num?)?.toInt(),
      forceRepeat: (map['forceRepeat'] as bool?) ?? false,
      notes: (map['notes'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unitType': unitType.toJson(),
      'surahId': surahId,
      'surahName': surahName,
      'pageNumber': pageNumber,
      'juzNumber': juzNumber,
      'fromAyah': fromAyah,
      'toAyah': toAyah,
      'lafziCount': lafziCount,
      'fathCount': fathCount,
      'tataaCount': tataaCount,
      'manualScoreOverride': manualScoreOverride,
      'forceRepeat': forceRepeat,
      'notes': notes,
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
  final int? targetPage;
  final int? juzNumber;
  final List<int> touchedPages;
  final List<int> touchedJuz;
  final EvaluationGrade grade;
  final int? score;
  final int lafziCount;
  final int fathCount;
  final int tataaCount;
  final bool isPartialRead;
  final bool isJuzExam;
  final bool forceRepeat;
  final List<TasmeeRecitationUnit> recitationUnits;
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
    this.targetPage,
    this.juzNumber,
    this.touchedPages = const [],
    this.touchedJuz = const [],
    this.grade = EvaluationGrade.pending,
    this.score,
    this.lafziCount = 0,
    this.fathCount = 0,
    this.tataaCount = 0,
    this.isPartialRead = false,
    this.isJuzExam = false,
    this.forceRepeat = false,
    this.recitationUnits = const [],
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

    List<TasmeeRecitationUnit> parseUnits(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map(
              (m) => TasmeeRecitationUnit.fromMap(
                Map<String, dynamic>.from(m),
              ),
            )
            .toList();
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
      surahId: ((map['surahId'] ?? map['surah_id'] ?? 1) as num).toInt(),
      surahName: (map['surahName'] ?? map['surah_name'] ?? '') as String,
      fromAyah: ((map['fromAyah'] ?? map['from_ayah'] ?? 1) as num).toInt(),
      toAyah: ((map['toAyah'] ?? map['to_ayah'] ?? 1) as num).toInt(),
      targetPage: (map['targetPage'] ?? map['target_page'] as num?)?.toInt(),
      juzNumber: (map['juzNumber'] ?? map['juz_number'] as num?)?.toInt(),
      touchedPages:
          parseIntList(map['touchedPages'] ?? map['touched_pages']),
      touchedJuz: parseIntList(map['touchedJuz'] ?? map['touched_juz']),
      grade: EvaluationGrade.fromString(map['grade'] as String?),
      score: (map['score'] as num?)?.toInt(),
      lafziCount: ((map['lafziCount'] ?? 0) as num).toInt(),
      fathCount: ((map['fathCount'] ?? 0) as num).toInt(),
      tataaCount: ((map['tataaCount'] ?? 0) as num).toInt(),
      isPartialRead: (map['isPartialRead'] as bool?) ?? false,
      isJuzExam: (map['isJuzExam'] as bool?) ?? false,
      forceRepeat: (map['forceRepeat'] as bool?) ?? false,
      recitationUnits: parseUnits(map['recitationUnits']),
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
      'targetPage': targetPage,
      'juzNumber': juzNumber,
      'touchedPages': touchedPages,
      'touchedJuz': touchedJuz,
      'grade': grade.toJson(),
      'score': score,
      'lafziCount': lafziCount,
      'fathCount': fathCount,
      'tataaCount': tataaCount,
      'isPartialRead': isPartialRead,
      'isJuzExam': isJuzExam,
      'forceRepeat': forceRepeat,
      'recitationUnits': recitationUnits.map((u) => u.toMap()).toList(),
      'teacherNotes': teacherNotes,
      'assignedAt': Timestamp.fromDate(assignedAt),
      'evaluatedAt': evaluatedAt != null
          ? Timestamp.fromDate(evaluatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}

/// Target type for a structured daily revision task.
enum RevisionTargetType {
  juz,
  pageRange,
  surah;

  static RevisionTargetType fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'page_range':
      case 'pagerange':
        return RevisionTargetType.pageRange;
      case 'surah':
        return RevisionTargetType.surah;
      case 'juz':
      default:
        return RevisionTargetType.juz;
    }
  }

  String toJson() {
    switch (this) {
      case RevisionTargetType.juz:
        return 'juz';
      case RevisionTargetType.pageRange:
        return 'page_range';
      case RevisionTargetType.surah:
        return 'surah';
    }
  }
}

/// Student self-check completion status for a daily revision task.
enum RevisionTaskStatus {
  pending,
  doneOnTime,
  doneLate;

  static RevisionTaskStatus fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'done_on_time':
      case 'doneontime':
        return RevisionTaskStatus.doneOnTime;
      case 'done_late':
      case 'donelate':
        return RevisionTaskStatus.doneLate;
      case 'pending':
      default:
        return RevisionTaskStatus.pending;
    }
  }

  String toJson() {
    switch (this) {
      case RevisionTaskStatus.pending:
        return 'pending';
      case RevisionTaskStatus.doneOnTime:
        return 'done_on_time';
      case RevisionTaskStatus.doneLate:
        return 'done_late';
    }
  }

  String localizedName(String languageCode) {
    switch (this) {
      case RevisionTaskStatus.pending:
        if (languageCode == 'he') return 'ממתין לביצוע';
        if (languageCode == 'en') return 'Pending';
        return 'قيد الإنجاز';
      case RevisionTaskStatus.doneOnTime:
        if (languageCode == 'he') return 'בוצע בזמן';
        if (languageCode == 'en') return 'Done on Time';
        return 'تم بالوقت';
      case RevisionTaskStatus.doneLate:
        if (languageCode == 'he') return 'בוצע באיחור';
        if (languageCode == 'en') return 'Done Late';
        return 'تم متأخراً';
    }
  }
}

/// Structured daily revision task (or rest day when `isRestDay == true`).
class DailyRevisionTask {
  final int dayIndex; // 0 = Sunday .. 6 = Saturday
  final bool isRestDay;
  final RevisionTargetType targetType;
  final int? juzNumber;
  final int? fromPage;
  final int? toPage;
  final int? surahId;
  final String? surahName;
  final String notes;
  final RevisionTaskStatus status;
  final DateTime? completedAt;

  const DailyRevisionTask({
    required this.dayIndex,
    this.isRestDay = false,
    this.targetType = RevisionTargetType.juz,
    this.juzNumber,
    this.fromPage,
    this.toPage,
    this.surahId,
    this.surahName,
    this.notes = '',
    this.status = RevisionTaskStatus.pending,
    this.completedAt,
  });

  String displaySummary(String langCode) {
    if (isRestDay) {
      if (langCode == 'he') return 'יום מנוחה (ללא משימה)';
      if (langCode == 'en') return 'Rest Day (No task)';
      return 'يوم راحة (بدون مهمة)';
    }
    switch (targetType) {
      case RevisionTargetType.juz:
        final j = juzNumber ?? 30;
        if (langCode == 'he') return 'ג׳וז $j מלא';
        if (langCode == 'en') return 'Whole Juz $j';
        return 'الجزء $j كامل';
      case RevisionTargetType.pageRange:
        final fp = fromPage ?? 1;
        final tp = toPage ?? fp;
        if (langCode == 'he') return 'עמודים $fp - $tp';
        if (langCode == 'en') return 'Pages $fp - $tp';
        return 'الصفحات $fp إلى $tp';
      case RevisionTargetType.surah:
        final sName = surahName ?? '';
        if (langCode == 'he') return 'סורת $sName';
        if (langCode == 'en') return 'Surah $sName';
        return 'سورة $sName';
    }
  }

  DailyRevisionTask copyWith({
    int? dayIndex,
    bool? isRestDay,
    RevisionTargetType? targetType,
    int? juzNumber,
    int? fromPage,
    int? toPage,
    int? surahId,
    String? surahName,
    String? notes,
    RevisionTaskStatus? status,
    DateTime? completedAt,
  }) {
    return DailyRevisionTask(
      dayIndex: dayIndex ?? this.dayIndex,
      isRestDay: isRestDay ?? this.isRestDay,
      targetType: targetType ?? this.targetType,
      juzNumber: juzNumber ?? this.juzNumber,
      fromPage: fromPage ?? this.fromPage,
      toPage: toPage ?? this.toPage,
      surahId: surahId ?? this.surahId,
      surahName: surahName ?? this.surahName,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory DailyRevisionTask.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic raw) {
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw);
      return null;
    }

    return DailyRevisionTask(
      dayIndex: ((map['dayIndex'] ?? 0) as num).toInt(),
      isRestDay: (map['isRestDay'] as bool?) ?? false,
      targetType: RevisionTargetType.fromString(map['targetType'] as String?),
      juzNumber: (map['juzNumber'] as num?)?.toInt(),
      fromPage: (map['fromPage'] as num?)?.toInt(),
      toPage: (map['toPage'] as num?)?.toInt(),
      surahId: (map['surahId'] as num?)?.toInt(),
      surahName: map['surahName'] as String?,
      notes: (map['notes'] ?? '') as String,
      status: RevisionTaskStatus.fromString(map['status'] as String?),
      completedAt: parseDate(map['completedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayIndex': dayIndex,
      'isRestDay': isRestDay,
      'targetType': targetType.toJson(),
      'juzNumber': juzNumber,
      'fromPage': fromPage,
      'toPage': toPage,
      'surahId': surahId,
      'surahName': surahName,
      'notes': notes,
      'status': status.toJson(),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}

/// Represents a student's 7-day structured weekly revision plan in `weekly_revision_plans`.
class WeeklyRevisionPlan {
  final String id;
  final String studentId;
  final String studentName;
  final String groupId;
  final String teacherId;
  final DateTime weekStartDate;
  final List<DailyRevisionTask> dailyTasks;
  final DateTime updatedAt;

  const WeeklyRevisionPlan({
    required this.id,
    required this.studentId,
    this.studentName = '',
    required this.groupId,
    required this.teacherId,
    required this.weekStartDate,
    required this.dailyTasks,
    required this.updatedAt,
  });

  int get activeDaysCount => dailyTasks.where((t) => !t.isRestDay).length;

  int get completedDaysCount => dailyTasks
      .where(
        (t) =>
            !t.isRestDay &&
            (t.status == RevisionTaskStatus.doneOnTime ||
                t.status == RevisionTaskStatus.doneLate),
      )
      .length;

  factory WeeklyRevisionPlan.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return WeeklyRevisionPlan.fromMap(data, id: doc.id);
  }

  factory WeeklyRevisionPlan.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parseDate(dynamic raw) {
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      return DateTime.now();
    }

    final rawTasks = map['dailyTasks'];
    final tasks = rawTasks is List
        ? rawTasks
            .whereType<Map>()
            .map(
              (m) => DailyRevisionTask.fromMap(Map<String, dynamic>.from(m)),
            )
            .toList()
        : List<DailyRevisionTask>.generate(
            7,
            (i) => DailyRevisionTask(dayIndex: i, isRestDay: true),
          );

    return WeeklyRevisionPlan(
      id: id ?? (map['id'] as String? ?? ''),
      studentId: (map['studentId'] ?? '') as String,
      studentName: (map['studentName'] ?? '') as String,
      groupId: (map['groupId'] ?? '') as String,
      teacherId: (map['teacherId'] ?? '') as String,
      weekStartDate: parseDate(map['weekStartDate']),
      dailyTasks: tasks,
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'groupId': groupId,
      'teacherId': teacherId,
      'weekStartDate': Timestamp.fromDate(weekStartDate),
      'dailyTasks': dailyTasks.map((t) => t.toMap()).toList(),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// Item in the Least Recently Revised (LRU) Priority Queue for spaced repetition.
class RevisionPriorityItem {
  final int juzNumber;
  final DateTime? lastRevisedAt;
  final int daysSinceLastRevision;
  final JuzProgressStatus juzStatus;

  const RevisionPriorityItem({
    required this.juzNumber,
    this.lastRevisedAt,
    required this.daysSinceLastRevision,
    required this.juzStatus,
  });
}
