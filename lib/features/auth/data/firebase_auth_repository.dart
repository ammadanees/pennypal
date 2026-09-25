import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';
import 'auth_error_mapper.dart';

/// Firebase Auth for credentials, Firestore `users/{uid}` for the profile
/// and role. The role is read-only from the app: security rules stop a
/// student from changing it, and admin accounts are set up by hand.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  bool get isDemo => false;

  @override
  Stream<AppUser?> authStateChanges() {
    late final StreamController<AppUser?> controller;
    StreamSubscription<User?>? authSub;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? docSub;

    controller = StreamController<AppUser?>(
      onListen: () {
        authSub = _auth.authStateChanges().listen((user) {
          docSub?.cancel();
          if (user == null) {
            controller.add(null);
            return;
          }
          // Follow the profile document so a fresh registration picks up
          // the name and mobile as soon as they are saved.
          docSub = _users.doc(user.uid).snapshots().listen(
                (snap) => controller.add(_fromSnapshot(user, snap)),
                onError: (Object _) => controller.add(_fallback(user)),
              );
        }, onError: controller.addError);
      },
      onCancel: () async {
        await docSub?.cancel();
        await authSub?.cancel();
      },
    );
    return controller.stream;
  }

  AppUser _fromSnapshot(User user, DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data();
    if (data == null) return _fallback(user);
    return AppUser(
      uid: user.uid,
      fullName: (data['fullName'] as String?) ?? _fallback(user).fullName,
      email: user.email ?? (data['email'] as String? ?? ''),
      mobile: (data['mobile'] as String?) ?? '',
      role: UserRole.parse(data['role']),
      photoUrl: data['photoUrl'] as String?,
    );
  }

  AppUser _fallback(User user) => AppUser(
        uid: user.uid,
        fullName: user.displayName ?? user.email?.split('@').first ?? 'Student',
        email: user.email ?? '',
        mobile: '',
        role: UserRole.student,
      );

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user?.uid;
      if (uid != null) unawaited(_touchLastLogin(uid));
    } on FirebaseAuthException catch (e) {
      throw mapAuthError(e);
    }
  }

  Future<void> _touchLastLogin(String uid) async {
    try {
      await _users
          .doc(uid)
          .set({'lastLogin': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Could not record last login: $e');
    }
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      await user.updateDisplayName(fullName.trim());
      try {
        await _users.doc(user.uid).set({
          'fullName': fullName.trim(),
          'email': email.trim().toLowerCase(),
          'mobile': mobile.trim(),
          'role': 'student',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // The account exists; the app falls back to Auth data until the
        // profile document can be written (for example, rules not deployed).
        debugPrint('Could not save profile document: $e');
      }
    } on FirebaseAuthException catch (e) {
      throw mapAuthError(e);
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      // Unknown emails look identical to known ones.
      if (e.code == 'user-not-found') return;
      throw mapAuthError(e);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> updateProfile({
    required String fullName,
    required String mobile,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw const AppFailure(AppStrings.authNoSession);
    try {
      await user.updateDisplayName(fullName.trim());
      await _users.doc(user.uid).set(
        {
          'fullName': fullName.trim(),
          'mobile': mobile.trim(),
          if (photoUrl != null) 'photoUrl': photoUrl,
        },
        SetOptions(merge: true),
      );
    } on FirebaseException {
      throw const AppFailure(AppStrings.errorGenericMessage);
    }
  }
}
