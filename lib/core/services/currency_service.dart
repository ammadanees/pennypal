import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/auth_providers.dart';
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
  /// Uses US Dollar (\$) as the global fallback for international users.
  static String detectDefaultCurrency() {
    try {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final country = locale.countryCode?.toUpperCase();
      if (country != null) {
        return switch (country) {
          'PK' => 'Rs.', // Pakistan
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
          'US' => '\$',   // United States
          _ => '\$',      // Global fallback for international users
        };
      }
    } catch (_) {
      // Platform dispatcher not initialized yet or locale missing
    }
    return '\$'; // Global fallback
  }

  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    // 1. If user is logged in and has an account currency saved in Firestore, sync it!
    if (user != null && user.currency != null && user.currency!.trim().isNotEmpty) {
      final cloudCurrency = user.currency!.trim();
      Formatters.currentCurrency = cloudCurrency;
      prefs.setString(_key, cloudCurrency);
      return cloudCurrency;
    }

    // 2. Otherwise check locally saved preference on this device
    final saved = prefs.getString(_key);
    if (saved != null && saved.isNotEmpty) {
      Formatters.currentCurrency = saved;
      // If user is signed in but cloud doesn't have it yet, sync to cloud
      if (user != null && (user.currency == null || user.currency!.trim().isEmpty)) {
        _syncToCloud(user.uid, saved);
      }
      return saved;
    }

    // 3. Fallback: Default to project standard Rs. (or detected country)
    final detected = detectDefaultCurrency();
    Formatters.currentCurrency = detected;
    prefs.setString(_key, detected);
    if (user != null) {
      _syncToCloud(user.uid, detected);
    }
    return detected;
  }

  Future<void> setCurrency(String newCurrency) async {
    state = newCurrency;
    Formatters.currentCurrency = newCurrency;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, newCurrency);

    final uid = ref.read(currentUidProvider);
    if (uid != null && uid.isNotEmpty) {
      await _syncToCloud(uid, newCurrency);
    }
  }

  Future<void> _syncToCloud(String uid, String currency) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'currency': currency,
      });
    } catch (_) {
      // Offline or network error - will sync when online
    }
  }
}

final currencyProvider =
    NotifierProvider<CurrencyNotifier, String>(CurrencyNotifier.new);
