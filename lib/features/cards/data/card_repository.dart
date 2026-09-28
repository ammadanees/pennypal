import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/record_store.dart';
import '../../../data/record_store_provider.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/payment_card.dart';

class CardLimitExceededException implements Exception {
  const CardLimitExceededException([
    this.message = 'Maximum of 2 cards allowed per user. Please delete an existing card first.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class CardRepository {
  CardRepository(this._store, this._uid);

  static const _collection = 'cards';
  static const int maxCardsPerUser = 2;

  final RecordStore _store;
  final String _uid;

  Stream<List<PaymentCard>> watchAll() =>
      _store.watch(_uid, _collection).map((records) {
        final list = records.map(PaymentCard.fromRecord).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  Future<void> save(PaymentCard card) async {
    final existing = await _store.watch(_uid, _collection).first;
    final isUpdate = existing.any((r) => r.id == card.id);
    if (!isUpdate && existing.length >= maxCardsPerUser) {
      throw const CardLimitExceededException();
    }
    return _store.upsert(_uid, _collection, card.id, card.toMap());
  }

  Future<void> delete(String id) => _store.delete(_uid, _collection, id);
}

final cardRepositoryProvider = Provider<CardRepository>(
  (ref) => CardRepository(
    ref.watch(recordStoreProvider),
    ref.watch(currentUidProvider) ?? '',
  ),
);

final cardsProvider = StreamProvider<List<PaymentCard>>((ref) {
  if (ref.watch(currentUidProvider) == null) {
    return Stream.value(const <PaymentCard>[]);
  }
  return ref.watch(cardRepositoryProvider).watchAll();
});
