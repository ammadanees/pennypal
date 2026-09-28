import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../budgets/data/budget_repository.dart';
import '../../savings/data/savings_repository.dart';
import '../../transactions/data/transaction_repository.dart';

final pendingWriteCountProvider = Provider<int>((ref) {
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? const [];
  final budgets = ref.watch(budgetsProvider).valueOrNull ?? const [];
  final goals = ref.watch(savingsGoalsProvider).valueOrNull ?? const [];
  return transactions.where((t) => t.pending).length +
      budgets.where((b) => b.pending).length +
      goals.where((g) => g.pending).length;
});
