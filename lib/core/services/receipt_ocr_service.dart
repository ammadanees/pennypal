import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/gemini_config.dart';
import '../constants/app_categories.dart';

class ParsedReceipt {
  const ParsedReceipt({
    this.merchantName,
    this.totalAmount,
    this.date,
    this.category,
  });

  final String? merchantName;
  final double? totalAmount;
  final DateTime? date;
  final ExpenseCategory? category;
}

abstract final class ReceiptOcrService {
  static Future<ParsedReceipt?> parseReceiptImage(Uint8List imageBytes) async {
    if (!GeminiConfig.isConfigured) {
      debugPrint('[ReceiptOcr] Gemini API key not configured, skipping cloud OCR.');
      return null;
    }

    try {
      final base64Image = base64Encode(imageBytes);
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/${GeminiConfig.model}:generateContent?key=${GeminiConfig.apiKey}',
      );

      const prompt = '''
Analyze this receipt or bill image carefully.
Extract the key financial details and return a single valid JSON object with the following fields:
{
  "merchantName": "store, restaurant, vendor, or biller name",
  "totalAmount": 123.45 (number only, the final total or amount paid),
  "date": "YYYY-MM-DD" (if visible, else null),
  "category": "one of: Food, Transport, Education, Shopping, Entertainment, Bills, Savings, Miscellaneous"
}
If any field cannot be found, use null or empty string. Do not include markdown code block formatting.
''';

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                    {
                      'inline_data': {
                        'mime_type': 'image/jpeg',
                        'data': base64Image,
                      },
                    },
                  ],
                },
              ],
              'generationConfig': {
                'response_mime_type': 'application/json',
                'temperature': 0.1,
              },
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        final text = candidates?.firstOrNull?['content']?['parts']?.firstOrNull?['text'] as String?;
        if (text != null && text.trim().isNotEmpty) {
          final parsedJson = jsonDecode(text.trim()) as Map<String, dynamic>;
          final merchant = parsedJson['merchantName'] as String?;
          final rawAmount = parsedJson['totalAmount'];
          final dateStr = parsedJson['date'] as String?;
          final catStr = parsedJson['category'] as String?;

          double? amount;
          if (rawAmount is num) {
            amount = rawAmount.toDouble();
          } else if (rawAmount is String) {
            amount = double.tryParse(rawAmount.replaceAll(RegExp(r'[^\d.]'), ''));
          }

          DateTime? date;
          if (dateStr != null && dateStr.isNotEmpty) {
            date = DateTime.tryParse(dateStr);
          }

          ExpenseCategory? category;
          if (catStr != null && catStr.isNotEmpty) {
            category = ExpenseCategory.values.firstWhere(
              (c) => c.label.toLowerCase() == catStr.toLowerCase() || c.name.toLowerCase() == catStr.toLowerCase(),
              orElse: () => ExpenseCategory.food,
            );
          }

          return ParsedReceipt(
            merchantName: merchant?.trim().isNotEmpty == true ? merchant!.trim() : null,
            totalAmount: amount,
            date: date,
            category: category,
          );
        }
      }

      debugPrint('[ReceiptOcr] Gemini response ${response.statusCode}: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('[ReceiptOcr] Error parsing receipt image with Gemini OCR: $e');
      return null;
    }
  }
}
