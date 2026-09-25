import 'dart:math' as math;

import '../../../core/constants/app_categories.dart';
import '../../../core/constants/report_strings.dart';
import '../../../core/utils/app_dates.dart';
import '../../transactions/domain/finance_transaction.dart';
import '../../transactions/domain/transaction_filter.dart';

enum ReportPeriod {
  thisMonth(ReportStrings.periodThisMonth),
  lastMonth(ReportStrings.periodLastMonth),
  last3Months(ReportStrings.periodLast3Months),
  thisYear(ReportStrings.periodThisYear);

  const ReportPeriod(this.label);

  final String label;

  DateRange range(DateTime now) {
    final monthStart = AppDates.startOfMonth(now);
    final endOfThisMonth = DateTime(now.year, now.month + 1, 0);
    switch (this) {
      case ReportPeriod.thisMonth:
        return DateRange(monthStart, endOfThisMonth);
      case ReportPeriod.lastMonth:
        return DateRange(
          AppDates.addMonths(monthStart, -1),
          DateTime(now.year, now.month, 0),
        );
      case ReportPeriod.last3Months:
        return DateRange(AppDates.addMonths(monthStart, -2), endOfThisMonth);
      case ReportPeriod.thisYear:
        return DateRange(DateTime(now.year), DateTime(now.year, 12, 31));
    }
  }

  /// The equally long stretch just before this one (same day span).
  DateRange previousRange(DateTime now) {
    final r = range(now);
    final shift = switch (this) {
      ReportPeriod.thisMonth || ReportPeriod.lastMonth => 1,
      ReportPeriod.last3Months => 3,
      ReportPeriod.thisYear => 12,
    };
    final today = AppDates.dateOnly(now);
    final coveredEnd = today.isBefore(r.end) ? today : r.end;
    return DateRange(
      AppDates.addMonths(r.start, -shift),
      AppDates.addMonths(coveredEnd, -shift),
    );
  }

  /// The month whose budget the report shows.
  DateTime budgetMonth(DateTime now) => this == ReportPeriod.lastMonth
      ? AppDates.addMonths(AppDates.startOfMonth(now), -1)
      : AppDates.startOfMonth(now);
}

class CategoryShare {
  const CategoryShare({
    required this.category,
    required this.amount,
    required this.share,
  });

  final ExpenseCategory category;
  final double amount;

  /// 0.0 to 1.0 of total expenses in the period.
  final double share;
}

class PeriodReport {
  const PeriodReport({
    required this.income,
    required this.expense,
    required this.categories,
    required this.transactionCount,
  });

  final double income;
  final double expense;

  /// Largest first. Only categories with spending.
  final List<CategoryShare> categories;
  final int transactionCount;

  double get net => income - expense;

  /// Share of income not spent, or null when there was no income.
  double? get keptFromIncome => income <= 0 ? null : net / income;

  CategoryShare? get topCategory => categories.firstOrNull;
}

class MonthTotal {
  const MonthTotal({
    required this.month,
    required this.income,
    required this.expense,
  });

  final DateTime month;
  final double income;
  final double expense;
}

abstract final class ReportCalculator {
  static PeriodReport forRange(List<FinanceTransaction> all, DateRange range) {
    var income = 0.0;
    var expense = 0.0;
    var count = 0;
    final byCategory = <ExpenseCategory, double>{};

    for (final t in all) {
      if (!range.contains(t.date)) continue;
      count++;
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
        final category = t.category ?? ExpenseCategory.miscellaneous;
        byCategory[category] = (byCategory[category] ?? 0) + t.amount;
      }
    }

    final categories = [
      for (final e in byCategory.entries)
        CategoryShare(
          category: e.key,
          amount: e.value,
          share: expense <= 0 ? 0 : e.value / expense,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    return PeriodReport(
      income: income,
      expense: expense,
      categories: categories,
      transactionCount: count,
    );
  }

  /// Totals for [months] months ending at [endMonth], oldest first.
  static List<MonthTotal> monthlyTotals(
    List<FinanceTransaction> all,
    DateTime endMonth, {
    int months = 6,
  }) {
    final end = AppDates.startOfMonth(endMonth);
    return [
      for (var i = months - 1; i >= 0; i--)
        _totalFor(all, AppDates.addMonths(end, -i)),
    ];
  }

  static MonthTotal _totalFor(List<FinanceTransaction> all, DateTime month) {
    var income = 0.0;
    var expense = 0.0;
    for (final t in all) {
      if (!AppDates.sameMonth(t.date, month)) continue;
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    return MonthTotal(month: month, income: income, expense: expense);
  }

  /// Spending over time for a sparkline: one value per day, or per week
  /// for long periods. Only days that have already happened.
  static List<double> spendingSeries(
    List<FinanceTransaction> all,
    DateRange range,
    DateTime now,
  ) {
    final start = AppDates.dateOnly(range.start);
    final days = daysCovered(range, now);
    final bucket = days > 62 ? 7 : 1;
    final buckets = List<double>.filled((days / bucket).ceil(), 0);
    for (final t in all) {
      if (t.isIncome || !range.contains(t.date)) continue;
      final index = AppDates.dateOnly(t.date).difference(start).inDays ~/ bucket;
      if (index >= 0 && index < buckets.length) buckets[index] += t.amount;
    }
    return buckets;
  }

  /// Days of the range that have already happened (at least 1).
  static int daysCovered(DateRange range, DateTime now) {
    final start = AppDates.dateOnly(range.start);
    final today = AppDates.dateOnly(now);
    final last = AppDates.dateOnly(range.end);
    final end = today.isBefore(last) ? today : last;
    return math.max(1, end.difference(start).inDays + 1);
  }
}
