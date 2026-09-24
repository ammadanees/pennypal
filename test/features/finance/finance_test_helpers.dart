import 'package:pennypal/core/constants/app_categories.dart';
import 'package:pennypal/features/transactions/domain/finance_transaction.dart';

FinanceTransaction expense(
  double amount,
  ExpenseCategory category,
  DateTime date, {
  String description = '',
}) =>
    FinanceTransaction(
      id: 'e-${date.microsecondsSinceEpoch}-$amount',
      type: TransactionType.expense,
      amount: amount,
      date: date,
      createdAt: date,
      category: category,
      description: description,
    );

FinanceTransaction income(double amount, DateTime date, {String source = 'Allowance'}) =>
    FinanceTransaction(
      id: 'i-${date.microsecondsSinceEpoch}-$amount',
      type: TransactionType.income,
      amount: amount,
      date: date,
      createdAt: date,
      source: source,
    );
