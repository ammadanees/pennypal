import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/core/services/currency_exchange_service.dart';
import 'package:pennypal/core/services/currency_service.dart';
import 'package:pennypal/data/record_store.dart';
import 'package:pennypal/features/transactions/domain/finance_transaction.dart';

void main() {
  group('CurrencyExchangeService', () {
    final service = CurrencyExchangeService();

    test('same currency returns 1.0 rate', () async {
      final result = await service.fetchRate(fromCode: 'USD', toCode: 'USD');
      expect(result.rate, 1.0);
    });

    test('fallback rates calculate reasonably between PKR and USD', () {
      final pkrToUsd = service.getFallbackRate('PKR', 'USD');
      expect(pkrToUsd, lessThan(0.01));
      expect(pkrToUsd, greaterThan(0.001));

      final usdToPkr = service.getFallbackRate('USD', 'PKR');
      expect(usdToPkr, greaterThan(200.0));
    });
  });

  group('FinanceTransaction currency persistence', () {
    test('transaction preserves explicit currency', () {
      final tx = FinanceTransaction(
        id: 'tx_1',
        type: TransactionType.expense,
        amount: 25.50,
        currency: '\$',
        date: DateTime(2026, 10, 26),
        createdAt: DateTime(2026, 10, 26),
      );

      final map = tx.toMap();
      expect(map['currency'], '\$');
      expect(map['amount'], 25.50);

      final restored = FinanceTransaction.fromRecord(
        StoredRecord(id: 'tx_1', data: map),
      );
      expect(restored.currency, '\$');
      expect(restored.amount, 25.50);
    });

    test('copyWith updates currency and amount cleanly', () {
      final tx = FinanceTransaction(
        id: 'tx_2',
        type: TransactionType.income,
        amount: 10000.0,
        currency: 'Rs.',
        date: DateTime(2026, 10, 26),
        createdAt: DateTime(2026, 10, 26),
      );

      final converted = tx.copyWith(
        amount: 35.90,
        currency: '\$',
      );

      expect(converted.amount, 35.90);
      expect(converted.currency, '\$');
    });
  });

  group('Supported currencies', () {
    test('contains common currencies including PKR and USD', () {
      final codes = supportedCurrencies.map((c) => c.code).toSet();
      expect(codes.contains('PKR'), isTrue);
      expect(codes.contains('USD'), isTrue);
      expect(codes.contains('EUR'), isTrue);
    });

    test('detectDefaultCurrency returns valid supported symbol', () {
      final detected = CurrencyNotifier.detectDefaultCurrency();
      final symbols = supportedCurrencies.map((c) => c.symbol).toSet();
      expect(symbols.contains(detected), isTrue);
    });
  });
}
