import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/record_store.dart';
import '../../../data/record_store_provider.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/debt_record.dart';

class DebtRepository {
  DebtRepository(this._store, this._uid);

  static const _collection = 'debts';

  final RecordStore _store;
  final String _uid;

  Stream<List<DebtRecord>> watchAll() => _store
      .watch(_uid, _collection)
      .map((records) => records.map(DebtRecord.fromRecord).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

  Future<void> save(DebtRecord debt) =>
      _store.upsert(_uid, _collection, debt.id, debt.toMap());

  Future<void> delete(String id) => _store.delete(_uid, _collection, id);

  Future<void> toggleSettled(DebtRecord debt) {
    final updated = debt.copyWith(
      isSettled: !debt.isSettled,
      settledAt: !debt.isSettled ? DateTime.now() : null,
    );
    return save(updated);
  }
}

final debtRepositoryProvider = Provider<DebtRepository>(
  (ref) => DebtRepository(
    ref.watch(recordStoreProvider),
    ref.watch(currentUidProvider) ?? '',
  ),
);

final debtsProvider = StreamProvider<List<DebtRecord>>((ref) {
  if (ref.watch(currentUidProvider) == null) {
    return Stream.value(const <DebtRecord>[]);
  }
  return ref.watch(debtRepositoryProvider).watchAll();
});
