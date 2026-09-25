import '../../../core/constants/app_categories.dart';
import '../../../core/utils/app_dates.dart';
import '../../../core/utils/formatters.dart';
import '../../budgets/domain/budget.dart';
import '../../budgets/domain/budget_calculator.dart';
import '../../dashboard/domain/finance_calculator.dart';
import '../../transactions/domain/finance_transaction.dart';
import '../../transactions/domain/transaction_filter.dart';

enum InsightKind { good, watch, info }

class Insight {
  const Insight(this.kind, this.message);

  final InsightKind kind;
  final String message;
}

/// Friendly one-line observations about this month, based on the student's
/// own numbers. General information only, never advice.
abstract final class InsightCalculator {
  static List<Insight> forMonth(
    List<FinanceTransaction> all, {
    Budget? budget,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final monthStart = AppDates.startOfMonth(today);
    final summary = FinanceCalculator.monthSummary(all, today);
    final insights = <Insight>[];

    // Compared with the same stretch of last month.
    final lastStart = AppDates.addMonths(monthStart, -1);
    final lastSameSpan = _expenseIn(
      all,
      DateRange(lastStart, AppDates.addMonths(AppDates.dateOnly(today), -1)),
    );
    if (lastSameSpan > 0 && summary.expense > 0) {
      final diff = summary.expense - lastSameSpan;
      if (diff.abs() >= 1) {
        insights.add(diff < 0
            ? Insight(InsightKind.good,
                'You have spent ${Formatters.money(-diff)} less than at this point last month. Keep it up!')
            : Insight(InsightKind.watch,
                'You have spent ${Formatters.money(diff)} more than at this point last month.'));
      }
    }

    if (budget != null) {
      final status = BudgetCalculator.status(budget, summary);
      final daysLeft = DateTime(today.year, today.month + 1, 0).day - today.day + 1;
      if (status.level == BudgetLevel.over) {
        insights.add(Insight(InsightKind.watch,
            'You are ${Formatters.money(status.overBy)} over budget this month.'));
      } else if (status.remaining > 0 && daysLeft > 0) {
        final perDay = status.remaining / daysLeft;
        insights.add(Insight(InsightKind.info,
            'You can spend about ${Formatters.money(perDay.floorToDouble())} a day for the rest of the month and stay within budget.'));
      }
    }

    if (summary.byCategory.isNotEmpty && summary.expense > 0) {
      final top = summary.byCategory.entries
          .reduce((a, b) => a.value >= b.value ? a : b);
      insights.add(Insight(InsightKind.info,
          '${top.key.label} is your biggest expense at ${Formatters.percent(top.value / summary.expense)} of this month\'s spending.'));
    }

    return insights;
  }

  static double _expenseIn(List<FinanceTransaction> all, DateRange range) {
    var total = 0.0;
    for (final t in all) {
      if (!t.isIncome && range.contains(t.date)) total += t.amount;
    }
    return total;
  }

  /// Exposed for reports: total expense in a range.
  static double expenseIn(List<FinanceTransaction> all, DateRange range) =>
      _expenseIn(all, range);

  /// Unused categories helper kept for tests.
  static ExpenseCategory? topCategory(MonthSummary s) => s.byCategory.isEmpty
      ? null
      : s.byCategory.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}
