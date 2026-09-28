import 'dart:async';
import 'dart:math' as math;

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/services/email_service.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository({this.latency = const Duration(milliseconds: 500)}) {
    _accounts[studentEmail] = _Account(
      studentPassword,
      const AppUser(
        uid: studentUid,
        fullName: 'Ammad Anees',
        studentId: 'Student1501103',
        email: studentEmail,
        mobile: '+92 306 9074462',
        role: UserRole.student,
      ),
    );
    _accounts[adminEmail] = _Account(
      adminPassword,
      const AppUser(
        uid: 'demo-admin',
        fullName: 'PennyPal Admin',
        email: adminEmail,
        mobile: '',
        role: UserRole.admin,
      ),
    );
  }

  static const String studentUid = 'demo-student';
  static const String studentEmail = 'alex@student.edu';
  static const String studentPassword = 'PennyPal1';
  static const String adminEmail = 'admin@pennypal.app';
  static const String adminPassword = 'Admin@1234';
  static const String loginHint =
      'Demo mode (Firebase not connected). Student: $studentEmail / '
      '$studentPassword. Admin: $adminEmail / $adminPassword.';

  final Duration latency;
  final Map<String, _Account> _accounts = {};
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();
  AppUser? _current;

  @override
  bool get isDemo => true;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  void _set(AppUser? user) {
    _current = user;
    _controller.add(user);
  }

  String _key(String email) => email.trim().toLowerCase();

  @override
  Future<void> signIn({required String email, required String password}) async {
    await Future<void>.delayed(latency);
    final account = _accounts[_key(email)];
    if (account == null || account.password != password) {
      throw const AppFailure(AppStrings.authInvalidCredentials);
    }
    _set(account.user);
  }

  final Map<String, ({String code, DateTime expiresAt})> _demoOtps = {};

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
    String? studentId,
  }) async {
    await Future<void>.delayed(latency);
    final key = _key(email);
    if (_accounts.containsKey(key)) {
      throw const AppFailure(AppStrings.authEmailInUse);
    }
    final user = AppUser(
      uid: 'demo-${_accounts.length + 1}',
      fullName: fullName.trim(),
      email: key,
      mobile: mobile.trim(),
      studentId: studentId?.trim(),
      role: UserRole.student,
      isEmailVerified: false,
    );
    _accounts[key] = _Account(password, user);
    _set(user);
    await sendEmailOtp(email: key);
  }

  @override
  Future<void> sendEmailOtp({String? email}) async {
    await Future<void>.delayed(latency);
    final targetEmail = email ?? _current?.email;
    if (targetEmail == null) throw const AppFailure(AppStrings.authNoSession);
    final key = _key(targetEmail);
    final rng = math.Random();
    final otp = (100000 + rng.nextInt(900000)).toString();
    _demoOtps[key] = (
      code: otp,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
    await EmailService.sendVerificationOtp(
      email: targetEmail,
      otp: otp,
      recipientName: _current?.fullName ?? 'Student',
    );
  }

  @override
  Future<void> verifyEmailOtp(String otp) async {
    await Future<void>.delayed(latency);
    final current = _current;
    if (current == null) throw const AppFailure(AppStrings.authNoSession);
    final key = _key(current.email);
    final cleanOtp = otp.trim();
    if (cleanOtp.length != 6) {
      throw const AppFailure('Please enter a valid 6-digit verification code.');
    }

    final record = _demoOtps[key];
    if (record == null) {
      throw const AppFailure(
          'No active verification code found. Please tap Resend Code.');
    }

    if (DateTime.now().isAfter(record.expiresAt)) {
      throw const AppFailure(
          'This verification code has expired. Please tap Resend Code.');
    }

    if (record.code != cleanOtp) {
      throw const AppFailure(
          'Invalid verification code. Please check and try again.');
    }

    _demoOtps.remove(key);
    final verified = current.copyWith(isEmailVerified: true);
    _accounts[key]?.user = verified;
    _set(verified);
  }

  @override
  Future<void> sendPasswordReset(String email) => Future<void>.delayed(latency);

  @override
  Future<void> signOut() async => _set(null);

  @override
  Future<void> updateProfile({
    required String fullName,
    required String mobile,
    String? studentId,
    String? photoUrl,
    String? studentStatus,
    bool? notificationsEnabled,
  }) async {
    final current = _current;
    if (current == null) throw const AppFailure(AppStrings.authNoSession);
    await Future<void>.delayed(latency);
    final updated = current.copyWith(
      fullName: fullName.trim(),
      mobile: mobile.trim(),
      studentId: studentId?.trim(),
      photoUrl: photoUrl,
      studentStatus: studentStatus?.trim(),
      notificationsEnabled: notificationsEnabled,
    );
    _accounts[_key(current.email)]?.user = updated;
    _set(updated);
  }
}

class _Account {
  _Account(this.password, this.user);

  final String password;
  AppUser user;
}
