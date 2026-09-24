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
  });

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();

  Future<void> updateProfile({required String fullName, required String mobile});

  /// True when running without Firebase (local development only).
  bool get isDemo => false;
}
