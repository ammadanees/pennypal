import 'app_user.dart';

/// Contract for authentication and the signed-in student's account record.
/// Implementations throw [AppFailure] with a message safe to show.
abstract class AuthRepository {
  /// Emits the signed-in user (with role), or null when signed out.
  Stream<AppUser?> authStateChanges();

  Future<void> signIn({required String email, required String password});

  Future<void> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
    String? studentId,
  });

  /// Sends a 6-digit verification OTP to the user's email.
  Future<void> sendEmailOtp({String? email});

  /// Verifies the entered 6-digit OTP and marks email as verified.
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

  /// True when running without Firebase (local development only).
  bool get isDemo => false;
}
