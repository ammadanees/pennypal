import '../../../core/constants/app_categories.dart';
import '../../../core/utils/app_dates.dart';
import '../../../data/record_store.dart';

/// One budget per month. The id is the month key, for example "2026-09".
class Budget {
  const Budget({
    required this.month,
    required this.totalAmount,
    required this.categoryLimits,
    required this.alertThreshold,
    required this.createdAt,
    this.pending = false,
  });

  final DateTime month;
  final double totalAmount;
  final Map<ExpenseCategory, double> categoryLimits;

  /// Fraction of a limit at which the student is warned (0.5 to 1.0).
  final double alertThreshold;
  final DateTime createdAt;
  final bool pending;

  String get id => AppDates.monthKey(month);

  Map<String, dynamic> toMap() => {
        'month': AppDates.startOfMonth(month),
        'totalAmount': totalAmount,
        'categoryLimits': {
          for (final e in categoryLimits.entries) e.key.name: e.value,
        },
        'alertThreshold': alertThreshold,
        'createdAt': createdAt,
        'updatedAt': DateTime.now(),
      };

  factory Budget.fromRecord(StoredRecord record) {
    final d = record.data;
    final limits = <ExpenseCategory, double>{};
    final raw = d['categoryLimits'];
    if (raw is Map) {
      for (final entry in raw.entries) {
        final category = ExpenseCategory.parse(entry.key);
        final value = entry.value;
        if (category != null && value is num) limits[category] = value.toDouble();
      }
    }
    return Budget(
      month: (d['month'] as DateTime?) ?? DateTime.now(),
      totalAmount: (d['totalAmount'] as num?)?.toDouble() ?? 0,
      categoryLimits: limits,
      alertThreshold: (d['alertThreshold'] as num?)?.toDouble() ?? 0.8,
      createdAt: (d['createdAt'] as DateTime?) ?? DateTime.now(),
      pending: record.hasPendingWrites,
    );
  }
}
