import '../../../data/record_store.dart';

enum GoalStatus { active, completed }

class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthlyContribution,
    required this.status,
    required this.createdAt,
    this.targetDate,
    this.completedAt,
    this.pending = false,
  });

  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final double monthlyContribution;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime? targetDate;
  final DateTime? completedAt;
  final bool pending;

  bool get isCompleted => status == GoalStatus.completed;

  SavingsGoal withSaved(double newCurrent, {DateTime? now}) {
    final reached = newCurrent >= targetAmount;
    return SavingsGoal(
      id: id,
      name: name,
      targetAmount: targetAmount,
      currentAmount: newCurrent,
      monthlyContribution: monthlyContribution,
      status: reached ? GoalStatus.completed : GoalStatus.active,
      createdAt: createdAt,
      targetDate: targetDate,
      completedAt: reached ? (completedAt ?? now ?? DateTime.now()) : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'monthlyContribution': monthlyContribution,
        'status': status.name,
        'targetDate': targetDate,
        'completedAt': completedAt,
        'createdAt': createdAt,
        'updatedAt': DateTime.now(),
      };

  factory SavingsGoal.fromRecord(StoredRecord record) {
    final d = record.data;
    return SavingsGoal(
      id: record.id,
      name: (d['name'] as String?) ?? 'Goal',
      targetAmount: (d['targetAmount'] as num?)?.toDouble() ?? 0,
      currentAmount: (d['currentAmount'] as num?)?.toDouble() ?? 0,
      monthlyContribution: (d['monthlyContribution'] as num?)?.toDouble() ?? 0,
      status:
          d['status'] == 'completed' ? GoalStatus.completed : GoalStatus.active,
      createdAt: (d['createdAt'] as DateTime?) ?? DateTime.now(),
      targetDate: d['targetDate'] as DateTime?,
      completedAt: d['completedAt'] as DateTime?,
      pending: record.hasPendingWrites,
    );
  }
}
