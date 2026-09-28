import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../data/auth_providers.dart';

class AuthController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<String?> signIn({required String email, required String password}) =>
      _run(() => ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password));

  Future<String?> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
    String? studentId,
  }) =>
      _run(() => ref.read(authRepositoryProvider).register(
            fullName: fullName,
            email: email,
            mobile: mobile,
            password: password,
            studentId: studentId,
          ));

  Future<String?> sendEmailOtp({String? email}) =>
      _run(() => ref.read(authRepositoryProvider).sendEmailOtp(email: email));

  Future<String?> verifyEmailOtp(String otp) =>
      _run(() => ref.read(authRepositoryProvider).verifyEmailOtp(otp));

  Future<String?> sendPasswordReset(String email) =>
      _run(() => ref.read(authRepositoryProvider).sendPasswordReset(email));

  Future<String?> updateProfile({
    required String fullName,
    required String mobile,
    String? studentId,
    String? photoUrl,
    String? studentStatus,
    bool? notificationsEnabled,
  }) =>
      _run(() => ref.read(authRepositoryProvider).updateProfile(
            fullName: fullName,
            mobile: mobile,
            studentId: studentId,
            photoUrl: photoUrl,
            studentStatus: studentStatus,
            notificationsEnabled: notificationsEnabled,
          ));

  Future<void> signOut() => ref.read(authRepositoryProvider).signOut();

  Future<String?> _run(Future<void> Function() action) async {
    state = true;
    try {
      await action();
      return null;
    } on AppFailure catch (failure) {
      return failure.message;
    } catch (_) {
      return AppStrings.errorGenericMessage;
    } finally {
      state = false;
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, bool>(AuthController.new);
