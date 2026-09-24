import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/record_store.dart';
import '../../../data/record_store_provider.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/savings_goal.dart';

class SavingsRepository {
  SavingsRepository(this._store, this._uid);

  static const _collection = 'savingsGoals';

  final RecordStore _store;
  final String _uid;

  Stream<List<SavingsGoal>> watchAll() => _store
      .watch(_uid, _collection)
      .map((records) => records.map(SavingsGoal.fromRecord).toList());

  Future<void> save(SavingsGoal goal) =>
      _store.upsert(_uid, _collection, goal.id, goal.toMap());

  Future<void> delete(String id) => _store.delete(_uid, _collection, id);
}

final savingsRepositoryProvider = Provider<SavingsRepository>(
  (ref) => SavingsRepository(
    ref.watch(recordStoreProvider),
    ref.watch(currentUidProvider) ?? '',
  ),
);

final savingsGoalsProvider = StreamProvider<List<SavingsGoal>>((ref) {
  if (ref.watch(currentUidProvider) == null) {
    return Stream.value(const <SavingsGoal>[]);
  }
  return ref.watch(savingsRepositoryProvider).watchAll();
});
