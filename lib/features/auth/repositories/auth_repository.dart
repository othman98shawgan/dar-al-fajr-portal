import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../firebase_options.dart';
import '../models/app_user.dart';

class AuthRepository {
  static const String secondaryAppName = 'SecondaryProvisioningApp';
  static const String usersCollection = 'users';

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of Firebase Auth user changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Currently signed-in Firebase Auth user.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Signs in a user with email and password.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Updates the currently signed-in user's password.
  Future<void> updatePassword(String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user found.',
      );
    }
    await user.updatePassword(newPassword);
  }

  /// Watches the Firestore `users/{uid}` document in real time.
  Stream<AppUser?> watchUserProfile(String uid) {
    return _firestore
        .collection(usersCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return AppUser.fromFirestore(snapshot);
    });
  }

  /// Fetches the Firestore `users/{uid}` document once.
  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _firestore.collection(usersCollection).doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return AppUser.fromFirestore(doc);
  }

  /// Updates the user's profile information (full name and phone number) in Firestore
  /// and updates the Firebase Auth displayName.
  Future<void> updateProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (fullName != null && fullName.trim().isNotEmpty) {
      updates['fullName'] = fullName.trim();
      final user = _firebaseAuth.currentUser;
      if (user != null && user.uid == uid) {
        try {
          await user.updateDisplayName(fullName.trim());
        } catch (_) {}
      }
    }

    if (phoneNumber != null) {
      updates['phoneNumber'] = phoneNumber.trim();
    }

    await _firestore.collection(usersCollection).doc(uid).set(
          updates,
          SetOptions(merge: true),
        );
  }

  /// Completes the First-Login Setup Gate:
  /// 1. Updates the user's Firebase Auth password.
  /// 2. Updates profile fields and sets `isFirstLogin: false` in Firestore.
  Future<void> completeFirstLoginSetup({
    required String newPassword,
    String? fullName,
    String? phoneNumber,
    String? preferredLanguage,
    DateTime? dateOfBirth,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user found.',
      );
    }

    await user.updatePassword(newPassword);

    final updates = <String, dynamic>{
      'isFirstLogin': false,
      'mustChangePassword': false,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (fullName != null && fullName.trim().isNotEmpty) {
      updates['fullName'] = fullName.trim();
      await user.updateDisplayName(fullName.trim());
    }
    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      updates['phoneNumber'] = phoneNumber.trim();
    }
    if (preferredLanguage != null && preferredLanguage.trim().isNotEmpty) {
      updates['preferredLanguage'] = preferredLanguage.trim();
    }
    if (dateOfBirth != null) {
      updates['dateOfBirth'] = Timestamp.fromDate(dateOfBirth);
    }

    await _firestore.collection(usersCollection).doc(user.uid).set(
          updates,
          SetOptions(merge: true),
        );
  }

  /// Secondary Firebase App Pattern for Admin account provisioning:
  /// Creates a new user account with a temporary password using an isolated
  /// secondary [FirebaseApp] instance so the Admin's active session is preserved.
  Future<AppUser> provisionUserAccount({
    required String email,
    required String temporaryPassword,
    required String fullName,
    required UserRole role,
    String? phoneNumber,
    String preferredLanguage = 'ar',
  }) async {
    FirebaseApp secondaryApp;
    try {
      secondaryApp = Firebase.app(secondaryAppName);
    } on FirebaseException {
      final options = Firebase.apps.isNotEmpty
          ? Firebase.app().options
          : DefaultFirebaseOptions.currentPlatform;
      secondaryApp = await Firebase.initializeApp(
        name: secondaryAppName,
        options: options,
      );
    }

    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

    try {
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: temporaryPassword,
      );

      final createdUid = credential.user!.uid;
      final newUser = AppUser(
        uid: createdUid,
        email: email.trim(),
        fullName: fullName.trim(),
        phoneNumber: phoneNumber?.trim(),
        role: role,
        isFirstLogin: true,
        preferredLanguage: preferredLanguage,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(usersCollection)
          .doc(createdUid)
          .set(newUser.toMap());

      return newUser;
    } finally {
      await secondaryAuth.signOut();
    }
  }
}
