import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/email_config.dart';

abstract final class EmailService {
  static final ValueNotifier<String?> lastSentOtp = ValueNotifier<String?>(null);

  static Future<void> sendVerificationOtp({
    required String email,
    required String otp,
    required String recipientName,
  }) async {
    lastSentOtp.value = otp;
    debugPrint('[EmailService] ✉️ OTP for $email: $otp');

    if (!EmailConfig.isConfigured) {
      debugPrint(
        '[EmailService] Notice: EmailConfig.apiKey is not configured. '
        'Add your Brevo or Resend key in lib/core/config/email_config.dart to dispatch emails to real inboxes.',
      );
      return;
    }

    try {
      if (EmailConfig.provider == 'resend') {
        final uri = Uri.parse('https://api.resend.com/emails');
        final res = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer ${EmailConfig.apiKey}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'from': '${EmailConfig.fromName} <${EmailConfig.fromEmail}>',
            'to': [email],
            'subject': '$otp is your PennyPal verification code',
            'html': _emailHtml(recipientName, otp),
          }),
        );
        debugPrint('[EmailService] Resend response: ${res.statusCode}');
      } else {
        // Brevo (Sendinblue) API
        final uri = Uri.parse('https://api.brevo.com/v3/smtp/email');
        final res = await http.post(
          uri,
          headers: {
            'api-key': EmailConfig.apiKey,
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
          body: jsonEncode({
            'sender': {
              'name': EmailConfig.fromName,
              'email': EmailConfig.fromEmail,
            },
            'to': [
              {'email': email, 'name': recipientName}
            ],
            'subject': '$otp is your PennyPal verification code',
            'htmlContent': _emailHtml(recipientName, otp),
          }),
        );
        debugPrint('[EmailService] Brevo status: ${res.statusCode}');
        if (res.statusCode >= 400) {
          debugPrint('[EmailService] ⚠️ Brevo Error Response: ${res.body}');
        } else {
          debugPrint('[EmailService] ✅ Email dispatched successfully to $email');
        }
      }
    } catch (e) {
      debugPrint('[EmailService] ⚠️ Failed to send email: $e');
    }
  }

  static String _emailHtml(String name, String otp) => '''
    <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 500px; margin: 0 auto; padding: 24px; border: 1px solid #e2e8f0; border-radius: 12px; background: #ffffff;">
      <h2 style="color: #05875c; margin-top: 0;">PennyPal Verification</h2>
      <p style="font-size: 15px; color: #334155;">Hi $name,</p>
      <p style="font-size: 15px; color: #475569;">Thank you for registering with PennyPal. Enter the following 6-digit verification code to complete your signup:</p>
      <div style="background-color: #f1f9f5; border: 1.5px dashed #05875c; border-radius: 10px; padding: 18px; text-align: center; margin: 24px 0;">
        <span style="font-size: 36px; font-weight: 700; letter-spacing: 8px; color: #05875c;">$otp</span>
      </div>
      <p style="font-size: 13px; color: #64748b; margin-bottom: 0;">This code is valid for 5 minutes. If you did not request this code, you can safely ignore this email.</p>
    </div>
  ''';
}
