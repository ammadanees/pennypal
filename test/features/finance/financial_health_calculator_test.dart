import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/core/constants/app_categories.dart';
import 'package:pennypal/features/budgets/domain/budget.dart';
import 'package:pennypal/features/dashboard/domain/financial_health_calculator.dart';

import 'finance_test_helpers.dart';

void main() {
  final now = DateTime(2026, 9, 15, 12); // Day 15 of 30-day month

  group('FinancialHealthCalculator', () {
    test('empty transactions returns neutral building score', () {
      final res = FinancialHealthCalculator.calculate(
        transactions: const [],
        budget: null,
        now: now,
      );

      expect(res.score, inInclusiveRange(30, 60));
      expect(res.burnRate, 0);
      expect(res.projectedSpend, 0);
    });

    test('disciplined student staying under budget achieves high score', () {
      final txs = [
        income(40000, DateTime(2026, 9, 1)),
        expense(1000, ExpenseCategory.food, DateTime(2026, 9, 3)),
        expense(1200, ExpenseCategory.transport, DateTime(2026, 9, 6)),
        expense(800, ExpenseCategory.food, DateTime(2026, 9, 9)),
        expense(1500, ExpenseCategory.entertainment, DateTime(2026, 9, 12)),
        expense(500, ExpenseCategory.food, DateTime(2026, 9, 14)),
      ];

      final budget = Budget(
        month: DateTime(2026, 9),
        totalAmount: 20000,
        categoryLimits: {ExpenseCategory.food: 8000},
        alertThreshold: 0.8,
        createdAt: DateTime(2026, 9, 1),
      );

      final res = FinancialHealthCalculator.calculate(
        transactions: txs,
        budget: budget,
        now: now,
        hasSavingsGoal: true,
      );

      // Spend is only 5,000 at day 15 (expected pace 10,000)
      expect(res.budgetScore, 40);
      expect(res.score, greaterThanOrEqualTo(80));
      expect(res.tier, HealthTier.master);
      expect(res.burnRate, closeTo(5000 / 15, 1));
      expect(res.projectedSpend, closeTo(10000, 100));
    });

    test('overspending drops budget score and alerts user', () {
      final txs = [
        income(10000, DateTime(2026, 9, 1)),
        expense(15000, ExpenseCategory.shopping, DateTime(2026, 9, 10)),
      ];

      final budget = Budget(
        month: DateTime(2026, 9),
        totalAmount: 8000,
        categoryLimits: const {},
        alertThreshold: 0.8,
        createdAt: DateTime(2026, 9, 1),
      );

      final res = FinancialHealthCalculator.calculate(
        transactions: txs,
        budget: budget,
        now: now,
      );

      expect(res.budgetScore, lessThanOrEqualTo(10));
      expect(res.score, lessThan(50));
      expect(res.tier, HealthTier.needsAttention);
      expect(res.projectedSpend, greaterThan(budget.totalAmount));
    });

    test('runwayDays calculates days remaining based on balance and burn rate', () {
      final txs = [
        income(30000, DateTime(2026, 9, 1)),
        expense(6000, ExpenseCategory.food, DateTime(2026, 9, 10)), // 6000 spent in 10 days = 600/day
      ];

      final res = FinancialHealthCalculator.calculate(
        transactions: txs,
        budget: null,
        now: DateTime(2026, 9, 10),
      );

      // Balance = 24,000. Burn rate = 600/day. Runway = 24,000 / 600 = 40 days
      expect(res.burnRate, 600);
      expect(res.runwayDays, 40);
    });
  });
}
