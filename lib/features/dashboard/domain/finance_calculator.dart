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
    return MonthSummary(
        income: income, expense: expense, byCategory: byCategory);
  }

  static List<PaymentModeSummary> modeSummaries(
    List<FinanceTransaction> all, {
    DateTime? month,
  }) {
    final inMap = <PaymentMode, double>{};
    final exMap = <PaymentMode, double>{};
    final balanceMap = <PaymentMode, double>{};
    final txCountMap = <PaymentMode, int>{};

    for (final t in all) {
      final mode = t.paymentMode ?? PaymentMode.cash;
      final delta = t.isIncome ? t.amount : -t.amount;
      balanceMap[mode] = (balanceMap[mode] ?? 0.0) + delta;
      txCountMap[mode] = (txCountMap[mode] ?? 0) + 1;

      if (month != null) {
        if (t.date.year != month.year || t.date.month != month.month) continue;
      }

      if (t.isIncome) {
        inMap[mode] = (inMap[mode] ?? 0.0) + t.amount;
      } else {
        exMap[mode] = (exMap[mode] ?? 0.0) + t.amount;
      }
    }

    return PaymentMode.values.map((mode) {
      return PaymentModeSummary(
        mode: mode,
        income: inMap[mode] ?? 0.0,
        expense: exMap[mode] ?? 0.0,
        allTimeBalance: balanceMap[mode] ?? 0.0,
        transactionCount: txCountMap[mode] ?? 0,
      );
    }).toList();
  }
}

class PaymentModeSummary {
  const PaymentModeSummary({
    required this.mode,
    required this.income,
    required this.expense,
    required this.allTimeBalance,
    this.transactionCount = 0,
  });

  final PaymentMode mode;
  final double income;
  final double expense;
  final double allTimeBalance;
  final int transactionCount;

  double get periodNet => income - expense;

  bool get hasActivity =>
      transactionCount > 0 || income > 0 || expense > 0 || allTimeBalance != 0;
}
