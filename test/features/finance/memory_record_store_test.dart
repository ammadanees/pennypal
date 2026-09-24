import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/data/demo_seed.dart';
import 'package:pennypal/data/memory_record_store.dart';
import 'package:pennypal/features/auth/data/demo_auth_repository.dart';
import 'package:pennypal/features/dashboard/domain/finance_calculator.dart';
import 'package:pennypal/features/transactions/domain/finance_transaction.dart';

void main() {
  test('saving the same id twice updates instead of duplicating', () async {
    final store = MemoryRecordStore();
    await store.upsert('u1', 'transactions', 'a', {'amount': 10.0});
    await store.upsert('u1', 'transactions', 'a', {'amount': 25.0});
    final records = await store.watch('u1', 'transactions').first;
    expect(records, hasLength(1));
    expect(records.single.data['amount'], 25.0);
  });

  test('each student only sees their own records', () async {
    final store = MemoryRecordStore();
    await store.upsert('u1', 'transactions', 'a', {'amount': 10.0});
    await store.upsert('u2', 'transactions', 'b', {'amount': 20.0});
    expect(await store.watch('u1', 'transactions').first, hasLength(1));
    expect((await store.watch('u2', 'transactions').first).single.id, 'b');
  });

  test('delete removes the record and streams the change', () async {
    final store = MemoryRecordStore();
    await store.upsert('u1', 'transactions', 'a', {'amount': 10.0});
    final updates = <int>[];
    final sub = store.watch('u1', 'transactions').listen((r) => updates.add(r.length));
    await Future<void>.delayed(Duration.zero);
    await store.delete('u1', 'transactions', 'a');
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(updates, [1, 0]);
  });

  test('demo data matches the figures shown on the welcome screens', () async {
    final store = MemoryRecordStore();
    final now = DateTime(2026, 9, 24, 15);
    await seedDemoData(store, now: now);

    final records =
        await store.watch(DemoAuthRepository.studentUid, 'transactions').first;
    final all = records.map(FinanceTransaction.fromRecord).toList();
    final summary = FinanceCalculator.monthSummary(all, now);
    expect(summary.income, 50000);
    expect(summary.expense, 31200);
    expect(FinanceCalculator.balance(all), 18800);
  });
}
