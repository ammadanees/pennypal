import '../../../core/constants/app_categories.dart';
import '../../../core/utils/app_dates.dart';
import 'finance_transaction.dart';

class DateRange {
  const DateRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  /// Inclusive of both days.
  bool contains(DateTime value) {
    final from = AppDates.dateOnly(start);
    final to = AppDates.dateOnly(end).add(const Duration(days: 1));
    return !value.isBefore(from) && value.isBefore(to);
  }
}

/// Search and filter state for the transaction history.
class TransactionFilter {
  const TransactionFilter({
    this.query = '',
    this.type,
    this.category,
    this.range,
  });

  final String query;
  final TransactionType? type;
  final ExpenseCategory? category;
  final DateRange? range;

  bool get isActive =>
      query.trim().isNotEmpty || type != null || category != null || range != null;

  TransactionFilter withQuery(String value) => TransactionFilter(
      query: value, type: type, category: category, range: range);

  TransactionFilter withType(TransactionType? value) => TransactionFilter(
      query: query, type: value, category: category, range: range);

  TransactionFilter withCategory(ExpenseCategory? value) => TransactionFilter(
      query: query, type: type, category: value, range: range);

  TransactionFilter withRange(DateRange? value) => TransactionFilter(
      query: query, type: type, category: category, range: value);

  List<FinanceTransaction> apply(List<FinanceTransaction> all) {
    final q = query.trim().toLowerCase();
    return all.where((t) {
      if (type != null && t.type != type) return false;
      if (category != null && t.category != category) return false;
      if (range != null && !range!.contains(t.date)) return false;
      if (q.isNotEmpty) {
        final haystack = '${t.title} ${t.description} ${t.source ?? ''} '
                '${t.category?.label ?? ''} ${t.amount}'
            .toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      return true;
    }).toList();
  }
}
