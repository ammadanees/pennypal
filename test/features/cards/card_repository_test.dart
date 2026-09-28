import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/data/memory_record_store.dart';
import 'package:pennypal/features/cards/data/card_repository.dart';
import 'package:pennypal/features/cards/domain/payment_card.dart';

void main() {
  group('PaymentCard', () {
    test('displayName includes last4 when available', () {
      final card = PaymentCard(
        id: 'c1',
        name: 'Meezan Visa',
        last4: '4128',
        createdAt: DateTime(2026, 9, 25),
      );
      expect(card.displayName, 'Meezan Visa (•••• 4128)');
    });

    test('displayName omits last4 when null or empty', () {
      final card = PaymentCard(
        id: 'c2',
        name: 'Cash Card',
        createdAt: DateTime(2026, 9, 25),
      );
      expect(card.displayName, 'Cash Card');
    });

    test('serializes and deserializes correctly', () async {
      final store = MemoryRecordStore();
      final repo = CardRepository(store, 'test-user');

      final card = PaymentCard(
        id: 'card-101',
        name: 'SadaPay Debit',
        bank: 'SadaPay',
        last4: '9942',
        cardType: 'Debit',
        createdAt: DateTime(2026, 9, 25, 10, 0),
      );

      await repo.save(card);
      final cards = await repo.watchAll().first;
      expect(cards.length, 1);
      expect(cards.first.id, 'card-101');
      expect(cards.first.name, 'SadaPay Debit');
      expect(cards.first.last4, '9942');
      expect(cards.first.displayName, 'SadaPay Debit (•••• 9942)');

      await repo.delete('card-101');
      final afterDelete = await repo.watchAll().first;
      expect(afterDelete, isEmpty);
    });

    test('enforces maximum 2 cards per user', () async {
      final store = MemoryRecordStore();
      final repo = CardRepository(store, 'test-user');

      final card1 = PaymentCard(
        id: 'c1',
        name: 'Card 1',
        createdAt: DateTime(2026, 9, 25),
      );
      final card2 = PaymentCard(
        id: 'c2',
        name: 'Card 2',
        createdAt: DateTime(2026, 9, 25),
      );
      final card3 = PaymentCard(
        id: 'c3',
        name: 'Card 3',
        createdAt: DateTime(2026, 9, 25),
      );

      // Save 2 cards - should succeed
      await repo.save(card1);
      await repo.save(card2);
      final cards = await repo.watchAll().first;
      expect(cards.length, 2);

      // Attempting to save a 3rd card should throw CardLimitExceededException
      expect(
        () => repo.save(card3),
        throwsA(isA<CardLimitExceededException>()),
      );

      // Updating an existing card should succeed
      final updatedCard1 = PaymentCard(
        id: 'c1',
        name: 'Card 1 Renamed',
        createdAt: DateTime(2026, 9, 25),
      );
      await repo.save(updatedCard1);
      final cardsAfterUpdate = await repo.watchAll().first;
      expect(cardsAfterUpdate.length, 2);
      expect(cardsAfterUpdate.any((c) => c.name == 'Card 1 Renamed'), isTrue);
    });
  });
}
