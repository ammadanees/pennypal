import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/record_store.dart';
import '../../../data/record_store_provider.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/finance_transaction.dart';

class TransactionRepository {
  TransactionRepository(this._store, this._uid);

  static const _collection = 'transactions';

  final RecordStore _store;
  final String _uid;

  Stream<List<FinanceTransaction>> watchAll() =>
      _store.watch(_uid, _collection).map((records) {
        final list = records.map(FinanceTransaction.fromRecord).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        return list;
      });

  Future<void> save(FinanceTransaction t) =>
      _store.upsert(_uid, _collection, t.id, t.toMap());

  Future<void> delete(String id) => _store.delete(_uid, _collection, id);
}

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(
    ref.watch(recordStoreProvider),
    ref.watch(currentUidProvider) ?? '',
  ),
);

final transactionsProvider = StreamProvider<List<FinanceTransaction>>((ref) {
  if (ref.watch(currentUidProvider) == null) {
    return Stream.value(const <FinanceTransaction>[]);
  }
  return ref.watch(transactionRepositoryProvider).watchAll();
});
