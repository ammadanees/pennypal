import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/record_store.dart';
import '../../../data/record_store_provider.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/subscription_record.dart';

class SubscriptionRepository {
  SubscriptionRepository(this._store, this._uid);

  static const _collection = 'subscriptions';

  final RecordStore _store;
  final String _uid;

  Stream<List<SubscriptionRecord>> watchAll() => _store
      .watch(_uid, _collection)
      .map((records) => records.map(SubscriptionRecord.fromRecord).toList()
        ..sort((a, b) => a.dueDay.compareTo(b.dueDay)));

  Future<void> save(SubscriptionRecord sub) =>
      _store.upsert(_uid, _collection, sub.id, sub.toMap());

  Future<void> delete(String id) => _store.delete(_uid, _collection, id);

  Future<void> markPaid(SubscriptionRecord sub) {
    final updated = sub.copyWith(lastPaidDate: DateTime.now());
    return save(updated);
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => SubscriptionRepository(
    ref.watch(recordStoreProvider),
    ref.watch(currentUidProvider) ?? '',
  ),
);

final subscriptionsProvider = StreamProvider<List<SubscriptionRecord>>((ref) {
  if (ref.watch(currentUidProvider) == null) {
    return Stream.value(const <SubscriptionRecord>[]);
  }
  return ref.watch(subscriptionRepositoryProvider).watchAll();
});
