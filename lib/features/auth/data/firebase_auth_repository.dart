import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/services/email_service.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';
import 'auth_error_mapper.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    SharedPreferences? prefs,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _prefs = prefs {
    _initLocalVerified();
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final SharedPreferences? _prefs;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  static const String _verifiedUidsKey = 'verified_uids';
  static final Set<String> _locallyVerifiedUids = <String>{};
  static final Map<String, Map<String, dynamic>> _pendingProfiles = {};
  static final Map<String, ({String code, DateTime expiresAt})> _pendingOtps =
      {};

  static void loadPersistedVerifiedUids(SharedPreferences prefs) {
    final list = prefs.getStringList(_verifiedUidsKey);
    if (list != null) {
      _locallyVerifiedUids.addAll(list);
    }
  }

  void _initLocalVerified() {
    final list = _prefs?.getStringList(_verifiedUidsKey);
    if (list != null) {
      _locallyVerifiedUids.addAll(list);
    }
  }

  Future<void> _markUidLocallyVerified(String uid) async {
    _locallyVerifiedUids.add(uid);
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setStringList(
          _verifiedUidsKey, _locallyVerifiedUids.toList());
    } catch (e) {
      debugPrint('Could not persist verified UID: $e');
    }
  }

  @override
  bool get isDemo => false;

  @override
  Stream<AppUser?> authStateChanges() {
    late final StreamController<AppUser?> controller;
    StreamSubscription<User?>? authSub;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? docSub;
    Timer? fallbackTimer;

    controller = StreamController<AppUser?>(
      onListen: () {
        authSub = _auth.authStateChanges().listen((user) {
          docSub?.cancel();
          fallbackTimer?.cancel();
          if (user == null) {
            controller.add(null);
            return;
          }

          var hasEmitted = false;

          fallbackTimer = Timer(const Duration(seconds: 2), () {
            if (!hasEmitted && !controller.isClosed) {
              controller.add(_fallback(user));
              hasEmitted = true;
            }
          });

          docSub = _users.doc(user.uid).snapshots().listen(
            (snap) {
              if (!snap.exists &&
                  snap.metadata.isFromCache &&
                  !_locallyVerifiedUids.contains(user.uid)) {
                return;
              }
              fallbackTimer?.cancel();
              hasEmitted = true;
              if (snap.data()?['isEmailVerified'] == true) {
                unawaited(_markUidLocallyVerified(user.uid));
              }
              controller.add(_fromSnapshot(user, snap));
            },
            onError: (Object _) {
              fallbackTimer?.cancel();
              hasEmitted = true;
              controller.add(_fallback(user));
            },
          );
        }, onError: controller.addError);
      },
      onCancel: () async {
        fallbackTimer?.cancel();
        await docSub?.cancel();
        await authSub?.cancel();
      },
    );
    return controller.stream;
  }

  AppUser _fromSnapshot(
      User user, DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data();
    if (data == null) return _fallback(user);
    final isVerifiedInDoc = (data['isEmailVerified'] as bool?) ?? false;
    if (isVerifiedInDoc && !_locallyVerifiedUids.contains(user.uid)) {
      unawaited(_markUidLocallyVerified(user.uid));
    }
    final isVerified = _locallyVerifiedUids.contains(user.uid) ||
        isVerifiedInDoc ||
        user.emailVerified;
    final rawPhoto = data['photoUrl'] as String?;
    final photo = rawPhoto != null && rawPhoto.trim().isNotEmpty
        ? rawPhoto.trim()
        : (user.photoURL != null && user.photoURL!.trim().isNotEmpty
            ? user.photoURL!.trim()
            : null);
    return AppUser(
      uid: user.uid,
      fullName: (data['fullName'] as String?) ?? _fallback(user).fullName,
      email: user.email ?? (data['email'] as String? ?? ''),
      mobile: (data['mobile'] as String?) ?? '',
      studentId: data['studentId'] as String?,
      role: UserRole.parse(data['role']),
      photoUrl: photo,
      isEmailVerified: isVerified,
      studentStatus: (data['studentStatus'] as String?) ?? 'Full-time',
      notificationsEnabled: (data['notificationsEnabled'] as bool?) ?? true,
    );
  }

  AppUser _fallback(User user) {
    final isVerified =
        _locallyVerifiedUids.contains(user.uid) || user.emailVerified;
    return AppUser(
      uid: user.uid,
      fullName: user.displayName ?? user.email?.split('@').first ?? 'Student',
      email: user.email ?? '',
      mobile: '',
      role: UserRole.student,
      photoUrl: user.photoURL != null && user.photoURL!.trim().isNotEmpty
          ? user.photoURL!.trim()
          : null,
      isEmailVerified: isVerified,
    );
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user?.uid;
      if (uid != null) {
        try {
          final snap = await _users.doc(uid).get();
          if (snap.exists && (snap.data()?['isEmailVerified'] == true)) {
            await _markUidLocallyVerified(uid);
          }
        } catch (e) {
          debugPrint('Could not pre-fetch profile on sign-in: $e');
        }
        unawaited(_touchLastLogin(uid));
      }
    } on FirebaseAuthException catch (e) {
      throw mapAuthError(e);
    }
  }

  Future<void> _touchLastLogin(String uid) async {
    try {
      await _users.doc(uid).set(
          {'lastLogin': FieldValue.serverTimestamp()}, SetOptions(merge: true));
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
    String? studentId,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      await user.updateDisplayName(fullName.trim());

      final initialProfile = <String, dynamic>{
        'fullName': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'mobile': mobile.trim(),
        if (studentId != null && studentId.trim().isNotEmpty)
          'studentId': studentId.trim(),
        'role': 'student',
        'isEmailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      };
      _pendingProfiles[user.uid] = initialProfile;

      try {
        await _users.doc(user.uid).set(initialProfile);
      } catch (e) {
        debugPrint('Could not save profile document immediately: $e');
      }
      await sendEmailOtp(email: email.trim().toLowerCase());
    } on FirebaseAuthException catch (e) {
      throw mapAuthError(e);
    }
  }

  @override
  Future<void> sendEmailOtp({String? email}) async {
    final user = _auth.currentUser;
    final targetEmail = email ?? user?.email;
    if (user == null || targetEmail == null) {
      throw const AppFailure(AppStrings.authNoSession);
    }

    final rng = math.Random();
    final otp = (100000 + rng.nextInt(900000)).toString();
    final expiresAt = DateTime.now().add(const Duration(minutes: 5));

    _pendingOtps[user.uid] = (code: otp, expiresAt: expiresAt);

    try {
      await _users.doc(user.uid).collection('verification').doc('otp').set({
        'code': otp,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'createdAt': FieldValue.serverTimestamp(),
        'email': targetEmail,
      });
    } catch (e) {
      debugPrint('Could not write verification document: $e');
    }

    try {
      await _firestore.collection('mail').add({
        'to': [targetEmail],
        'message': {
          'subject': '$otp is your PennyPal verification code',
          'html':
              '<p>Hi ${user.displayName ?? 'Student'},</p><p>Your 6-digit PennyPal verification code is: <b>$otp</b></p><p>This code expires in 5 minutes.</p>',
        },
      });
    } catch (e) {
      debugPrint('Firestore mail collection write notice: $e');
    }

    await EmailService.sendVerificationOtp(
      email: targetEmail,
      otp: otp,
      recipientName: user.displayName ?? 'Student',
    );
  }

  @override
  Future<void> verifyEmailOtp(String otp) async {
    final user = _auth.currentUser;
    if (user == null) throw const AppFailure(AppStrings.authNoSession);

    final cleanOtp = otp.trim();
    if (cleanOtp.length != 6) {
      throw const AppFailure('Please enter a valid 6-digit verification code.');
    }

    String? storedCode;
    DateTime? expiresAt;

    try {
      final docSnap = await _users
          .doc(user.uid)
          .collection('verification')
          .doc('otp')
          .get();
      if (docSnap.exists) {
        final data = docSnap.data();
        storedCode = data?['code'] as String?;
        final expiresAtTs = data?['expiresAt'] as Timestamp?;
        expiresAt = expiresAtTs?.toDate();
      }
    } catch (e) {
      debugPrint('Could not read verification doc from Firestore: $e');
    }

    if (storedCode == null && _pendingOtps.containsKey(user.uid)) {
      final pendingOtpRecord = _pendingOtps[user.uid]!;
      storedCode = pendingOtpRecord.code;
      expiresAt = pendingOtpRecord.expiresAt;
    }

    if (storedCode == null) {
      throw const AppFailure(
          'No active verification code found. Please tap Resend Code.');
    }

    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      throw const AppFailure(
          'This verification code has expired. Please tap Resend Code.');
    }

    if (storedCode != cleanOtp) {
      throw const AppFailure(
          'Invalid verification code. Please check and try again.');
    }

    await _markUidLocallyVerified(user.uid);
    _pendingOtps.remove(user.uid);

    final pendingProfile = _pendingProfiles.remove(user.uid) ?? {};
    final profileUpdate = <String, dynamic>{
      'role': 'student',
      'isEmailVerified': true,
      'emailVerifiedAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      if (pendingProfile['fullName'] != null)
        'fullName': pendingProfile['fullName']
      else if (user.displayName != null && user.displayName!.isNotEmpty)
        'fullName': user.displayName,
      if (pendingProfile['email'] != null)
        'email': pendingProfile['email']
      else if (user.email != null)
        'email': user.email!.toLowerCase(),
      if (pendingProfile['mobile'] != null) 'mobile': pendingProfile['mobile'],
      if (pendingProfile['studentId'] != null)
        'studentId': pendingProfile['studentId'],
      if (pendingProfile['createdAt'] != null)
        'createdAt': pendingProfile['createdAt']
      else
        'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await _users.doc(user.uid).set(profileUpdate, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore update profile notice: $e');
    }

    try {
      await _users.doc(user.uid).collection('verification').doc('otp').delete();
    } catch (e) {
      debugPrint('Could not delete used OTP: $e');
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
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
    String? studentId,
    String? photoUrl,
    String? studentStatus,
    bool? notificationsEnabled,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw const AppFailure(AppStrings.authNoSession);
    try {
      await user.updateDisplayName(fullName.trim());
      if (photoUrl != null && photoUrl.trim().isNotEmpty) {
        try {
          await user.updatePhotoURL(photoUrl.trim());
        } catch (_) {}
      }
      await _users.doc(user.uid).set(
        {
          'fullName': fullName.trim(),
          'mobile': mobile.trim(),
          if (studentId != null) 'studentId': studentId.trim(),
          if (photoUrl != null) 'photoUrl': photoUrl.trim(),
          if (studentStatus != null) 'studentStatus': studentStatus.trim(),
          if (notificationsEnabled != null)
            'notificationsEnabled': notificationsEnabled,
        },
        SetOptions(merge: true),
      );
    } on FirebaseException {
      throw const AppFailure(AppStrings.errorGenericMessage);
    }
  }
}
