import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/surah_page_map.dart';

/// The 4 Dar al-Fajr Center tracks.
enum CenterTrack {
  hifz,
  qaidahNouraniah,
  readingTajweed,
  tarbawi;

  static CenterTrack fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'qaidah_nouraniah':
      case 'qaidahnouraniah':
      case 'qaidah':
        return CenterTrack.qaidahNouraniah;
      case 'reading_tajweed':
      case 'readingtajweed':
      case 'tajweed':
        return CenterTrack.readingTajweed;
      case 'tarbawi':
        return CenterTrack.tarbawi;
      case 'hifz':
      default:
        return CenterTrack.hifz;
    }
  }

  String toJson() {
    switch (this) {
      case CenterTrack.hifz:
        return 'hifz';
      case CenterTrack.qaidahNouraniah:
        return 'qaidah_nouraniah';
      case CenterTrack.readingTajweed:
        return 'reading_tajweed';
      case CenterTrack.tarbawi:
        return 'tarbawi';
    }
  }

  String localizedName(String languageCode) {
    switch (this) {
      case CenterTrack.hifz:
        if (languageCode == 'he') return 'חיפז (שינון)';
        if (languageCode == 'en') return 'Hifz & Memorization';
        return 'مسار الحفظ والتسميع';
      case CenterTrack.qaidahNouraniah:
        if (languageCode == 'he') return 'קאעידה נוראניה';
        if (languageCode == 'en') return "Qa'idah Nouraniah";
        return 'القاعدة النورانية';
      case CenterTrack.readingTajweed:
        if (languageCode == 'he') return 'קריאה וטג׳וויד';
        if (languageCode == 'en') return 'Reading & Tajweed';
        return 'التلاوة والتجويد';
      case CenterTrack.tarbawi:
        if (languageCode == 'he') return 'חינוכי (תרבווי)';
        if (languageCode == 'en') return 'Tarbawi';
        return 'المسار التربوي';
    }
  }
}

/// Represents a learner profile in the `students` Firestore collection.
class StudentProfile {
  final String id;
  final String fullName;
  final String parentId;
  final String? parentName;
  final String? userId;
  final String? email;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final List<int> memorizedPages;
  final List<int> completedSurahs;
  final List<int> completedJuz;
  final List<String> memorizedCenterUnits;
  final Map<int, String> juzStatuses;
  final Map<int, DateTime> lastRevisedJuzDates;
  final bool isArchived;
  final DateTime? createdAt;

  const StudentProfile({
    required this.id,
    required this.fullName,
    required this.parentId,
    this.parentName,
    this.userId,
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.memorizedPages = const [],
    this.completedSurahs = const [],
    this.completedJuz = const [],
    this.memorizedCenterUnits = const [],
    this.juzStatuses = const {},
    this.lastRevisedJuzDates = const {},
    this.isArchived = false,
    this.createdAt,
  });

  /// Total memorized center page units (out of 657) according to Dar al-Fajr rules.
  int get memorizedCenterPagesCount =>
      CenterQuranMap.calculateMemorizedCenterPages(
        memorizedPages: memorizedPages,
        completedSurahs: completedSurahs,
        memorizedCenterUnits: memorizedCenterUnits,
      );

  factory StudentProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return StudentProfile.fromMap(data, id: doc.id);
  }

  factory StudentProfile.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime? parseDate(dynamic raw) {
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw);
      return null;
    }

    List<int> parseIntList(dynamic raw) {
      if (raw is List) {
        return raw.whereType<num>().map((e) => e.toInt()).toList();
      }
      return const [];
    }

    List<String> parseStringList(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return const [];
    }

    Map<int, String> parseJuzStatuses(dynamic raw) {
      if (raw is Map) {
        final result = <int, String>{};
        raw.forEach((key, value) {
          final k = int.tryParse(key.toString());
          if (k != null && value != null) {
            result[k] = value.toString();
          }
        });
        return result;
      }
      return const {};
    }

    Map<int, DateTime> parseLastRevisedDates(dynamic raw) {
      if (raw is Map) {
        final result = <int, DateTime>{};
        raw.forEach((key, value) {
          final k = int.tryParse(key.toString());
          final dt = parseDate(value);
          if (k != null && dt != null) {
            result[k] = dt;
          }
        });
        return result;
      }
      return const {};
    }

    return StudentProfile(
      id: id ?? (map['id'] as String? ?? ''),
      fullName:
          (map['fullName'] ?? map['full_name'] ?? map['name'] ?? '') as String,
      parentId: (map['parentId'] ?? map['parent_id'] ?? '') as String,
      parentName: (map['parentName'] ?? map['parent_name']) as String?,
      userId: (map['userId'] ?? map['user_id']) as String?,
      email: map['email'] as String?,
      phoneNumber:
          (map['phoneNumber'] ?? map['phone_number'] ?? map['phone'])
              as String?,
      dateOfBirth: parseDate(map['dateOfBirth'] ?? map['date_of_birth']),
      memorizedPages:
          parseIntList(map['memorizedPages'] ?? map['memorized_pages']),
      completedSurahs:
          parseIntList(map['completedSurahs'] ?? map['completed_surahs']),
      completedJuz: parseIntList(map['completedJuz'] ?? map['completed_juz']),
      memorizedCenterUnits: parseStringList(
        map['memorizedCenterUnits'] ?? map['memorized_center_units'],
      ),
      juzStatuses:
          parseJuzStatuses(map['juzStatuses'] ?? map['juz_statuses']),
      lastRevisedJuzDates: parseLastRevisedDates(
        map['lastRevisedJuzDates'] ?? map['last_revised_juz_dates'],
      ),
      isArchived: (map['isArchived'] ?? map['is_archived'] ?? false) == true,
      createdAt: parseDate(map['createdAt'] ?? map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'parentId': parentId,
      'parentName': parentName,
      'userId': userId,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'memorizedPages': memorizedPages,
      'completedSurahs': completedSurahs,
      'completedJuz': completedJuz,
      'memorizedCenterUnits': memorizedCenterUnits,
      'juzStatuses': juzStatuses.map((k, v) => MapEntry(k.toString(), v)),
      'lastRevisedJuzDates': lastRevisedJuzDates.map(
        (k, v) => MapEntry(k.toString(), Timestamp.fromDate(v)),
      ),
      'isArchived': isArchived,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}

/// Utility for parsing and localizing weekly schedule days and times.
class ScheduleDayHelper {
  ScheduleDayHelper._();

  /// Standard center week order: Sunday (7) .. Saturday (6).
  static const List<int> centerWeekOrder = [
    DateTime.sunday,
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
  ];

  static String normalizeDigits(String input) {
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var out = input;
    for (var i = 0; i < eastern.length; i++) {
      out = out.replaceAll(eastern[i], '$i');
    }
    return out;
  }

  /// Parses an Arabic, Hebrew, or English day string (or substring) into `DateTime.weekday` (`1..7`).
  static int? parseWeekday(String raw) {
    final text = raw.trim().toLowerCase();
    if (text.isEmpty) return null;

    if (text.contains('سبت') ||
        text.contains('שבת') ||
        text.contains('saturday') ||
        RegExp(r'\bsat\b').hasMatch(text)) {
      return DateTime.saturday;
    }
    if (text.contains('أحد') ||
        text.contains('احد') ||
        text.contains('ראשון') ||
        text.contains('sunday') ||
        RegExp(r'\bsun\b').hasMatch(text)) {
      return DateTime.sunday;
    }
    if (text.contains('إثنين') ||
        text.contains('اثنين') ||
        text.contains('שני') ||
        text.contains('monday') ||
        RegExp(r'\bmon\b').hasMatch(text)) {
      return DateTime.monday;
    }
    if (text.contains('ثلاثاء') ||
        text.contains('שלישי') ||
        text.contains('tuesday') ||
        RegExp(r'\btue\b').hasMatch(text)) {
      return DateTime.tuesday;
    }
    if (text.contains('أربعاء') ||
        text.contains('اربعاء') ||
        text.contains('רביעי') ||
        text.contains('wednesday') ||
        RegExp(r'\bwed\b').hasMatch(text)) {
      return DateTime.wednesday;
    }
    if (text.contains('خميس') ||
        text.contains('חמישי') ||
        text.contains('thursday') ||
        RegExp(r'\bthu\b').hasMatch(text)) {
      return DateTime.thursday;
    }
    if (text.contains('جمعة') ||
        text.contains('جمعه') ||
        text.contains('שישי') ||
        text.contains('friday') ||
        RegExp(r'\bfri\b').hasMatch(text)) {
      return DateTime.friday;
    }
    return null;
  }

  static String canonicalArabicDay(int weekday) {
    switch (weekday) {
      case DateTime.saturday:
        return 'السبت';
      case DateTime.sunday:
        return 'الأحد';
      case DateTime.monday:
        return 'الاثنين';
      case DateTime.tuesday:
        return 'الثلاثاء';
      case DateTime.wednesday:
        return 'الأربعاء';
      case DateTime.thursday:
        return 'الخميس';
      case DateTime.friday:
        return 'الجمعة';
      default:
        return 'الأحد';
    }
  }

  static String localizedDayName(int weekday, String langCode) {
    switch (weekday) {
      case DateTime.monday:
        if (langCode == 'he') return 'יום שני';
        if (langCode == 'en') return 'Monday';
        return 'الاثنين';
      case DateTime.tuesday:
        if (langCode == 'he') return 'יום שלישי';
        if (langCode == 'en') return 'Tuesday';
        return 'الثلاثاء';
      case DateTime.wednesday:
        if (langCode == 'he') return 'יום רביעי';
        if (langCode == 'en') return 'Wednesday';
        return 'الأربعاء';
      case DateTime.thursday:
        if (langCode == 'he') return 'יום חמישי';
        if (langCode == 'en') return 'Thursday';
        return 'الخميس';
      case DateTime.friday:
        if (langCode == 'he') return 'יום שישי';
        if (langCode == 'en') return 'Friday';
        return 'الجمعة';
      case DateTime.saturday:
        if (langCode == 'he') return 'שבת';
        if (langCode == 'en') return 'Saturday';
        return 'السبت';
      case DateTime.sunday:
      default:
        if (langCode == 'he') return 'יום ראשון';
        if (langCode == 'en') return 'Sunday';
        return 'الأحد';
    }
  }

  static String localizedShortDayName(int weekday, String langCode) {
    switch (weekday) {
      case DateTime.monday:
        if (langCode == 'he') return 'ב׳';
        if (langCode == 'en') return 'Mon';
        return 'إثنين';
      case DateTime.tuesday:
        if (langCode == 'he') return 'ג׳';
        if (langCode == 'en') return 'Tue';
        return 'ثلاثاء';
      case DateTime.wednesday:
        if (langCode == 'he') return 'ד׳';
        if (langCode == 'en') return 'Wed';
        return 'أربعاء';
      case DateTime.thursday:
        if (langCode == 'he') return 'ה׳';
        if (langCode == 'en') return 'Thu';
        return 'خميس';
      case DateTime.friday:
        if (langCode == 'he') return 'ו׳';
        if (langCode == 'en') return 'Fri';
        return 'جمعة';
      case DateTime.saturday:
        if (langCode == 'he') return 'ש׳';
        if (langCode == 'en') return 'Sat';
        return 'سبت';
      case DateTime.sunday:
      default:
        if (langCode == 'he') return 'א׳';
        if (langCode == 'en') return 'Sun';
        return 'أحد';
    }
  }

  static int parseTimeToMinutes(String raw) {
    final normalized = normalizeDigits(raw);
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(normalized);
    if (match == null) return 24 * 60;
    final h = int.tryParse(match.group(1)!) ?? 0;
    final m = int.tryParse(match.group(2)!) ?? 0;
    return (h * 60) + m;
  }

  /// Parses an Enrollment `oneOnOneSlotTime` string (e.g. `'الخميس 17:15 (فردي)'`)
  /// into `(weekday, timeLabel, sortMinutes)`.
  static ({int? weekday, String timeLabel, int sortMinutes}) parseOneOnOneSlot(
    String raw,
  ) {
    final trimmed = raw.trim();
    final weekday = parseWeekday(trimmed);
    final normalized = normalizeDigits(trimmed);
    final timeMatch = RegExp(r'(\d{1,2}:\d{2})').firstMatch(normalized);
    final timeLabel = timeMatch?.group(1) ?? trimmed;
    final sortMinutes = parseTimeToMinutes(timeLabel);
    return (weekday: weekday, timeLabel: timeLabel, sortMinutes: sortMinutes);
  }
}

/// Represents a single day+time session slot for a [StudyGroup].
class GroupScheduleSlot {
  final String day;
  final String startTime;
  final String endTime;

  const GroupScheduleSlot({
    required this.day,
    this.startTime = '',
    this.endTime = '',
  });

  int? get weekday => ScheduleDayHelper.parseWeekday(day);

  int get sortMinutes => ScheduleDayHelper.parseTimeToMinutes(startTime);

  String formatTimeRange() {
    final s = startTime.trim();
    final e = endTime.trim();
    if (s.isNotEmpty && e.isNotEmpty) return '$s - $e';
    return s.isNotEmpty ? s : e;
  }

  GroupScheduleSlot copyWith({
    String? day,
    String? startTime,
    String? endTime,
  }) {
    return GroupScheduleSlot(
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  factory GroupScheduleSlot.fromMap(Map<String, dynamic> map) {
    return GroupScheduleSlot(
      day: (map['day'] ?? '') as String,
      startTime: (map['startTime'] ?? map['start_time'] ?? '') as String,
      endTime: (map['endTime'] ?? map['end_time'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

/// Represents a class group in the `groups` Firestore collection.
class StudyGroup {
  final String id;
  final String name;
  final CenterTrack track;
  final String teacherId;
  final String teacherName;
  final List<String> scheduleDays;
  final String startTime;
  final String endTime;
  final List<GroupScheduleSlot> scheduleSlots;
  final int capacity;
  final bool isArchived;
  final DateTime? createdAt;

  const StudyGroup({
    required this.id,
    required this.name,
    required this.track,
    required this.teacherId,
    this.teacherName = '',
    this.scheduleDays = const [],
    this.startTime = '',
    this.endTime = '',
    this.scheduleSlots = const [],
    this.capacity = 15,
    this.isArchived = false,
    this.createdAt,
  });

  /// Returns per-day slots, synthesizing from legacy [scheduleDays]/[startTime]/[endTime]
  /// when [scheduleSlots] is empty.
  List<GroupScheduleSlot> get effectiveScheduleSlots {
    if (scheduleSlots.isNotEmpty) return scheduleSlots;
    return scheduleDays
        .map(
          (d) => GroupScheduleSlot(
            day: d,
            startTime: startTime,
            endTime: endTime,
          ),
        )
        .toList();
  }

  List<GroupScheduleSlot> slotsForWeekday(int weekday) {
    return effectiveScheduleSlots
        .where((s) => s.weekday == weekday)
        .toList()
      ..sort((a, b) => a.sortMinutes.compareTo(b.sortMinutes));
  }

  String formatScheduleSummary(String langCode, {bool multiline = false}) {
    final slots = effectiveScheduleSlots;
    if (slots.isEmpty) {
      if (startTime.isEmpty) return '';
      return endTime.isNotEmpty ? '$startTime - $endTime' : startTime;
    }

    String dayLabel(GroupScheduleSlot s) {
      final wd = s.weekday;
      return wd != null ? ScheduleDayHelper.localizedDayName(wd, langCode) : s.day;
    }

    final firstRange = slots.first.formatTimeRange();
    final allSameRange =
        slots.every((s) => s.formatTimeRange() == firstRange);

    if (!multiline && allSameRange) {
      final daysText = slots.map(dayLabel).join(' • ');
      return firstRange.isNotEmpty ? '$daysText • $firstRange' : daysText;
    }

    final parts = slots.map((s) {
      final d = dayLabel(s);
      final r = s.formatTimeRange();
      if (multiline) {
        return r.isNotEmpty ? '$d • $r' : d;
      }
      return r.isNotEmpty ? '$d ($r)' : d;
    }).toList();
    return parts.join(multiline ? '\n' : ' • ');
  }

  StudyGroup copyWith({
    String? id,
    String? name,
    CenterTrack? track,
    String? teacherId,
    String? teacherName,
    List<String>? scheduleDays,
    String? startTime,
    String? endTime,
    List<GroupScheduleSlot>? scheduleSlots,
    int? capacity,
    DateTime? createdAt,
  }) {
    return StudyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      track: track ?? this.track,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      scheduleDays: scheduleDays ?? this.scheduleDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      scheduleSlots: scheduleSlots ?? this.scheduleSlots,
      capacity: capacity ?? this.capacity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory StudyGroup.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return StudyGroup.fromMap(data, id: doc.id);
  }

  factory StudyGroup.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawCreatedAt = map['createdAt'] ?? map['created_at'];
    DateTime? parsedCreatedAt;
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt);
    }

    final rawDays = map['scheduleDays'] ?? map['schedule_days'];
    final days = rawDays is List
        ? rawDays.map((e) => e.toString()).toList()
        : <String>[];

    final rawSlots = map['scheduleSlots'] ?? map['schedule_slots'];
    final slots = rawSlots is List
        ? rawSlots
            .whereType<Map>()
            .map(
              (m) => GroupScheduleSlot.fromMap(Map<String, dynamic>.from(m)),
            )
            .toList()
        : <GroupScheduleSlot>[];

    final resolvedDays =
        days.isNotEmpty ? days : slots.map((s) => s.day).toList();
    final rawStart = (map['startTime'] ?? map['start_time'] ?? '') as String;
    final rawEnd = (map['endTime'] ?? map['end_time'] ?? '') as String;

    return StudyGroup(
      id: id ?? (map['id'] as String? ?? ''),
      name: (map['name'] ?? '') as String,
      track: CenterTrack.fromString(map['track'] as String?),
      teacherId: (map['teacherId'] ?? map['teacher_id'] ?? '') as String,
      teacherName: (map['teacherName'] ?? map['teacher_name'] ?? '') as String,
      scheduleDays: resolvedDays,
      startTime:
          rawStart.isNotEmpty ? rawStart : (slots.firstOrNull?.startTime ?? ''),
      endTime: rawEnd.isNotEmpty ? rawEnd : (slots.firstOrNull?.endTime ?? ''),
      scheduleSlots: slots,
      capacity: (map['capacity'] as num?)?.toInt() ?? 15,
      isArchived: (map['isArchived'] ?? map['is_archived'] ?? false) == true,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final resolvedSlots = effectiveScheduleSlots;
    final resolvedDays = scheduleDays.isNotEmpty
        ? scheduleDays
        : resolvedSlots.map((s) => s.day).toList();
    final resolvedStart = startTime.isNotEmpty
        ? startTime
        : (resolvedSlots.firstOrNull?.startTime ?? '');
    final resolvedEnd = endTime.isNotEmpty
        ? endTime
        : (resolvedSlots.firstOrNull?.endTime ?? '');

    return {
      'id': id,
      'name': name,
      'track': track.toJson(),
      'teacherId': teacherId,
      'teacherName': teacherName,
      'scheduleDays': resolvedDays,
      'startTime': resolvedStart,
      'endTime': resolvedEnd,
      'scheduleSlots': resolvedSlots.map((s) => s.toMap()).toList(),
      'capacity': capacity,
      'isArchived': isArchived,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}

/// Represents a student-to-group enrollment in the `enrollments` Firestore collection.
class Enrollment {
  final String id;
  final String studentId;
  final String studentName;
  final String groupId;
  final String groupName;
  final CenterTrack track;
  final String? oneOnOneSlotTime;
  final String? groupArrivalTime;
  final DateTime? createdAt;

  const Enrollment({
    required this.id,
    required this.studentId,
    this.studentName = '',
    required this.groupId,
    this.groupName = '',
    this.track = CenterTrack.hifz,
    this.oneOnOneSlotTime,
    this.groupArrivalTime,
    this.createdAt,
  });

  factory Enrollment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return Enrollment.fromMap(data, id: doc.id);
  }

  factory Enrollment.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawCreatedAt = map['createdAt'] ?? map['created_at'];
    DateTime? parsedCreatedAt;
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt);
    }

    return Enrollment(
      id: id ?? (map['id'] as String? ?? ''),
      studentId: (map['studentId'] ?? map['student_id'] ?? '') as String,
      studentName: (map['studentName'] ?? map['student_name'] ?? '') as String,
      groupId: (map['groupId'] ?? map['group_id'] ?? '') as String,
      groupName: (map['groupName'] ?? map['group_name'] ?? '') as String,
      track: CenterTrack.fromString(map['track'] as String?),
      oneOnOneSlotTime:
          (map['oneOnOneSlotTime'] ?? map['one_on_one_slot_time']) as String?,
      groupArrivalTime:
          (map['groupArrivalTime'] ?? map['group_arrival_time']) as String?,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'groupId': groupId,
      'groupName': groupName,
      'track': track.toJson(),
      'oneOnOneSlotTime': oneOnOneSlotTime,
      'groupArrivalTime': groupArrivalTime,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
