import 'package:flutter/widgets.dart';
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

  /// Resolves the default currency symbol based on the device's locale.
  static String detectDefaultCurrency() {
    try {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final country = locale.countryCode?.toUpperCase();
      if (country != null) {
        return switch (country) {
          'PK' => 'Rs.', // Pakistan
          'US' => '\$',   // United States
          'GB' => '£',    // United Kingdom
          'IN' => '₹',    // India
          'AE' => 'AED',  // UAE
          // Eurozone
          'DE' ||
          'FR' ||
          'IT' ||
          'ES' ||
          'NL' ||
          'BE' ||
          'AT' ||
          'PT' ||
          'IE' ||
          'FI' ||
          'GR' ||
          'LU' ||
          'CY' ||
          'MT' ||
          'SK' ||
          'SI' ||
          'EE' ||
          'LV' ||
          'LT' ||
          'HR' =>
            '€',
          _ => '\$',      // Global default for international users
        };
      }
    } catch (_) {
      // Platform dispatcher not initialized yet or locale missing
    }
    return AppStrings.defaultCurrency;
  }

  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(_key);
    if (saved != null && saved.isNotEmpty) {
      Formatters.currentCurrency = saved;
      return saved;
    }

    final detected = detectDefaultCurrency();
    Formatters.currentCurrency = detected;
    // Persist auto-detected preference
    prefs.setString(_key, detected);
    return detected;
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
