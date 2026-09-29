import 'dart:math' as math;

import '../../../core/utils/formatters.dart';
import '../../budgets/domain/budget.dart';
import '../../transactions/domain/finance_transaction.dart';
import 'finance_calculator.dart';

enum HealthTier {
  master('Financial Master', 'Outstanding budgeting & savings discipline'),
  disciplined(
      'Disciplined Saver', 'Healthy positive cashflow and habit tracking'),
  building('Building Habits',
      'Making steady progress, watch discretionary expenses'),
  needsAttention(
      'Needs Attention', 'Expenses are outpacing savings or budget limits');

  const HealthTier(this.title, this.description);
  final String title;
  final String description;
}

class FinancialHealthScore {
  const FinancialHealthScore({
    required this.score,
    required this.tier,
    required this.budgetScore,
    required this.savingsScore,
    required this.consistencyScore,
    required this.burnRate,
    required this.projectedSpend,
    required this.runwayDays,
    required this.recommendation,
  });

  final int score;
  final HealthTier tier;

  final int budgetScore;
  final int savingsScore;
  final int consistencyScore;

  final double burnRate;
  final double projectedSpend;
  final int runwayDays;
  final String recommendation;
}

abstract final class FinancialHealthCalculator {
  static FinancialHealthScore calculate({
    required List<FinanceTransaction> transactions,
    required Budget? budget,
    required DateTime now,
    bool hasSavingsGoal = false,
  }) {
    final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysElapsed = math.max(1, now.day);
    final daysRemaining = math.max(0, totalDaysInMonth - daysElapsed);

    final summary = FinanceCalculator.monthSummary(transactions, now);
    final monthIncome = summary.income;
    final monthExpense = summary.expense;
    final allTimeBalance = FinanceCalculator.balance(transactions);

    final burnRate = monthExpense > 0 ? (monthExpense / daysElapsed) : 0.0;
    final projectedSpend = monthExpense + (burnRate * daysRemaining);
    final runwayDays = burnRate > 0 && allTimeBalance > 0
        ? (allTimeBalance / burnRate).floor()
        : (allTimeBalance > 0 ? 999 : 0);

    int budgetScore = 25;
    if (budget != null && budget.totalAmount > 0) {
      final paceRatio = daysElapsed / totalDaysInMonth;
      final expectedSpendToDate = budget.totalAmount * paceRatio;

      if (monthExpense <= expectedSpendToDate) {
        budgetScore = 40;
      } else if (monthExpense <= budget.totalAmount) {
        final overPaceFraction = (monthExpense - expectedSpendToDate) /
            (budget.totalAmount - expectedSpendToDate + 1);
        budgetScore = math.max(20, (40 - (overPaceFraction * 20)).round());
      } else {
        final overBudgetAmount = monthExpense - budget.totalAmount;
        final penalty = (overBudgetAmount / budget.totalAmount * 20).round();
        budgetScore = math.max(0, 15 - penalty);
      }
    } else {
      if (monthExpense == 0) {
        budgetScore = 30;
      } else if (monthIncome > 0 && monthExpense <= monthIncome) {
        budgetScore = 25;
      } else {
        budgetScore = math.max(
            10,
            20 -
                ((monthExpense / (monthIncome == 0 ? 1000 : monthIncome)) * 10)
                    .round());
      }
    }

    int savingsScore = 15;
    if (monthIncome > 0) {
      final savingsRate = (monthIncome - monthExpense) / monthIncome;
      if (savingsRate >= 0.25) {
        savingsScore = 30;
      } else if (savingsRate > 0) {
        savingsScore = math.max(5, (savingsRate / 0.25 * 30).round());
      } else {
        savingsScore = 0;
      }
    } else {
      savingsScore = monthExpense == 0 ? 15 : 5;
    }

    final distinctDays = transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .map((t) => t.date.day)
        .toSet()
        .length;

    int consistencyScore = math.min(20, distinctDays * 4);
    if (hasSavingsGoal) consistencyScore += 10;
    consistencyScore = consistencyScore.clamp(0, 30);

    final compositeScore =
        (budgetScore + savingsScore + consistencyScore).clamp(0, 100);

    final tier = switch (compositeScore) {
      >= 80 => HealthTier.master,
      >= 65 => HealthTier.disciplined,
      >= 45 => HealthTier.building,
      _ => HealthTier.needsAttention,
    };

    String recommendation;
    if (budget != null &&
        budget.totalAmount > 0 &&
        projectedSpend > budget.totalAmount) {
      final targetDaily = daysRemaining > 0
          ? math.max(0.0, (budget.totalAmount - monthExpense) / daysRemaining)
          : 0.0;
      recommendation =
          'Limit spend to ~${Formatters.money(targetDaily.floorToDouble())}/day to finish the month within budget.';
    } else if (monthExpense > monthIncome && monthIncome > 0) {
      recommendation =
          'Expenses exceed monthly income. Trim discretionary spending to rebuild your balance.';
    } else if (savingsScore < 20 && monthIncome > 0) {
      recommendation =
          'Try allocating 10% more into savings or goals to level up your score.';
    } else if (distinctDays < 3) {
      recommendation =
          'Log your daily expenses consistently to build a stronger financial discipline score.';
    } else {
      recommendation =
          'Excellent financial pacing! Your cashflow is healthy and your habits are consistent.';
    }

    return FinancialHealthScore(
      score: compositeScore,
      tier: tier,
      budgetScore: budgetScore,
      savingsScore: savingsScore,
      consistencyScore: consistencyScore,
      burnRate: burnRate,
      projectedSpend: projectedSpend,
      runwayDays: runwayDays,
      recommendation: recommendation,
    );
  }
}
