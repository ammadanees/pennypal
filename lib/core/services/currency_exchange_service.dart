import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ExchangeRateResult {
  const ExchangeRateResult({
    required this.rate,
    required this.isLive,
    this.error,
  });

  final double rate;
  final bool isLive;
  final String? error;
}

class CurrencyExchangeService {
  CurrencyExchangeService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  /// Approximate fallback rates pegged to 1 USD.
  static const Map<String, double> _fallbackToUsd = {
    'USD': 1.0,
    'PKR': 278.50,
    'EUR': 0.92,
    'GBP': 0.77,
    'AED': 3.67,
    'INR': 84.00,
  };

  /// Calculates the fallback exchange rate from [fromCode] to [toCode].
  double getFallbackRate(String fromCode, String toCode) {
    if (fromCode.toUpperCase() == toCode.toUpperCase()) return 1.0;
    final fromUsd = _fallbackToUsd[fromCode.toUpperCase()] ?? 1.0;
    final toUsd = _fallbackToUsd[toCode.toUpperCase()] ?? 1.0;
    return toUsd / fromUsd;
  }

  /// Fetches the live exchange rate from open.er-api.com, falling back to cached rates if unavailable.
  Future<ExchangeRateResult> fetchRate({
    required String fromCode,
    required String toCode,
  }) async {
    final from = fromCode.toUpperCase();
    final to = toCode.toUpperCase();

    if (from == to) {
      return const ExchangeRateResult(rate: 1.0, isLive: true);
    }

    try {
      final url = Uri.parse('https://open.er-api.com/v6/latest/$from');
      final response = await _client.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['result'] == 'success') {
          final rates = data['rates'];
          if (rates is Map && rates.containsKey(to)) {
            final rateNum = rates[to];
            if (rateNum is num) {
              return ExchangeRateResult(
                rate: rateNum.toDouble(),
                isLive: true,
              );
            }
          }
        }
      }
    } catch (e) {
      // Network timeout, offline, or parse failure - gracefully use fallback
    }

    final fallback = getFallbackRate(from, to);
    return ExchangeRateResult(
      rate: fallback,
      isLive: false,
      error: 'Using offline estimated rate',
    );
  }
}

final currencyExchangeServiceProvider =
    Provider<CurrencyExchangeService>((ref) => CurrencyExchangeService());
