import '../../../core/constants/app_categories.dart';
import '../../dashboard/domain/finance_calculator.dart';
import 'budget.dart';

enum BudgetLevel { onTrack, nearing, over }

class CategoryUsage {
  const CategoryUsage({required this.category, required this.spent, this.limit});

  final ExpenseCategory category;
  final double spent;

  /// Null when the student set no limit for this category.
  final double? limit;

  double get ratio => (limit == null || limit! <= 0) ? 0 : spent / limit!;
}

class BudgetStatus {
  const BudgetStatus({
    required this.total,
    required this.spent,
    required this.alertThreshold,
    required this.categories,
  });

  final double total;
  final double spent;
  final double alertThreshold;
  final List<CategoryUsage> categories;

  double get remaining => total - spent;
  double get overBy => spent > total ? spent - total : 0;
  double get ratio => total <= 0 ? 0 : spent / total;

  BudgetLevel get level => ratio >= 1
      ? BudgetLevel.over
      : ratio >= alertThreshold
          ? BudgetLevel.nearing
          : BudgetLevel.onTrack;
}

abstract final class BudgetCalculator {
  static BudgetStatus status(Budget budget, MonthSummary summary) {
    final categories = <CategoryUsage>[
      for (final category in ExpenseCategory.values)
        if (budget.categoryLimits.containsKey(category) ||
            (summary.byCategory[category] ?? 0) > 0)
          CategoryUsage(
            category: category,
            spent: summary.byCategory[category] ?? 0,
            limit: budget.categoryLimits[category],
          ),
    ];
    return BudgetStatus(
      total: budget.totalAmount,
      spent: summary.expense,
      alertThreshold: budget.alertThreshold,
      categories: categories,
    );
  }
}
