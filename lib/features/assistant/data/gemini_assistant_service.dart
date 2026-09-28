import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/gemini_config.dart';
import '../../../core/utils/formatters.dart';
import '../domain/assistant_engine.dart';

class GeminiAssistantService implements AssistantService {
  const GeminiAssistantService({
    this.fallback = const RuleBasedAssistant(),
    this.timeout = const Duration(seconds: 8),
  });

  final AssistantService fallback;
  final Duration timeout;

  @override
  Future<AssistantReply> ask(String question, AssistantContext ctx) async {
    if (!GeminiConfig.isConfigured) {
      debugPrint(
          '[GeminiAssistant] API key not configured, using offline engine.');
      return fallback.ask(question, ctx);
    }

    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/${GeminiConfig.model}:generateContent?key=${GeminiConfig.apiKey}',
      );

      final systemContext = '''
You are PennyPal's friendly, encouraging AI financial guide for students.
Your job is to provide practical budgeting, saving, and expense guidance.

Student Financial Snapshot:
- Monthly Income: ${ctx.monthIncome > 0 ? Formatters.money(ctx.monthIncome) : 'Not recorded'}
- Monthly Expenses: ${ctx.monthExpense > 0 ? Formatters.money(ctx.monthExpense) : 'None yet'}
- Budget Total: ${ctx.budgetTotal != null ? Formatters.money(ctx.budgetTotal!) : 'Not set'}
- Budget Spent: ${ctx.budgetSpent != null ? Formatters.money(ctx.budgetSpent!) : 'N/A'}
- Top Expense Category: ${ctx.topCategoryLabel ?? 'N/A'}
- Active Savings Goal: ${ctx.goalName ?? 'None'} (Target: ${ctx.goalRemaining != null ? Formatters.money(ctx.goalRemaining!) : 'N/A'})

Guidelines:
1. Keep replies concise, helpful, and student-friendly (2 to 4 sentences or brief bullets).
2. Answer the student's question directly with educational guidance.
3. Never give formal professional investment, stock, crypto, or legal tax advice.
4. Conclude with a helpful follow-up tip if relevant.
''';

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': '$systemContext\n\nStudent asks: "$question"'},
                  ],
                },
              ],
              'generationConfig': {
                'temperature': 0.7,
                'maxOutputTokens': 250,
              },
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;
          final text = parts?.firstOrNull?['text'] as String?;
          if (text != null && text.trim().isNotEmpty) {
            return AssistantReply(
              text.trim(),
              suggestions: const [
                'Where did my money go this month?',
                'How can I save more on food?',
                'What is the 50/30/20 rule?',
              ],
            );
          }
        }
      }

      debugPrint(
          '[GeminiAssistant] Non-200 or empty response (${response.statusCode}): ${response.body}');
      return fallback.ask(question, ctx);
    } catch (e) {
      debugPrint(
          '[GeminiAssistant] Error connecting to Gemini API ($e), falling back to offline engine.');
      return fallback.ask(question, ctx);
    }
  }
}
