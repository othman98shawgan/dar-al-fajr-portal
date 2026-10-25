import 'package:cloud_firestore/cloud_firestore.dart';

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
    this.createdAt,
  });

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
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
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
    this.createdAt,
  });

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

    return StudyGroup(
      id: id ?? (map['id'] as String? ?? ''),
      name: (map['name'] ?? '') as String,
      track: CenterTrack.fromString(map['track'] as String?),
      teacherId: (map['teacherId'] ?? map['teacher_id'] ?? '') as String,
      teacherName: (map['teacherName'] ?? map['teacher_name'] ?? '') as String,
      scheduleDays: days,
      startTime: (map['startTime'] ?? map['start_time'] ?? '') as String,
      endTime: (map['endTime'] ?? map['end_time'] ?? '') as String,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'track': track.toJson(),
      'teacherId': teacherId,
      'teacherName': teacherName,
      'scheduleDays': scheduleDays,
      'startTime': startTime,
      'endTime': endTime,
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
