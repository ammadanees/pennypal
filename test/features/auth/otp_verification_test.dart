import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/core/errors/app_failure.dart';
import 'package:pennypal/core/services/email_service.dart';
import 'package:pennypal/features/auth/data/demo_auth_repository.dart';

void main() {
  group('Email OTP Verification Flow', () {
    late DemoAuthRepository repo;

    setUp(() {
      repo = DemoAuthRepository(latency: Duration.zero);
      EmailService.lastSentOtp.value = null;
    });

    test('registering sets isEmailVerified to false and dispatches OTP', () async {
      await repo.register(
        fullName: 'Sara Ahmed',
        email: 'sara@student.edu',
        mobile: '+92 300 9876543',
        password: 'Password123!',
      );

      final user = await repo.authStateChanges().first;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, isFalse);
      expect(EmailService.lastSentOtp.value, isNotNull);
      expect(EmailService.lastSentOtp.value!.length, 6);
    });

    test('verifying with invalid code throws AppFailure', () async {
      await repo.register(
        fullName: 'Sara Ahmed',
        email: 'sara@student.edu',
        mobile: '+92 300 9876543',
        password: 'Password123!',
      );

      expect(
        () => repo.verifyEmailOtp('000000'),
        throwsA(isA<AppFailure>().having(
          (e) => e.message,
          'message',
          contains('Invalid verification code'),
        )),
      );

      final user = await repo.authStateChanges().first;
      expect(user!.isEmailVerified, isFalse);
    });

    test('verifying with correct code marks user as verified', () async {
      await repo.register(
        fullName: 'Sara Ahmed',
        email: 'sara@student.edu',
        mobile: '+92 300 9876543',
        password: 'Password123!',
      );

      final generatedOtp = EmailService.lastSentOtp.value!;
      await repo.verifyEmailOtp(generatedOtp);

      final user = await repo.authStateChanges().first;
      expect(user!.isEmailVerified, isTrue);
    });

    test('resending OTP generates a fresh code and old code fails', () async {
      await repo.register(
        fullName: 'Sara Ahmed',
        email: 'sara@student.edu',
        mobile: '+92 300 9876543',
        password: 'Password123!',
      );

      final firstOtp = EmailService.lastSentOtp.value!;
      await repo.sendEmailOtp();
      final secondOtp = EmailService.lastSentOtp.value!;

      expect(secondOtp.length, 6);

      // If the second OTP happens to differ (almost always 1 in 900,000)
      if (firstOtp != secondOtp) {
        expect(
          () => repo.verifyEmailOtp(firstOtp),
          throwsA(isA<AppFailure>()),
        );
      }

      await repo.verifyEmailOtp(secondOtp);
      final user = await repo.authStateChanges().first;
      expect(user!.isEmailVerified, isTrue);
    });
  });
}
