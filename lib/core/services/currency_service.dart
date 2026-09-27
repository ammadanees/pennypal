import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_strings.dart';
import '../utils/formatters.dart';
import 'shared_preferences_provider.dart';

class CurrencyOption {
  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.name,
  });

  final String code;
  final String symbol;
  final String name;
}

const List<CurrencyOption> supportedCurrencies = [
  CurrencyOption(code: 'PKR', symbol: 'Rs.', name: 'Pakistani Rupee'),
  CurrencyOption(code: 'USD', symbol: '\$', name: 'US Dollar'),
  CurrencyOption(code: 'EUR', symbol: '€', name: 'Euro'),
  CurrencyOption(code: 'GBP', symbol: '£', name: 'British Pound'),
  CurrencyOption(code: 'AED', symbol: 'AED', name: 'UAE Dirham'),
  CurrencyOption(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
];

class CurrencyNotifier extends Notifier<String> {
  static const _key = 'user_currency_preference';

  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(_key) ?? AppStrings.defaultCurrency;
    Formatters.currentCurrency = saved;
    return saved;
  }

  Future<void> setCurrency(String newCurrency) async {
    state = newCurrency;
    Formatters.currentCurrency = newCurrency;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, newCurrency);
  }
}

final currencyProvider =
    NotifierProvider<CurrencyNotifier, String>(CurrencyNotifier.new);
