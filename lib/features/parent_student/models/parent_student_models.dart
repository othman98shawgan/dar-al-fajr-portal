import '../../admin/models/admin_models.dart';
import '../../hifz/models/teacher_models.dart';

/// Represents a single row in the Parent/Student Weekly Arrival Schedule.
class ChildScheduleSlot {
  final String dayAbbrev;
  final String dayName;
  final String dateLabel;
  final String statusLabel;
  final bool isCompleted;
  final String trackBadgeLabel;
  final bool isTertiaryTrackBadge;
  final String sessionModeLabel;
  final bool isOneOnOne;
  final String arrivalTime;

  const ChildScheduleSlot({
    required this.dayAbbrev,
    required this.dayName,
    required this.dateLabel,
    required this.statusLabel,
    required this.isCompleted,
    required this.trackBadgeLabel,
    this.isTertiaryTrackBadge = false,
    required this.sessionModeLabel,
    required this.isOneOnOne,
    required this.arrivalTime,
  });
}

/// Represents an in-progress Surah card on the Progress Summary tab.
class InProgressSurahData {
  final int surahNumber;
  final String surahName;
  final int fromAyah;
  final int toAyah;
  final int totalVerses;
  final String expectedCompletionLabel;

  const InProgressSurahData({
    required this.surahNumber,
    required this.surahName,
    required this.fromAyah,
    required this.toAyah,
    required this.totalVerses,
    required this.expectedCompletionLabel,
  });

  double get progressFraction =>
      totalVerses > 0 ? (toAyah / totalVerses).clamp(0.0, 1.0) : 0.0;

  int get progressPercent => (progressFraction * 100).round();

  int get remainingVerses => (totalVerses - toAyah).clamp(0, totalVerses);
}

/// Represents an in-progress Juz' item on the Progress Summary tab.
class InProgressJuzData {
  final int juzNumber;
  final String juzTitle;
  final int completedPages;
  final int totalPages;
  final String startedDateLabel;
  final bool isActive;

  const InProgressJuzData({
    required this.juzNumber,
    required this.juzTitle,
    required this.completedPages,
    this.totalPages = 21,
    required this.startedDateLabel,
    this.isActive = true,
  });

  double get progressFraction =>
      totalPages > 0 ? (completedPages / totalPages).clamp(0.0, 1.0) : 0.0;

  int get progressPercent => (progressFraction * 100).round();

  int get remainingPages => (totalPages - completedPages).clamp(0, totalPages);
}

/// Consolidated view-model for a single child in the Parent/Student portal.
class ChildPortalProfile {
  final String id;
  final String shortName;
  final String fullName;
  final String groupName;
  final String teacherName;
  final String periodLabel;
  final int attendancePercent;
  final String streakBannerTitle;
  final String streakDaysLabel;

  // Progress KPIs (out of 604 pages, 114 surahs, 30 ajzaa)
  final int memorizedPagesCount;
  final int completedSurahsCount;
  final int completedJuzCount;
  final String completedJuzSubtitle;
  final String motivationalBannerHighlight;
  final String motivationalBannerBody;

  // Latest recorded audio recitation
  final String lastRecitationTitle;
  final String lastRecitationNote;
  final String lastRecitationScore;
  final String lastRecitationDuration;
  final String lastRecitationWhen;

  // In-progress Surahs & Ajzaa
  final List<InProgressSurahData> inProgressSurahs;
  final List<InProgressJuzData> inProgressAjzaa;
  final List<String> completedSurahNames;

  // Weekly Schedule & Assignments
  final List<ChildScheduleSlot> weeklySchedule;
  final String newHifzSurah;
  final String newHifzAyahRange;
  final String newHifzPagesLabel;
  final double newHifzProgress;
  final String newHifzStatusLeft;
  final String newHifzStatusRight;

  final String revisionSurah;
  final String revisionAyahRange;
  final String revisionHizbLabel;
  final double revisionProgress;
  final String revisionStatusLeft;
  final String revisionStatusRight;

  final String weeklyGradeLabel;
  final int weeklyStarsCount;
  final String teacherNoteAuthor;
  final String teacherNoteText;
  final String teacherVoiceDuration;

  final StudentProfile? firestoreStudent;
  final List<Enrollment> firestoreEnrollments;
  final List<AttendanceLog> firestoreAttendance;
  final List<HifzAssignment> firestoreAssignments;

  const ChildPortalProfile({
    required this.id,
    required this.shortName,
    required this.fullName,
    required this.groupName,
    required this.teacherName,
    required this.periodLabel,
    required this.attendancePercent,
    required this.streakBannerTitle,
    required this.streakDaysLabel,
    required this.memorizedPagesCount,
    required this.completedSurahsCount,
    required this.completedJuzCount,
    required this.completedJuzSubtitle,
    required this.motivationalBannerHighlight,
    required this.motivationalBannerBody,
    required this.lastRecitationTitle,
    required this.lastRecitationNote,
    required this.lastRecitationScore,
    required this.lastRecitationDuration,
    required this.lastRecitationWhen,
    required this.inProgressSurahs,
    required this.inProgressAjzaa,
    required this.completedSurahNames,
    required this.weeklySchedule,
    required this.newHifzSurah,
    required this.newHifzAyahRange,
    required this.newHifzPagesLabel,
    required this.newHifzProgress,
    required this.newHifzStatusLeft,
    required this.newHifzStatusRight,
    required this.revisionSurah,
    required this.revisionAyahRange,
    required this.revisionHizbLabel,
    required this.revisionProgress,
    required this.revisionStatusLeft,
    required this.revisionStatusRight,
    required this.weeklyGradeLabel,
    this.weeklyStarsCount = 5,
    required this.teacherNoteAuthor,
    required this.teacherNoteText,
    required this.teacherVoiceDuration,
    this.firestoreStudent,
    this.firestoreEnrollments = const [],
    this.firestoreAttendance = const [],
    this.firestoreAssignments = const [],
  });

  double get overallQuranPercentage =>
      ((memorizedPagesCount / 604.0) * 100.0).clamp(0.0, 100.0);

  double get surahsProgressFraction =>
      (completedSurahsCount / 114.0).clamp(0.0, 1.0);

  double get juzProgressFraction =>
      (completedJuzCount / 30.0).clamp(0.0, 1.0);
}
