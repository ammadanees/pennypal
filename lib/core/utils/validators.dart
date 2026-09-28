abstract final class Validators {
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
  static final RegExp _mobile = RegExp(r'^\+?\d{10,15}$');

  static String? required(String? value, String fieldName) =>
      (value == null || value.trim().isEmpty) ? 'Enter your $fieldName.' : null;

  static String? fullName(String? value) {
    final missing = required(value, 'full name');
    if (missing != null) return missing;
    final v = value!.trim();
    if (v.length < 2) return 'Your name needs at least 2 characters.';
    if (v.length > 60) return 'Keep your name under 60 characters.';
    return null;
  }

  static String? studentId(String? value) {
    final missing = required(value, 'student ID / enrollment');
    if (missing != null) return missing;
    final v = value!.trim();
    if (v.length < 4) return 'Student ID must be at least 4 characters.';
    if (v.length > 25) return 'Keep your student ID under 25 characters.';
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(v)) {
      return 'Use letters, numbers, or hyphens (e.g. Student1501103).';
    }
    return null;
  }

  static String? email(String? value) {
    final missing = required(value, 'email');
    if (missing != null) return missing;
    return _email.hasMatch(value!.trim())
        ? null
        : 'That email address doesn\'t look right.';
  }

  static String? mobile(String? value) {
    final missing = required(value, 'mobile number');
    if (missing != null) return missing;
    final cleaned = value!.replaceAll(RegExp(r'[\s-]'), '');
    return _mobile.hasMatch(cleaned)
        ? null
        : 'Enter a valid mobile number, for example +92 300 1234567.';
  }

  static String? passwordPresent(String? value) =>
      (value == null || value.isEmpty) ? 'Enter your password.' : null;

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Choose a password.';
    if (value.length < 8) return 'Use at least 8 characters.';
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Add a lowercase letter.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Add an uppercase letter.';
    }
    if (!RegExp(r'\d').hasMatch(value)) return 'Add a number.';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirm your password.';
    return value == original ? null : 'Passwords don\'t match.';
  }

  static String? amount(String? value, {String fieldName = 'amount'}) {
    if (value == null || value.trim().isEmpty) return 'Enter the $fieldName.';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Enter a valid number.';
    if (n <= 0) return 'Must be more than zero.';
    if (n > 999999999) return 'That number is too large.';
    return null;
  }

  static String? optionalAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final n = double.tryParse(value.trim());
    if (n == null) return 'Enter a valid number.';
    if (n < 0) return 'Cannot be negative.';
    if (n > 999999999) return 'That number is too large.';
    return null;
  }

  static String? maxLength(String? value, int max) =>
      (value != null && value.trim().length > max)
          ? 'Keep this under $max characters.'
          : null;
}
