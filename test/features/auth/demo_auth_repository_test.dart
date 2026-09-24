import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/core/errors/app_failure.dart';
import 'package:pennypal/features/auth/data/demo_auth_repository.dart';
import 'package:pennypal/features/auth/domain/app_user.dart';

void main() {
  late DemoAuthRepository repo;

  setUp(() => repo = DemoAuthRepository(latency: Duration.zero));

  test('signs in the seeded student with the student role', () async {
    await repo.signIn(
      email: DemoAuthRepository.studentEmail,
      password: DemoAuthRepository.studentPassword,
    );
    final user = await repo.authStateChanges().first;
    expect(user?.role, UserRole.student);
  });

  test('signs in the seeded admin with the admin role', () async {
    await repo.signIn(
      email: DemoAuthRepository.adminEmail,
      password: DemoAuthRepository.adminPassword,
    );
    final user = await repo.authStateChanges().first;
    expect(user?.isAdmin, isTrue);
  });

  test('wrong password is rejected with a friendly failure', () {
    expect(
      repo.signIn(email: DemoAuthRepository.studentEmail, password: 'nope'),
      throwsA(isA<AppFailure>()),
    );
  });

  test('registering creates a student and blocks duplicate emails', () async {
    await repo.register(
      fullName: 'Sara Ali',
      email: 'Sara@Example.com',
      mobile: '+92 301 5551234',
      password: 'PennyPal1',
    );
    final user = await repo.authStateChanges().first;
    expect(user?.email, 'sara@example.com');
    expect(user?.role, UserRole.student);

    await repo.signOut();
    expect(
      repo.register(
        fullName: 'Sara Again',
        email: 'sara@example.com',
        mobile: '+92 301 5551234',
        password: 'PennyPal1',
      ),
      throwsA(isA<AppFailure>()),
    );
  });

  test('signing out clears the user', () async {
    await repo.signIn(
      email: DemoAuthRepository.studentEmail,
      password: DemoAuthRepository.studentPassword,
    );
    await repo.signOut();
    expect(await repo.authStateChanges().first, isNull);
  });

  test('initials and first name', () {
    const user = AppUser(
      uid: '1',
      fullName: 'Alex Khan',
      email: 'a@b.co',
      mobile: '',
      role: UserRole.student,
    );
    expect(user.initials, 'AK');
    expect(user.firstName, 'Alex');
  });
}
