import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/surah_page_map.dart';
import '../../../core/services/quran_metadata_service.dart';
import '../../admin/models/admin_models.dart';
import '../models/teacher_models.dart';

class TeacherRepository {
  static const String groupsCollection = 'groups';
  static const String enrollmentsCollection = 'enrollments';
  static const String studentsCollection = 'students';
  static const String attendanceCollection = 'attendance_logs';
  static const String assignmentsCollection = 'hifz_assignments';
  static const String revisionPlansCollection = 'weekly_revision_plans';
  static const String settingsCollection = 'settings';
  static const String gradingConfigDocId = 'grading_config';

  final FirebaseFirestore _firestore;
  final QuranMetadataService quranService;

  TeacherRepository({
    FirebaseFirestore? firestore,
    required this.quranService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Grading Penalty Config (Admin Configurable)
  // ---------------------------------------------------------------------------

  Stream<GradingPenaltyConfig> watchGradingPenaltyConfig() {
    return _firestore
        .collection(settingsCollection)
        .doc(gradingConfigDocId)
        .snapshots()
        .map((doc) => GradingPenaltyConfig.fromMap(doc.data()));
  }

  Future<void> saveGradingPenaltyConfig(GradingPenaltyConfig config) async {
    await _firestore
        .collection(settingsCollection)
        .doc(gradingConfigDocId)
        .set(config.toMap(), SetOptions(merge: true));
  }

  // ---------------------------------------------------------------------------
  // Teacher Groups & Roster
  // ---------------------------------------------------------------------------

  Stream<List<StudyGroup>> watchTeacherGroups(String teacherId) {
    if (teacherId.trim().isEmpty) {
      return watchAllGroups();
    }
    return _firestore
        .collection(groupsCollection)
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StudyGroup.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<StudyGroup>> watchAllGroups() {
    return _firestore.collection(groupsCollection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => StudyGroup.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<Enrollment>> watchGroupEnrollments(String groupId) {
    return _firestore
        .collection(enrollmentsCollection)
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Enrollment.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<StudentProfile?> watchStudentProfile(String studentId) {
    if (studentId.trim().isEmpty) {
      return Stream<StudentProfile?>.value(null);
    }
    return _firestore
        .collection(studentsCollection)
        .doc(studentId)
        .snapshots()
        .map((doc) => doc.exists ? StudentProfile.fromFirestore(doc) : null);
  }

  Stream<List<StudentProfile>> watchAllStudents() {
    return _firestore.collection(studentsCollection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => StudentProfile.fromFirestore(doc))
              .toList(),
        );
  }

  // ---------------------------------------------------------------------------
  // Multi-Mode Attendance Logging (Group & 1-on-1)
  // ---------------------------------------------------------------------------

  Stream<List<AttendanceLog>> watchGroupAttendance(String groupId) {
    return _firestore
        .collection(attendanceCollection)
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceLog.fromFirestore(doc))
              .toList(),
        );
  }

  Future<AttendanceLog> logAttendance({
    required String groupId,
    required String studentId,
    required String studentName,
    required String teacherId,
    required AttendanceStatus status,
    SessionMode sessionMode = SessionMode.group,
    DateTime? sessionDate,
    String? notes,
  }) async {
    final docRef = _firestore.collection(attendanceCollection).doc();
    final log = AttendanceLog(
      id: docRef.id,
      groupId: groupId,
      studentId: studentId,
      studentName: studentName,
      teacherId: teacherId,
      sessionDate: sessionDate ?? DateTime.now(),
      sessionMode: sessionMode,
      status: status,
      notes: notes,
      createdAt: DateTime.now(),
    );

    await docRef.set(log.toMap());
    return log;
  }

  Future<void> saveBatchAttendance({
    required String groupId,
    required String teacherId,
    required Map<String, AttendanceStatus> studentStatuses,
    Map<String, String>? studentNames,
    SessionMode sessionMode = SessionMode.group,
    DateTime? sessionDate,
  }) async {
    final batch = _firestore.batch();
    final now = sessionDate ?? DateTime.now();

    for (final entry in studentStatuses.entries) {
      final docRef = _firestore.collection(attendanceCollection).doc();
      final log = AttendanceLog(
        id: docRef.id,
        groupId: groupId,
        studentId: entry.key,
        studentName: studentNames?[entry.key] ?? '',
        teacherId: teacherId,
        sessionDate: now,
        sessionMode: sessionMode,
        status: entry.value,
        createdAt: now,
      );
      batch.set(docRef, log.toMap());
    }

    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // Hifz & Revision Assignment Engine + Automated Progress Calculation
  // ---------------------------------------------------------------------------

  Stream<List<HifzAssignment>> watchStudentAssignments(String studentId) {
    return _firestore
        .collection(assignmentsCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HifzAssignment.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<HifzAssignment>> watchGroupAssignments(String groupId) {
    return _firestore
        .collection(assignmentsCollection)
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HifzAssignment.fromFirestore(doc))
              .toList(),
        );
  }

  Future<HifzAssignment> saveHifzAssignment({
    String? existingAssignmentId,
    required String studentId,
    required String studentName,
    required String groupId,
    required String teacherId,
    required AssignmentType type,
    required int surahId,
    required String surahName,
    required int fromAyah,
    required int toAyah,
    required EvaluationGrade grade,
    String teacherNotes = '',
    int? targetPage,
    int? juzNumber,
    int? score,
    int lafziCount = 0,
    int fathCount = 0,
    int tataaCount = 0,
    bool isPartialRead = false,
    bool isJuzExam = false,
    bool forceRepeat = false,
    List<TasmeeRecitationUnit> recitationUnits = const [],
    bool autoCreateNextAssignment = false,
    int? nextSurahId,
    String? nextSurahName,
    int? nextPage,
    int? nextFromAyah,
    int? nextToAyah,
  }) async {
    if (quranService.surahs.isEmpty) {
      try {
        await quranService.loadMetadata();
      } catch (_) {}
    }

    final surahDef = CenterQuranMap.getSurahById(surahId);
    List<int> pages = quranService.calculatePages(surahId, fromAyah, toAyah);
    List<int> juzList = quranService.calculateJuz(surahId, fromAyah, toAyah);

    if (pages.isEmpty) {
      if (targetPage != null) {
        pages = [targetPage];
      } else if (surahDef.isJuz30 ||
          (fromAyah <= 1 && toAyah >= surahDef.totalVerses)) {
        pages = surahDef.pages;
      } else {
        pages = [surahDef.startPage];
      }
    }
    if (juzList.isEmpty) {
      if (juzNumber != null) {
        juzList = [juzNumber];
      } else {
        juzList = [surahDef.primaryJuz];
      }
    }

    // Also include pages & juz from any additional recitation units
    final allPages = <int>{...pages};
    final allJuz = <int>{...juzList};
    for (final unit in recitationUnits) {
      if (unit.pageNumber != null) {
        allPages.add(unit.pageNumber!);
        allJuz.add(CenterQuranMap.getJuzForPage(unit.pageNumber!));
      } else if (unit.unitType == RecitationUnitType.surah) {
        final uSurah = CenterQuranMap.getSurahById(unit.surahId);
        allPages.addAll(uSurah.pages);
        allJuz.add(uSurah.primaryJuz);
      } else if (unit.unitType == RecitationUnitType.juzExam &&
          unit.juzNumber != null) {
        allJuz.add(unit.juzNumber!);
      }
    }

    final docRef = (existingAssignmentId != null &&
            existingAssignmentId.trim().isNotEmpty)
        ? _firestore.collection(assignmentsCollection).doc(existingAssignmentId)
        : _firestore.collection(assignmentsCollection).doc();
    final now = DateTime.now();

    final resolvedSurahName =
        surahName.trim().isNotEmpty ? surahName.trim() : surahDef.nameAr;

    final assignment = HifzAssignment(
      id: docRef.id,
      studentId: studentId,
      studentName: studentName.trim(),
      groupId: groupId,
      teacherId: teacherId,
      type: type,
      surahId: surahId,
      surahName: resolvedSurahName,
      fromAyah: fromAyah,
      toAyah: toAyah,
      targetPage: targetPage,
      juzNumber: juzNumber,
      touchedPages: allPages.toList()..sort(),
      touchedJuz: allJuz.toList()..sort(),
      grade: grade,
      score: isPartialRead ? null : score,
      lafziCount: lafziCount,
      fathCount: fathCount,
      tataaCount: tataaCount,
      isPartialRead: isPartialRead,
      isJuzExam: isJuzExam,
      forceRepeat: forceRepeat,
      recitationUnits: recitationUnits,
      teacherNotes: teacherNotes.trim(),
      assignedAt: now,
      evaluatedAt:
          (grade != EvaluationGrade.pending || isPartialRead) ? now : null,
    );

    await docRef.set(assignment.toMap(), SetOptions(merge: true));

    // Automatically update student's memorized pages, surahs, center units & Juz lifecycle
    if (!isPartialRead && grade.isPassed) {
      final studentUpdates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final passedPages = <int>{};
      final passedSurahs = <int>{};
      final passedJuzExams = <int>{};
      final passedCenterUnits = <String>{};

      if (recitationUnits.isNotEmpty) {
        const defaultConfig = GradingPenaltyConfig();
        for (final unit in recitationUnits) {
          if (!unit.isPassed(defaultConfig)) continue;
          final uSurah = CenterQuranMap.getSurahById(unit.surahId);
          if (unit.unitType == RecitationUnitType.surah || uSurah.isJuz30) {
            passedSurahs.add(uSurah.id);
            passedPages.addAll(uSurah.pages);
            if (uSurah.isJuz30) {
              passedCenterUnits.add('s${uSurah.id}');
            } else {
              for (final p in uSurah.pages) {
                passedCenterUnits.add('s${uSurah.id}_p$p');
              }
            }
          } else if (unit.unitType == RecitationUnitType.page) {
            final p = unit.pageNumber ?? uSurah.startPage;
            passedPages.add(p);
            passedCenterUnits.add('s${uSurah.id}_p$p');
            if (uSurah.pages.length == 1) {
              passedSurahs.add(uSurah.id);
            }
          } else if (unit.unitType == RecitationUnitType.juzExam) {
            final j = unit.juzNumber ?? uSurah.primaryJuz;
            passedJuzExams.add(j);
          }
        }
      } else {
        if (isJuzExam || type == AssignmentType.revision) {
          final j = juzNumber ?? surahDef.primaryJuz;
          passedJuzExams.add(j);
        } else {
          passedPages.addAll(pages);
          final isFullSurahCompleted = surahDef.isJuz30 ||
              (fromAyah <= 1 && toAyah >= surahDef.totalVerses);
          if (isFullSurahCompleted) {
            passedSurahs.add(surahId);
            if (surahDef.isJuz30) {
              passedCenterUnits.add('s$surahId');
            } else {
              for (final p in surahDef.pages) {
                passedCenterUnits.add('s${surahId}_p$p');
              }
            }
          } else {
            for (final p in pages) {
              passedCenterUnits.add('s${surahId}_p$p');
            }
          }
        }
      }

      if (passedPages.isNotEmpty) {
        studentUpdates['memorizedPages'] =
            FieldValue.arrayUnion(passedPages.toList());
      }
      if (passedSurahs.isNotEmpty) {
        studentUpdates['completedSurahs'] =
            FieldValue.arrayUnion(passedSurahs.toList());
      }
      if (passedCenterUnits.isNotEmpty) {
        studentUpdates['memorizedCenterUnits'] =
            FieldValue.arrayUnion(passedCenterUnits.toList());
      }
      if (passedJuzExams.isNotEmpty) {
        studentUpdates['completedJuz'] =
            FieldValue.arrayUnion(passedJuzExams.toList());
        final juzStatusMap = <String, String>{};
        final revisedDatesMap = <String, Timestamp>{};
        for (final j in passedJuzExams) {
          juzStatusMap[j.toString()] = JuzProgressStatus.passedExam.toJson();
          revisedDatesMap[j.toString()] = Timestamp.fromDate(now);
        }
        studentUpdates['juzStatuses'] = juzStatusMap;
        studentUpdates['lastRevisedJuzDates'] = revisedDatesMap;
      } else if (juzList.isNotEmpty && type == AssignmentType.newHifz) {
        studentUpdates['completedJuz'] = FieldValue.arrayUnion(juzList);
      }

      await _firestore.collection(studentsCollection).doc(studentId).set(
            studentUpdates,
            SetOptions(merge: true),
          );
    }

    // Create next pending assignment if requested (either suggested next page/surah on pass, or rollover on repeat)
    if (autoCreateNextAssignment && nextSurahId != null) {
      final nextDef = CenterQuranMap.getSurahById(nextSurahId);
      final nextDocRef = _firestore.collection(assignmentsCollection).doc();
      final nextAssignment = HifzAssignment(
        id: nextDocRef.id,
        studentId: studentId,
        studentName: studentName.trim(),
        groupId: groupId,
        teacherId: teacherId,
        type: AssignmentType.newHifz,
        surahId: nextDef.id,
        surahName: (nextSurahName != null && nextSurahName.trim().isNotEmpty)
            ? nextSurahName.trim()
            : nextDef.nameAr,
        fromAyah: nextFromAyah ?? 1,
        toAyah: nextToAyah ?? nextDef.totalVerses,
        targetPage: nextPage ?? nextDef.startPage,
        juzNumber: nextDef.primaryJuz,
        touchedPages: [nextPage ?? nextDef.startPage],
        touchedJuz: [nextDef.primaryJuz],
        grade: EvaluationGrade.pending,
        assignedAt: now.add(const Duration(seconds: 1)),
      );
      await nextDocRef.set(nextAssignment.toMap());
    }

    return assignment;
  }

  // ---------------------------------------------------------------------------
  // Weekly Revision Plans & Spaced Repetition (LRU Priority Queue)
  // ---------------------------------------------------------------------------

  Stream<List<WeeklyRevisionPlan>> watchStudentWeeklyPlans(String studentId) {
    if (studentId.trim().isEmpty) {
      return Stream<List<WeeklyRevisionPlan>>.value(const []);
    }
    return _firestore
        .collection(revisionPlansCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WeeklyRevisionPlan.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<WeeklyRevisionPlan>> watchGroupWeeklyPlans(String groupId) {
    if (groupId.trim().isEmpty) {
      return Stream<List<WeeklyRevisionPlan>>.value(const []);
    }
    return _firestore
        .collection(revisionPlansCollection)
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WeeklyRevisionPlan.fromFirestore(doc))
              .toList(),
        );
  }

  Future<WeeklyRevisionPlan> saveWeeklyRevisionPlan({
    String? existingPlanId,
    required String studentId,
    required String studentName,
    required String groupId,
    required String teacherId,
    required DateTime weekStartDate,
    required List<DailyRevisionTask> dailyTasks,
  }) async {
    final docRef =
        (existingPlanId != null && existingPlanId.trim().isNotEmpty)
            ? _firestore.collection(revisionPlansCollection).doc(existingPlanId)
            : _firestore
                .collection(revisionPlansCollection)
                .doc('${studentId}_${weekStartDate.year}_${weekStartDate.month}_${weekStartDate.day}');
    final now = DateTime.now();
    final plan = WeeklyRevisionPlan(
      id: docRef.id,
      studentId: studentId,
      studentName: studentName.trim(),
      groupId: groupId,
      teacherId: teacherId,
      weekStartDate: weekStartDate,
      dailyTasks: dailyTasks,
      updatedAt: now,
    );

    await docRef.set(plan.toMap(), SetOptions(merge: true));
    return plan;
  }

  Future<void> updateDailyRevisionTaskStatus({
    required WeeklyRevisionPlan plan,
    required int dayIndex,
    required RevisionTaskStatus status,
  }) async {
    final now = DateTime.now();
    DailyRevisionTask? updatedTask;
    final updatedTasks = plan.dailyTasks.map((t) {
      if (t.dayIndex == dayIndex) {
        updatedTask = t.copyWith(
          status: status,
          completedAt: status == RevisionTaskStatus.pending ? null : now,
        );
        return updatedTask!;
      }
      return t;
    }).toList();

    await _firestore
        .collection(revisionPlansCollection)
        .doc(plan.id)
        .set({
      'dailyTasks': updatedTasks.map((t) => t.toMap()).toList(),
      'updatedAt': Timestamp.fromDate(now),
    }, SetOptions(merge: true));

    // If task is marked Done / Done Late and targets a Juz, update LRU lastRevisedJuzDates
    if (updatedTask != null &&
        !updatedTask!.isRestDay &&
        (status == RevisionTaskStatus.doneOnTime ||
            status == RevisionTaskStatus.doneLate)) {
      int? revisedJuz = updatedTask!.juzNumber;
      if (revisedJuz == null &&
          updatedTask!.targetType == RevisionTargetType.surah &&
          updatedTask!.surahId != null) {
        revisedJuz = CenterQuranMap.getSurahById(updatedTask!.surahId!).primaryJuz;
      } else if (revisedJuz == null &&
          updatedTask!.targetType == RevisionTargetType.pageRange &&
          updatedTask!.fromPage != null) {
        revisedJuz = CenterQuranMap.getJuzForPage(updatedTask!.fromPage!);
      }

      if (revisedJuz != null) {
        await _firestore
            .collection(studentsCollection)
            .doc(plan.studentId)
            .set({
          'lastRevisedJuzDates': {
            revisedJuz.toString(): Timestamp.fromDate(now),
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }
  }

  /// Computes the Least Recently Revised (LRU) priority queue for a student's memorized Juz'.
  List<RevisionPriorityItem> computeRevisionPriorityQueue(
    StudentProfile student,
  ) =>
      computeRevisionPriorityQueueForStudent(student);

  static List<RevisionPriorityItem> computeRevisionPriorityQueueForStudent(
    StudentProfile student,
  ) {
    final now = DateTime.now();
    final activeJuzSet = <int>{
      ...student.completedJuz,
      ...student.juzStatuses.keys,
    };

    for (final p in student.memorizedPages) {
      activeJuzSet.add(CenterQuranMap.getJuzForPage(p));
    }
    for (final sId in student.completedSurahs) {
      activeJuzSet.add(CenterQuranMap.getSurahById(sId).primaryJuz);
    }

    if (activeJuzSet.isEmpty) {
      activeJuzSet.add(30); // Default to Juz 30 for new students
    }

    final items = activeJuzSet.map((juz) {
      final lastDate = student.lastRevisedJuzDates[juz];
      final daysSince =
          lastDate != null ? now.difference(lastDate).inDays : 999;

      // Determine JuzProgressStatus
      JuzProgressStatus status = JuzProgressStatus.fromString(
        student.juzStatuses[juz],
      );
      if (status == JuzProgressStatus.inProgress) {
        final juzPages = CenterQuranMap.getPagesForJuz(juz);
        final memSet = student.memorizedPages.toSet();
        final allPagesDone = juzPages.every((p) => memSet.contains(p)) ||
            (juz == 30 &&
                CenterQuranMap.getSurahsByJuz(30)
                    .every((s) => student.completedSurahs.contains(s.id)));
        if (allPagesDone) {
          status = JuzProgressStatus.readyForExam;
        }
      }

      return RevisionPriorityItem(
        juzNumber: juz,
        lastRevisedAt: lastDate,
        daysSinceLastRevision: daysSince,
        juzStatus: status,
      );
    }).toList();

    items.sort((a, b) {
      final cmp =
          b.daysSinceLastRevision.compareTo(a.daysSinceLastRevision);
      if (cmp != 0) return cmp;
      return b.juzNumber.compareTo(a.juzNumber);
    });

    return items;
  }

  // ---------------------------------------------------------------------------
  // Admin Prior Balance Provisioning (الرصيد السابق)
  // ---------------------------------------------------------------------------

  Future<void> updateStudentPriorBalance({
    required String studentId,
    required List<int> completedJuz,
    required List<int> completedSurahs,
    required List<int> memorizedPages,
  }) async {
    final pagesSet = <int>{...memorizedPages};
    final surahsSet = <int>{...completedSurahs};
    final centerUnits = <String>{};
    final juzStatuses = <String, String>{};

    for (final j in completedJuz) {
      pagesSet.addAll(CenterQuranMap.getPagesForJuz(j));
      for (final s in CenterQuranMap.getSurahsByJuz(j)) {
        surahsSet.add(s.id);
      }
      juzStatuses[j.toString()] = JuzProgressStatus.passedExam.toJson();
    }

    for (final sId in surahsSet) {
      final s = CenterQuranMap.getSurahById(sId);
      pagesSet.addAll(s.pages);
      if (s.isJuz30) {
        centerUnits.add('s$sId');
      } else {
        for (final p in s.pages) {
          centerUnits.add('s${sId}_p$p');
        }
      }
    }

    for (final s in CenterQuranMap.surahs) {
      if (!s.isJuz30 && !surahsSet.contains(s.id)) {
        for (final p in s.pages) {
          if (pagesSet.contains(p)) {
            centerUnits.add('s${s.id}_p$p');
          }
        }
      }
    }

    await _firestore.collection(studentsCollection).doc(studentId).set({
      'completedJuz': completedJuz.toSet().toList()..sort(),
      'completedSurahs': surahsSet.toList()..sort(),
      'memorizedPages': pagesSet.toList()..sort(),
      'memorizedCenterUnits': centerUnits.toList(),
      'juzStatuses': juzStatuses,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
