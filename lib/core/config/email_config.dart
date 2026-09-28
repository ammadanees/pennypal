abstract final class EmailConfig {
  static const String provider = 'brevo';

  static const String apiKey =
      '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';

  static const String fromEmail = 'ammad.anees99@gmail.com';
  static const String fromName = 'PennyPal Verification';

  static bool get isConfigured => apiKey.isNotEmpty;
}
