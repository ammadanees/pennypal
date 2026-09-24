import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('alex'), isNotNull);
      expect(Validators.email('alex@student'), isNotNull);
      expect(Validators.email(' alex@student.edu '), isNull);
    });

    test('mobile accepts common formats', () {
      expect(Validators.mobile(''), isNotNull);
      expect(Validators.mobile('12345'), isNotNull);
      expect(Validators.mobile('+92 300 1234567'), isNull);
      expect(Validators.mobile('0300-1234567'), isNull);
    });

    test('new password rules', () {
      expect(Validators.newPassword(''), isNotNull);
      expect(Validators.newPassword('short1A'), isNotNull);
      expect(Validators.newPassword('alllowercase1'), isNotNull);
      expect(Validators.newPassword('ALLUPPERCASE1'), isNotNull);
      expect(Validators.newPassword('NoNumbersHere'), isNotNull);
      expect(Validators.newPassword('PennyPal1'), isNull);
    });

    test('confirm password must match', () {
      expect(Validators.confirmPassword('', 'PennyPal1'), isNotNull);
      expect(Validators.confirmPassword('PennyPal2', 'PennyPal1'), isNotNull);
      expect(Validators.confirmPassword('PennyPal1', 'PennyPal1'), isNull);
    });

    test('amounts', () {
      expect(Validators.amount(''), isNotNull);
      expect(Validators.amount('abc'), isNotNull);
      expect(Validators.amount('1.2.3'), isNotNull);
      expect(Validators.amount('0'), isNotNull);
      expect(Validators.amount('450'), isNull);
      expect(Validators.amount('450.50'), isNull);
      expect(Validators.optionalAmount(''), isNull);
      expect(Validators.optionalAmount('-5'), isNotNull);
      expect(Validators.optionalAmount('0'), isNull);
    });

    test('full name', () {
      expect(Validators.fullName(' '), isNotNull);
      expect(Validators.fullName('A'), isNotNull);
      expect(Validators.fullName('Alex Khan'), isNull);
    });
  });
}
