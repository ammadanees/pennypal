import 'package:flutter/material.dart';

import '../../../core/constants/finance_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/money_display.dart';
import '../../../shared/widgets/transaction_tile.dart';
import '../domain/finance_transaction.dart';

extension TransactionDisplay on FinanceTransaction {
  IconData get icon =>
      isIncome ? Icons.south_west : (category?.icon ?? Icons.category_outlined);

  MoneyKind get kind => isIncome ? MoneyKind.income : MoneyKind.expense;

  String get subtitle {
    final kindLabel = isIncome ? FinanceStrings.income : (category?.label ?? '');
    final when = '${Formatters.dayLabel(date)} ${Formatters.time(date)}';
    final base = kindLabel.isEmpty ? when : '$kindLabel, $when';
    return pending ? '$base, ${FinanceStrings.waitingToSync}' : base;
  }
}

/// A transaction row using the shared tile.
class TransactionListTile extends StatelessWidget {
  const TransactionListTile({super.key, required this.transaction, this.onTap});

  final FinanceTransaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TransactionTile(
      title: transaction.title,
      subtitle: transaction.subtitle,
      amount: transaction.amount,
      kind: transaction.kind,
      icon: transaction.icon,
      onTap: onTap,
    );
  }
}
