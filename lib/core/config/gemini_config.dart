abstract final class GeminiConfig {
  static const String apiKey =
      'AQ.Ab8RN6JPfOtNhM5TTNJRC2WuvZV3lGHfxXwGVI-bvkamwpiGug';

  static const String model = 'gemini-3.8-flash';

  static bool get isConfigured =>
      apiKey.trim().isNotEmpty && !apiKey.contains('YOUR_API_KEY');
}
