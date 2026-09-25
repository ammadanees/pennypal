import 'dart:async';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

/// In-memory stand-in used ONLY when Firebase is not configured in debug
/// builds, so the UI can be run and reviewed immediately. Nothing is
/// persisted and it is never used in release builds.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository({this.latency = const Duration(milliseconds: 500)}) {
    _accounts[studentEmail] = _Account(
      studentPassword,
      const AppUser(
        uid: studentUid,
        fullName: 'Alex Khan',
        email: studentEmail,
        mobile: '+92 300 1234567',
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

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
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
      role: UserRole.student,
    );
    _accounts[key] = _Account(password, user);
    _set(user);
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      Future<void>.delayed(latency);

  @override
  Future<void> signOut() async => _set(null);

  @override
  Future<void> updateProfile({
    required String fullName,
    required String mobile,
    String? photoUrl,
  }) async {
    final current = _current;
    if (current == null) throw const AppFailure(AppStrings.authNoSession);
    await Future<void>.delayed(latency);
    final updated = current.copyWith(
      fullName: fullName.trim(),
      mobile: mobile.trim(),
      photoUrl: photoUrl,
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
