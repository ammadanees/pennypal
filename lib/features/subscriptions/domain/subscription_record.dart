import '../../../core/constants/app_categories.dart';
import '../../../data/record_store.dart';

class SubscriptionRecord {
  const SubscriptionRecord({
    required this.id,
    required this.name,
    required this.amount,
    this.billingCycle = 'monthly',
    required this.dueDay,
    required this.category,
    this.iconName = 'receipt',
    this.lastPaidDate,
    this.reminderEnabled = true,
    required this.createdAt,
  });

  final String id;
  final String name;
  final double amount;
  final String billingCycle;
  final int dueDay;
  final ExpenseCategory category;
  final String iconName;
  final DateTime? lastPaidDate;
  final bool reminderEnabled;
  final DateTime createdAt;

  bool isPaidForMonth(DateTime now) {
    if (lastPaidDate == null) return false;
    return lastPaidDate!.year == now.year && lastPaidDate!.month == now.month;
  }

  int daysUntilDue(DateTime now) {
    final targetMonth = (now.day > dueDay) ? now.month + 1 : now.month;
    final targetYear = (targetMonth > 12) ? now.year + 1 : now.year;
    final resolvedMonth = (targetMonth > 12) ? 1 : targetMonth;
    final daysInMonth = DateTime(targetYear, resolvedMonth + 1, 0).day;
    final clampedDay = dueDay > daysInMonth ? daysInMonth : dueDay;
    final dueDate = DateTime(targetYear, resolvedMonth, clampedDay);
    return dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  SubscriptionRecord copyWith({
    String? name,
    double? amount,
    String? billingCycle,
    int? dueDay,
    ExpenseCategory? category,
    String? iconName,
    DateTime? lastPaidDate,
    bool? reminderEnabled,
  }) {
    return SubscriptionRecord(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      billingCycle: billingCycle ?? this.billingCycle,
      dueDay: dueDay ?? this.dueDay,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      lastPaidDate: lastPaidDate ?? this.lastPaidDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'amount': amount,
        'billingCycle': billingCycle,
        'dueDay': dueDay,
        'category': category.name,
        'iconName': iconName,
        'lastPaidDate': lastPaidDate,
        'reminderEnabled': reminderEnabled,
        'createdAt': createdAt,
        'updatedAt': DateTime.now(),
      };

  factory SubscriptionRecord.fromRecord(StoredRecord record) {
    final d = record.data;
    final date = (d['createdAt'] as DateTime?) ?? DateTime.now();
    return SubscriptionRecord(
      id: record.id,
      name: (d['name'] as String?) ?? 'Subscription',
      amount: (d['amount'] as num?)?.toDouble() ?? 0,
      billingCycle: (d['billingCycle'] as String?) ?? 'monthly',
      dueDay: (d['dueDay'] as int?) ?? 1,
      category: ExpenseCategory.parse(d['category']) ?? ExpenseCategory.bills,
      iconName: (d['iconName'] as String?) ?? 'receipt',
      lastPaidDate: d['lastPaidDate'] as DateTime?,
      reminderEnabled: (d['reminderEnabled'] as bool?) ?? true,
      createdAt: date,
    );
  }
}
