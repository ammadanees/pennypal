import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_dates.dart';
import '../../../data/record_store.dart';
import '../../../data/record_store_provider.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/budget.dart';

class BudgetRepository {
  BudgetRepository(this._store, this._uid);

  static const _collection = 'budgets';

  final RecordStore _store;
  final String _uid;

  Stream<List<Budget>> watchAll() => _store
      .watch(_uid, _collection)
      .map((records) => records.map(Budget.fromRecord).toList());

  Future<void> save(Budget budget) =>
      _store.upsert(_uid, _collection, budget.id, budget.toMap());

  Future<void> delete(Budget budget) =>
      _store.delete(_uid, _collection, budget.id);
}

final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => BudgetRepository(
    ref.watch(recordStoreProvider),
    ref.watch(currentUidProvider) ?? '',
  ),
);

final budgetsProvider = StreamProvider<List<Budget>>((ref) {
  if (ref.watch(currentUidProvider) == null) {
    return Stream.value(const <Budget>[]);
  }
  return ref.watch(budgetRepositoryProvider).watchAll();
});

final selectedBudgetMonthProvider = StateProvider<DateTime>(
  (ref) => AppDates.startOfMonth(DateTime.now()),
);

extension BudgetListX on List<Budget> {
  Budget? forMonth(DateTime month) {
    final key = AppDates.monthKey(month);
    return where((b) => b.id == key).firstOrNull;
  }
}
