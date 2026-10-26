import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/record_store.dart';
import '../../data/record_store_provider.dart';
import '../../features/auth/data/auth_providers.dart';
import 'currency_service.dart';

enum CurrencySwitchMode {
  convertAll,
  newRecordsOnly,
  symbolOnly,
}

class CurrencyMigrationService {
  CurrencyMigrationService(this._store, this._uid, this._ref);

  final RecordStore _store;
  final String _uid;
  final Ref _ref;

  static double _round(double val) => double.parse(val.toStringAsFixed(2));

  Future<void> executeSwitch({
    required CurrencySwitchMode mode,
    required String oldSymbol,
    required String newSymbol,
    required double exchangeRate,
    void Function(String message)? onProgress,
  }) async {
    if (_uid.isEmpty) {
      // Just change preference if no user is signed in
      await _ref.read(currencyProvider.notifier).setCurrency(newSymbol);
      return;
    }

    switch (mode) {
      case CurrencySwitchMode.convertAll:
        await _executeConvertAll(
          oldSymbol: oldSymbol,
          newSymbol: newSymbol,
          rate: exchangeRate,
          onProgress: onProgress,
        );
        break;

      case CurrencySwitchMode.newRecordsOnly:
        await _executeNewRecordsOnly(
          oldSymbol: oldSymbol,
          newSymbol: newSymbol,
          onProgress: onProgress,
        );
        break;

      case CurrencySwitchMode.symbolOnly:
        onProgress?.call('Updating currency display...');
        await _ref.read(currencyProvider.notifier).setCurrency(newSymbol);
        break;
    }
  }

  Future<void> _executeConvertAll({
    required String oldSymbol,
    required String newSymbol,
    required double rate,
    void Function(String message)? onProgress,
  }) async {
    // 1. Transactions
    onProgress?.call('Converting transactions...');
    try {
      final txRecords = await _store.watch(_uid, 'transactions').first
          .timeout(const Duration(seconds: 3), onTimeout: () => const []);
      for (final rec in txRecords) {
        final rawAmount = (rec.data['amount'] as num?)?.toDouble() ?? 0.0;
        final converted = _round(rawAmount * rate);
        await _store.upsert(_uid, 'transactions', rec.id, {
          'amount': converted,
          'currency': newSymbol,
        });
      }
    } catch (_) {}

    // 2. Budgets
    onProgress?.call('Adjusting budgets...');
    try {
      final budgetRecords = await _store.watch(_uid, 'budgets').first
          .timeout(const Duration(seconds: 3), onTimeout: () => const []);
      for (final rec in budgetRecords) {
        final total = (rec.data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        final rawLimits = rec.data['categoryLimits'];
        final updatedLimits = <String, dynamic>{};
        if (rawLimits is Map) {
          for (final entry in rawLimits.entries) {
            if (entry.value is num) {
              updatedLimits[entry.key.toString()] =
                  _round((entry.value as num).toDouble() * rate);
            }
          }
        }
        await _store.upsert(_uid, 'budgets', rec.id, {
          'totalAmount': _round(total * rate),
          'categoryLimits': updatedLimits,
        });
      }
    } catch (_) {}

    // 3. Savings Goals
    onProgress?.call('Updating savings goals...');
    try {
      final savingsRecords = await _store.watch(_uid, 'savings_goals').first
          .timeout(const Duration(seconds: 3), onTimeout: () => const []);
      for (final rec in savingsRecords) {
        final target = (rec.data['targetAmount'] as num?)?.toDouble() ?? 0.0;
        final current = (rec.data['currentAmount'] as num?)?.toDouble() ?? 0.0;
        final monthly =
            (rec.data['monthlyContribution'] as num?)?.toDouble() ?? 0.0;
        await _store.upsert(_uid, 'savings_goals', rec.id, {
          'targetAmount': _round(target * rate),
          'currentAmount': _round(current * rate),
          'monthlyContribution': _round(monthly * rate),
        });
      }
    } catch (_) {}

    // 4. Debts
    onProgress?.call('Converting debts and loans...');
    try {
      final debtRecords = await _store.watch(_uid, 'debts').first
          .timeout(const Duration(seconds: 3), onTimeout: () => const []);
      for (final rec in debtRecords) {
        final amt = (rec.data['amount'] as num?)?.toDouble() ?? 0.0;
        await _store.upsert(_uid, 'debts', rec.id, {
          'amount': _round(amt * rate),
        });
      }
    } catch (_) {}

    // 5. Subscriptions
    onProgress?.call('Converting subscriptions...');
    try {
      final subRecords = await _store.watch(_uid, 'subscriptions').first
          .timeout(const Duration(seconds: 3), onTimeout: () => const []);
      for (final rec in subRecords) {
        final amt = (rec.data['amount'] as num?)?.toDouble() ?? 0.0;
        await _store.upsert(_uid, 'subscriptions', rec.id, {
          'amount': _round(amt * rate),
        });
      }
    } catch (_) {}

    // Finally, set active currency preference
    await _ref.read(currencyProvider.notifier).setCurrency(newSymbol);
  }

  Future<void> _executeNewRecordsOnly({
    required String oldSymbol,
    required String newSymbol,
    void Function(String message)? onProgress,
  }) async {
    onProgress?.call('Preserving past records in $oldSymbol...');
    try {
      final txRecords = await _store.watch(_uid, 'transactions').first
          .timeout(const Duration(seconds: 3), onTimeout: () => const []);
      for (final rec in txRecords) {
        final cur = rec.data['currency'] as String?;
        if (cur == null || cur.isEmpty) {
          await _store.upsert(_uid, 'transactions', rec.id, {
            'currency': oldSymbol,
          });
        }
      }
    } catch (_) {}

    // Set preference for future transactions
    await _ref.read(currencyProvider.notifier).setCurrency(newSymbol);
  }
}

final currencyMigrationServiceProvider =
    Provider<CurrencyMigrationService>((ref) {
  final store = ref.watch(recordStoreProvider);
  final uid = ref.watch(currentUidProvider) ?? '';
  return CurrencyMigrationService(store, uid, ref);
});
