import 'app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<void> signIn({required String email, required String password});

  Future<void> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
    String? studentId,
  });

  Future<void> sendEmailOtp({String? email});

  Future<void> verifyEmailOtp(String otp);

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();

  Future<void> updateProfile({
    required String fullName,
    required String mobile,
    String? studentId,
    String? photoUrl,
    String? studentStatus,
    bool? notificationsEnabled,
  });

  bool get isDemo => false;
}
