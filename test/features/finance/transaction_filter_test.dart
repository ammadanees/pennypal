import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/core/constants/app_categories.dart';
import 'package:pennypal/features/transactions/domain/finance_transaction.dart';
import 'package:pennypal/features/transactions/domain/transaction_filter.dart';

import 'finance_test_helpers.dart';

void main() {
  final all = [
    expense(450, ExpenseCategory.food, DateTime(2026, 9, 24, 13), description: 'Lunch'),
    expense(1200, ExpenseCategory.transport, DateTime(2026, 9, 20, 8), description: 'Bus pass'),
    expense(3500, ExpenseCategory.education, DateTime(2026, 9, 5, 15), description: 'Course books'),
    income(50000, DateTime(2026, 9, 1, 9)),
  ];

  test('no filter returns everything', () {
    expect(const TransactionFilter().apply(all), hasLength(4));
    expect(const TransactionFilter().isActive, isFalse);
  });

  test('search matches title, category and amount, ignoring case', () {
    expect(const TransactionFilter(query: 'LUNCH').apply(all), hasLength(1));
    expect(const TransactionFilter(query: 'transport').apply(all), hasLength(1));
    expect(const TransactionFilter(query: '3500').apply(all), hasLength(1));
    expect(const TransactionFilter(query: 'allowance').apply(all).single.isIncome, isTrue);
    expect(const TransactionFilter(query: 'zzz').apply(all), isEmpty);
  });

  test('type and category filters', () {
    expect(const TransactionFilter(type: TransactionType.income).apply(all), hasLength(1));
    expect(const TransactionFilter(type: TransactionType.expense).apply(all), hasLength(3));
    final food = const TransactionFilter(category: ExpenseCategory.food).apply(all);
    expect(food.single.description, 'Lunch');
  });

  test('date range is inclusive of both end days', () {
    final range = DateRange(DateTime(2026, 9, 20), DateTime(2026, 9, 24));
    final result = TransactionFilter(range: range).apply(all);
    expect(result, hasLength(2));
    expect(range.contains(DateTime(2026, 9, 24, 23, 59)), isTrue);
    expect(range.contains(DateTime(2026, 9, 25)), isFalse);
  });

  test('filters combine', () {
    final f = const TransactionFilter(query: 'bus', type: TransactionType.expense);
    expect(f.apply(all).single.description, 'Bus pass');
    expect(f.isActive, isTrue);
  });
}
