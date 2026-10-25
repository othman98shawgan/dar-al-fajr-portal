import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  teacher,
  parent,
  student;

  static UserRole fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'admin':
        return UserRole.admin;
      case 'teacher':
        return UserRole.teacher;
      case 'parent':
        return UserRole.parent;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  String toJson() => name;

  String localizedName(String langCode) {
    switch (this) {
      case UserRole.admin:
        switch (langCode) {
          case 'he':
            return 'מנהל מערכת';
          case 'en':
            return 'Admin';
          case 'ar':
          default:
            return 'مدير النظام';
        }
      case UserRole.teacher:
        switch (langCode) {
          case 'he':
            return 'מורה';
          case 'en':
            return 'Teacher';
          case 'ar':
          default:
            return 'معلم';
        }
      case UserRole.parent:
        switch (langCode) {
          case 'he':
            return 'הורה';
          case 'en':
            return 'Parent';
          case 'ar':
          default:
            return 'ولي أمر';
        }
      case UserRole.student:
        switch (langCode) {
          case 'he':
            return 'תלמיד';
          case 'en':
            return 'Student';
          case 'ar':
          default:
            return 'طالب';
        }
    }
  }

  String get displayName => localizedName('ar');
}

class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final UserRole role;
  final bool isFirstLogin;
  final String preferredLanguage;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.role,
    this.isFirstLogin = true,
    this.preferredLanguage = 'ar',
    this.createdAt,
  });

  /// Convenience alias for [fullName].
  String get name => fullName;

  /// Convenience alias for [phoneNumber].
  String? get phone => phoneNumber;

  /// Convenience alias for [isFirstLogin] (First-Login Setup Gate).
  bool get mustChangePassword => isFirstLogin;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppUser.fromMap(data, uid: doc.id);
  }

  factory AppUser.fromMap(Map<String, dynamic> map, {String? uid}) {
    final rawCreatedAt = map['createdAt'] ?? map['created_at'];
    DateTime? parsedCreatedAt;
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt);
    }

    final firstLoginFlag = map['isFirstLogin'] ??
        map['is_first_login'] ??
        map['mustChangePassword'] ??
        map['must_change_password'] ??
        false;

    return AppUser(
      uid: uid ?? (map['uid'] as String? ?? ''),
      email: map['email'] as String? ?? '',
      fullName: (map['fullName'] ?? map['full_name'] ?? map['name'] ?? '')
          as String,
      phoneNumber:
          (map['phoneNumber'] ?? map['phone_number'] ?? map['phone'])
              as String?,
      role: UserRole.fromString(map['role'] as String?),
      isFirstLogin: firstLoginFlag == true,
      preferredLanguage: (map['preferredLanguage'] ??
              map['preferred_language'] ??
              'ar') as String,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role.toJson(),
      'isFirstLogin': isFirstLogin,
      'mustChangePassword': isFirstLogin,
      'preferredLanguage': preferredLanguage,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    UserRole? role,
    bool? isFirstLogin,
    String? preferredLanguage,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
