import '../../../core/constants/app_categories.dart';
import '../../transactions/domain/finance_transaction.dart';

class MonthSummary {
  const MonthSummary({
    required this.income,
    required this.expense,
    required this.byCategory,
  });

  final double income;
  final double expense;
  final Map<ExpenseCategory, double> byCategory;

  double get net => income - expense;
}

abstract final class FinanceCalculator {
  /// All-time income minus all-time expenses.
  static double balance(List<FinanceTransaction> all) {
    var total = 0.0;
    for (final t in all) {
      total += t.isIncome ? t.amount : -t.amount;
    }
    return total;
  }

  static MonthSummary monthSummary(
    List<FinanceTransaction> all,
    DateTime month,
  ) {
    var income = 0.0;
    var expense = 0.0;
    final byCategory = <ExpenseCategory, double>{};
    for (final t in all) {
      if (t.date.year != month.year || t.date.month != month.month) continue;
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
        final category = t.category ?? ExpenseCategory.miscellaneous;
        byCategory[category] = (byCategory[category] ?? 0) + t.amount;
      }
    }
    return MonthSummary(income: income, expense: expense, byCategory: byCategory);
  }
}
