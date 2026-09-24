import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/core/constants/app_categories.dart';
import 'package:pennypal/features/reports/domain/report_calculator.dart';
import 'package:pennypal/features/transactions/domain/transaction_filter.dart';

import 'finance_test_helpers.dart';

void main() {
  final now = DateTime(2026, 9, 24, 15);

  final all = [
    income(50000, DateTime(2026, 9, 1)),
    income(45000, DateTime(2026, 8, 1)),
    expense(450, ExpenseCategory.food, DateTime(2026, 9, 24, 13)),
    expense(3200, ExpenseCategory.food, DateTime(2026, 9, 21)),
    expense(1200, ExpenseCategory.transport, DateTime(2026, 9, 2)),
    expense(9000, ExpenseCategory.shopping, DateTime(2026, 8, 15)),
    expense(2000, ExpenseCategory.bills, DateTime(2026, 7, 10)),
    expense(700, ExpenseCategory.food, DateTime(2025, 12, 30)),
  ];

  group('ReportPeriod ranges', () {
    test('this month and last month', () {
      final thisMonth = ReportPeriod.thisMonth.range(now);
      expect(thisMonth.start, DateTime(2026, 9, 1));
      expect(thisMonth.end, DateTime(2026, 9, 30));
      final last = ReportPeriod.lastMonth.range(now);
      expect(last.start, DateTime(2026, 8, 1));
      expect(last.end, DateTime(2026, 8, 31));
    });

    test('last 3 months and this year', () {
      final three = ReportPeriod.last3Months.range(now);
      expect(three.start, DateTime(2026, 7, 1));
      expect(three.end, DateTime(2026, 9, 30));
      final year = ReportPeriod.thisYear.range(now);
      expect(year.start, DateTime(2026, 1, 1));
      expect(year.end, DateTime(2026, 12, 31));
    });

    test('budget month follows the period', () {
      expect(ReportPeriod.thisMonth.budgetMonth(now), DateTime(2026, 9));
      expect(ReportPeriod.lastMonth.budgetMonth(now), DateTime(2026, 8));
      expect(ReportPeriod.thisYear.budgetMonth(now), DateTime(2026, 9));
    });
  });

  group('ReportCalculator', () {
    test('totals, categories and shares for a period', () {
      final r = ReportCalculator.forRange(all, ReportPeriod.thisMonth.range(now));
      expect(r.income, 50000);
      expect(r.expense, 4850);
      expect(r.net, 45150);
      expect(r.transactionCount, 4);
      expect(r.categories.first.category, ExpenseCategory.food);
      expect(r.categories.first.amount, 3650);
      expect(r.categories.first.share, closeTo(3650 / 4850, 1e-9));
      expect(r.topCategory?.category, ExpenseCategory.food);
      expect(r.keptFromIncome, closeTo(45150 / 50000, 1e-9));
    });

    test('categories are sorted largest first and shares add up', () {
      final r = ReportCalculator.forRange(all, ReportPeriod.thisYear.range(now));
      final amounts = r.categories.map((c) => c.amount).toList();
      expect(amounts, [...amounts]..sort((a, b) => b.compareTo(a)));
      expect(r.categories.fold<double>(0, (s, c) => s + c.share), closeTo(1, 1e-9));
    });

    test('a period with no transactions is empty and safe', () {
      final r = ReportCalculator.forRange(all, DateRange(DateTime(2024, 1, 1), DateTime(2024, 1, 31)));
      expect(r.transactionCount, 0);
      expect(r.expense, 0);
      expect(r.keptFromIncome, isNull);
      expect(r.topCategory, isNull);
    });

    test('monthly totals cover six months across a year boundary', () {
      final totals = ReportCalculator.monthlyTotals(all, DateTime(2026, 1), months: 6);
      expect(totals.map((m) => m.month).toList(), [
        DateTime(2025, 8),
        DateTime(2025, 9),
        DateTime(2025, 10),
        DateTime(2025, 11),
        DateTime(2025, 12),
        DateTime(2026, 1),
      ]);
      expect(totals[4].expense, 700);
    });

    test('monthly totals end with the current month, oldest first', () {
      final totals = ReportCalculator.monthlyTotals(all, now);
      expect(totals, hasLength(6));
      expect(totals.last.expense, 4850);
      expect(totals[4].expense, 9000); // August
      expect(totals[3].expense, 2000); // July
    });

    test('days covered stops at today for the current period', () {
      final range = ReportPeriod.thisMonth.range(now);
      expect(ReportCalculator.daysCovered(range, now), 24);
      expect(ReportCalculator.daysCovered(ReportPeriod.lastMonth.range(now), now), 31);
      expect(ReportCalculator.daysCovered(range, DateTime(2026, 8, 1)), 1);
    });
  });
}
