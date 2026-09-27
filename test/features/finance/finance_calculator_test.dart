import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/core/constants/app_categories.dart';
import 'package:pennypal/features/budgets/domain/budget.dart';
import 'package:pennypal/features/budgets/domain/budget_calculator.dart';
import 'package:pennypal/features/dashboard/domain/finance_calculator.dart';

import 'finance_test_helpers.dart';

void main() {
  final sep = DateTime(2026, 9, 10, 12);
  final aug = DateTime(2026, 8, 20, 12);

  final all = [
    income(50000, DateTime(2026, 9, 1)),
    income(2000, aug),
    expense(450, ExpenseCategory.food, sep),
    expense(3200, ExpenseCategory.food, sep),
    expense(1200, ExpenseCategory.transport, sep),
    expense(999, ExpenseCategory.bills, aug),
  ];

  group('FinanceCalculator', () {
    test('balance is all-time income minus expenses', () {
      expect(FinanceCalculator.balance(all), 50000 + 2000 - 450 - 3200 - 1200 - 999);
    });

    test('month summary only counts the given month', () {
      final s = FinanceCalculator.monthSummary(all, DateTime(2026, 9));
      expect(s.income, 50000);
      expect(s.expense, 4850);
      expect(s.byCategory[ExpenseCategory.food], 3650);
      expect(s.byCategory[ExpenseCategory.bills], isNull);
      expect(s.net, 45150);
    });

    test('empty list gives zeros', () {
      expect(FinanceCalculator.balance(const []), 0);
      final s = FinanceCalculator.monthSummary(const [], DateTime(2026, 9));
      expect(s.income, 0);
      expect(s.expense, 0);
    });

    test('modeSummaries separates income, expense and preserves sum', () {
      final txs = [
        income(10000, sep, paymentMode: PaymentMode.cash),
        income(25000, sep, paymentMode: PaymentMode.bankTransfer),
        income(5000, sep, paymentMode: PaymentMode.card),
        expense(2000, ExpenseCategory.food, sep, paymentMode: PaymentMode.cash),
        expense(4000, ExpenseCategory.shopping, sep, paymentMode: PaymentMode.card),
        expense(1000, ExpenseCategory.bills, sep, paymentMode: PaymentMode.bankTransfer),
      ];

      final summaries = FinanceCalculator.modeSummaries(txs, month: sep);
      final cash = summaries.firstWhere((s) => s.mode == PaymentMode.cash);
      final card = summaries.firstWhere((s) => s.mode == PaymentMode.card);
      final bank = summaries.firstWhere((s) => s.mode == PaymentMode.bankTransfer);

      expect(cash.income, 10000);
      expect(cash.expense, 2000);
      expect(cash.allTimeBalance, 8000);

      expect(card.income, 5000);
      expect(card.expense, 4000);
      expect(card.allTimeBalance, 1000);

      expect(bank.income, 25000);
      expect(bank.expense, 1000);
      expect(bank.allTimeBalance, 24000);

      // Verify overall sum remains preserved
      final sumOfBalances = summaries.fold<double>(0, (acc, s) => acc + s.allTimeBalance);
      expect(sumOfBalances, FinanceCalculator.balance(txs));
      expect(sumOfBalances, 33000);
    });
  });

  group('BudgetCalculator', () {
    Budget budget(double total, Map<ExpenseCategory, double> limits,
            {double threshold = 0.8}) =>
        Budget(
          month: DateTime(2026, 9),
          totalAmount: total,
          categoryLimits: limits,
          alertThreshold: threshold,
          createdAt: DateTime(2026, 9),
        );

    test('on track, nearing and over levels', () {
      final summary = FinanceCalculator.monthSummary(all, DateTime(2026, 9)); // 4,850 spent
      expect(BudgetCalculator.status(budget(20000, {}), summary).level, BudgetLevel.onTrack);
      expect(BudgetCalculator.status(budget(5500, {}), summary).level, BudgetLevel.nearing);
      final over = BudgetCalculator.status(budget(4000, {}), summary);
      expect(over.level, BudgetLevel.over);
      expect(over.overBy, 850);
      expect(over.remaining, -850);
    });

    test('lists limited categories and unbudgeted spending', () {
      final summary = FinanceCalculator.monthSummary(all, DateTime(2026, 9));
      final status = BudgetCalculator.status(
        budget(20000, {ExpenseCategory.food: 5000, ExpenseCategory.education: 1000}),
        summary,
      );
      final food = status.categories.firstWhere((c) => c.category == ExpenseCategory.food);
      expect(food.spent, 3650);
      expect(food.ratio, closeTo(0.73, 0.001));
      final transport =
          status.categories.firstWhere((c) => c.category == ExpenseCategory.transport);
      expect(transport.limit, isNull);
      expect(status.categories.any((c) => c.category == ExpenseCategory.education), isTrue);
    });

    test('zero total does not divide by zero', () {
      final status = BudgetCalculator.status(
        budget(0, {}),
        FinanceCalculator.monthSummary(all, DateTime(2026, 9)),
      );
      expect(status.ratio, 0);
    });

    test('budget round-trips through its map', () {
      final b = budget(40000, {ExpenseCategory.food: 15000});
      expect(b.id, '2026-09');
      expect(b.toMap()['categoryLimits'], {'food': 15000.0});
    });
  });
}
