import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_categories.dart';
import '../data/transaction_repository.dart';
import '../domain/finance_transaction.dart';
import '../domain/transaction_filter.dart';

class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  void setQuery(String query) => state = state.withQuery(query);

  void setType(TransactionType? type) {
    // A category only makes sense for expenses.
    state = state
        .withType(type)
        .withCategory(type == TransactionType.income ? null : state.category);
  }

  void setCategory(ExpenseCategory? category) {
    state = state.withCategory(category);
    if (category != null && state.type == TransactionType.income) {
      state = state.withType(null);
    }
  }

  void setRange(DateRange? range) => state = state.withRange(range);

  void setPaymentMode(PaymentMode? mode, {String? cardId}) =>
      state = state.withPaymentMode(mode, cardId: cardId);

  void setCardId(String? cardId) => state = state.withCardId(cardId);

  void clear() => state = const TransactionFilter();
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilter>(
  TransactionFilterNotifier.new,
);

final filteredTransactionsProvider =
    Provider<AsyncValue<List<FinanceTransaction>>>((ref) {
  final filter = ref.watch(transactionFilterProvider);
  return ref.watch(transactionsProvider).whenData(filter.apply);
});
