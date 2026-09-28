import 'package:flutter/material.dart';

enum ExpenseCategory {
  food('Food', Icons.restaurant_outlined),
  transport('Transport', Icons.directions_bus_outlined),
  education('Education', Icons.menu_book_outlined),
  shopping('Shopping', Icons.shopping_bag_outlined),
  entertainment('Entertainment', Icons.movie_outlined),
  bills('Bills', Icons.receipt_long_outlined),
  savings('Savings', Icons.savings_outlined),
  miscellaneous('Miscellaneous', Icons.category_outlined);

  const ExpenseCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  static ExpenseCategory? parse(Object? value) =>
      ExpenseCategory.values.where((e) => e.name == value).firstOrNull;
}

enum PaymentMode {
  cash('Cash', Icons.payments_outlined),
  card('Card', Icons.credit_card_outlined),
  bankTransfer('Bank transfer', Icons.account_balance_outlined),
  wallet('Mobile wallet', Icons.smartphone_outlined);

  const PaymentMode(this.label, this.icon);

  final String label;
  final IconData icon;

  static PaymentMode? parse(Object? value) =>
      PaymentMode.values.where((e) => e.name == value).firstOrNull;
}

const List<String> incomeSourceSuggestions = [
  'Allowance',
  'Scholarship',
  'Salary',
  'Freelance',
  'Gift',
  'Other',
];
