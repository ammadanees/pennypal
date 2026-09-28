/// Configuration for Google Gemini AI assistant via Google AI Studio.
/// As specified in SRS Section 1.8: "Google AI Studio for API key creation".
///
/// Quick setup:
/// 1. Get a free API Key from Google AI Studio at https://aistudio.google.com/
/// 2. Paste your key in `apiKey` below.
abstract final class GeminiConfig {
  /// Paste your Google AI Studio Gemini API key here:
  static const String apiKey = 'AQ.Ab8RN6J7Cks4NuSUFXReFHqNJSfPfpviTT1wAN6yS-O8ucV6gw';

  /// Fast and responsive model recommended for conversational mobile chatbots and OCR
  static const String model = 'gemini-3.8-flash';

  static bool get isConfigured =>
      apiKey.trim().isNotEmpty && !apiKey.contains('YOUR_API_KEY');
}
