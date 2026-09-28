abstract final class GeminiConfig {
  static const String apiKey =
      'AQ.Ab8RN6J7Cks4NuSUFXReFHqNJSfPfpviTT1wAN6yS-O8ucV6gw';

  static const String model = 'gemini-3.8-flash';

  static bool get isConfigured =>
      apiKey.trim().isNotEmpty && !apiKey.contains('YOUR_API_KEY');
}
