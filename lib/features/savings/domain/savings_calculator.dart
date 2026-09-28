import 'dart:math' as math;

import '../../../core/utils/app_dates.dart';
import 'savings_goal.dart';

class GoalProgress {
  const GoalProgress({
    required this.remaining,
    required this.ratio,
    required this.milestonesReached,
    this.monthsToGo,
    this.estimatedCompletion,
    this.onTrack,
    this.neededPerMonth,
  });

  final double remaining;

  final double ratio;
  final List<int> milestonesReached;

  final int? monthsToGo;
  final DateTime? estimatedCompletion;

  final bool? onTrack;

  final double? neededPerMonth;

  bool get isComplete => remaining <= 0;
}

abstract final class SavingsCalculator {
  static const List<int> milestones = [25, 50, 75, 100];

  static GoalProgress progress(SavingsGoal goal, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final remaining = math.max(0.0, goal.targetAmount - goal.currentAmount);
    final ratio = goal.targetAmount <= 0
        ? 0.0
        : (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);

    int? monthsToGo;
    DateTime? estimate;
    if (remaining > 0 && goal.monthlyContribution > 0) {
      monthsToGo = (remaining / goal.monthlyContribution).ceil();
      estimate = AppDates.addMonths(today, monthsToGo);
    }

    bool? onTrack;
    if (estimate != null && goal.targetDate != null) {
      onTrack = !estimate.isAfter(goal.targetDate!);
    }

    double? needed;
    if (remaining > 0 && goal.targetDate != null) {
      final months =
          math.max(1, AppDates.monthsBetween(today, goal.targetDate!));
      needed = (remaining / months).ceilToDouble();
    }

    return GoalProgress(
      remaining: remaining,
      ratio: ratio,
      milestonesReached: [
        for (final m in milestones)
          if (ratio * 100 >= m - 1e-9) m,
      ],
      monthsToGo: monthsToGo,
      estimatedCompletion: estimate,
      onTrack: onTrack,
      neededPerMonth: needed,
    );
  }
}
