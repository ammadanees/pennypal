/// Configuration for sending real 6-digit OTP verification emails.
///
/// Quick setup:
/// 1. Create a free account at https://brevo.com (free 300 emails/day, no domain required).
/// 2. Get your API Key: Profile (top right) > SMTP & API > API Keys > Generate a new API key.
/// 3. Paste the key in `apiKey` below and set `fromEmail` to the email you used on Brevo.
abstract final class EmailConfig {
  /// Provider: 'brevo' (recommended, no domain needed) or 'resend'
  static const String provider = 'brevo';

  /// Paste your API key here:
  static const String apiKey = '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';

  /// Sender email (for Brevo, use your registered account email):
  static const String fromEmail = 'ammad.anees99@gmail.com';
  static const String fromName = 'PennyPal Verification';

  static bool get isConfigured => apiKey.isNotEmpty;
}
