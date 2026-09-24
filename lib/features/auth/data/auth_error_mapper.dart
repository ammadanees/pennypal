import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';

/// Turns Firebase error codes into friendly messages.
/// Wrong password and unknown email share one message so the app never
/// reveals which emails have accounts.
AppFailure mapAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return const AppFailure(AppStrings.authInvalidEmail);
    case 'user-disabled':
      return const AppFailure(AppStrings.authUserDisabled);
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return const AppFailure(AppStrings.authInvalidCredentials);
    case 'email-already-in-use':
      return const AppFailure(AppStrings.authEmailInUse);
    case 'weak-password':
      return const AppFailure(AppStrings.authWeakPassword);
    case 'too-many-requests':
      return const AppFailure(AppStrings.authTooManyRequests);
    case 'network-request-failed':
      return const AppFailure(AppStrings.authNetwork);
    default:
      return const AppFailure(AppStrings.errorGenericMessage);
  }
}
