import '../../../core/constants/app_categories.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/record_store.dart';

enum TransactionType { income, expense }

class FinanceTransaction {
  const FinanceTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.createdAt,
    this.category,
    this.source,
    this.description = '',
    this.paymentMode,
    this.cardId,
    this.cardName,
    this.receiptImageUrl,
    this.currency,
    this.pending = false,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final DateTime createdAt;

  final ExpenseCategory? category;
  final PaymentMode? paymentMode;
  final String? cardId;
  final String? cardName;
  final String? receiptImageUrl;
  final String? currency;

  final String? source;

  final String description;

  final bool pending;

  bool get isIncome => type == TransactionType.income;

  String get title {
    if (isIncome) return (source?.isNotEmpty ?? false) ? source! : 'Income';
    if (description.isNotEmpty) return description;
    return category?.label ?? 'Expense';
  }

  FinanceTransaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    DateTime? date,
    DateTime? createdAt,
    ExpenseCategory? category,
    PaymentMode? paymentMode,
    String? cardId,
    String? cardName,
    String? receiptImageUrl,
    String? currency,
    String? source,
    String? description,
    bool? pending,
  }) {
    return FinanceTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      paymentMode: paymentMode ?? this.paymentMode,
      cardId: cardId ?? this.cardId,
      cardName: cardName ?? this.cardName,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      currency: currency ?? this.currency,
      source: source ?? this.source,
      description: description ?? this.description,
      pending: pending ?? this.pending,
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'amount': amount,
        'date': date,
        'createdAt': createdAt,
        'updatedAt': DateTime.now(),
        'category': category?.name,
        'paymentMode': paymentMode?.name,
        'cardId': cardId,
        'cardName': cardName,
        'source': source,
        'description': description,
        'receiptImageUrl': receiptImageUrl,
        'currency': currency ?? Formatters.currentCurrency,
      };

  factory FinanceTransaction.fromRecord(StoredRecord record) {
    final d = record.data;
    final date = (d['date'] as DateTime?) ?? DateTime.now();
    return FinanceTransaction(
      id: record.id,
      type: d['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      amount: (d['amount'] as num?)?.toDouble() ?? 0,
      date: date,
      createdAt: (d['createdAt'] as DateTime?) ?? date,
      category: ExpenseCategory.parse(d['category']),
      paymentMode: PaymentMode.parse(d['paymentMode']),
      cardId: d['cardId'] as String?,
      cardName: d['cardName'] as String?,
      source: d['source'] as String?,
      description: (d['description'] as String?) ?? '',
      receiptImageUrl: d['receiptImageUrl'] as String?,
      currency: d['currency'] as String?,
      pending: record.hasPendingWrites,
    );
  }
}
