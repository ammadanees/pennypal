import '../../../core/utils/app_dates.dart';
import '../../../core/utils/formatters.dart';
import '../../budgets/data/budget_repository.dart';
import '../../budgets/domain/budget.dart';
import '../../budgets/domain/budget_calculator.dart';
import '../../dashboard/domain/finance_calculator.dart';
import '../../learning/domain/lesson.dart';
import '../../savings/domain/savings_calculator.dart';
import '../../savings/domain/savings_goal.dart';
import '../../transactions/domain/finance_transaction.dart';
import 'app_notification.dart';

abstract final class NotificationEngine {
  static List<AppNotification> generate({
    required List<FinanceTransaction> transactions,
    required List<Budget> budgets,
    required List<SavingsGoal> goals,
    required List<Lesson> lessons,
    required Set<String> readLessonIds,
    required DateTime now,
  }) {
    final result = <AppNotification>[];
    final month = AppDates.startOfMonth(now);
    final key = AppDates.monthKey(month);
    final monthName = AppDates.monthLabel(month);

    AppNotification note(
      String id,
      NotificationType type,
      String title,
      String message,
    ) =>
        AppNotification(
          id: id,
          type: type,
          title: title,
          message: message,
          createdAt: now,
        );

    final budget = budgets.forMonth(month);
    if (budget != null) {
      final status = BudgetCalculator.status(
        budget,
        FinanceCalculator.monthSummary(transactions, month),
      );
      if (status.level == BudgetLevel.over) {
        result.add(note(
          'budget-$key-overall-over',
          NotificationType.budgetOver,
          'Over budget',
          'You are ${Formatters.money(status.overBy)} over your $monthName budget.',
        ));
      } else if (status.level == BudgetLevel.nearing) {
        result.add(note(
          'budget-$key-overall-warn',
          NotificationType.budgetWarning,
          'Budget alert',
          'You have used ${Formatters.percent(status.ratio)} of your $monthName budget.',
        ));
      }
      for (final usage in status.categories) {
        if (usage.limit == null || usage.limit! <= 0) continue;
        final label = usage.category.label;
        if (usage.ratio > 1) {
          result.add(note(
            'budget-$key-${usage.category.name}-over',
            NotificationType.budgetOver,
            '$label is over its limit',
            'You have spent ${Formatters.money(usage.spent)} on $label against a limit of ${Formatters.money(usage.limit!)}.',
          ));
        } else if (usage.ratio >= budget.alertThreshold) {
          result.add(note(
            'budget-$key-${usage.category.name}-warn',
            NotificationType.budgetWarning,
            '$label is nearly at its limit',
            '${Formatters.percent(usage.ratio)} of your $label limit is used.',
          ));
        }
      }
    }

    for (final goal in goals) {
      if (goal.isCompleted &&
          goal.completedAt != null &&
          now.difference(goal.completedAt!).inDays > 30) {
        continue;
      }
      final reached =
          SavingsCalculator.progress(goal, now: now).milestonesReached;
      if (reached.isEmpty) continue;
      final m = reached.last;
      result.add(note(
        'goal-${goal.id}-$m',
        NotificationType.savingsMilestone,
        m == 100 ? 'Goal reached' : 'Savings milestone',
        m == 100
            ? 'You reached your goal: ${goal.name}. Well done!'
            : '${goal.name} is $m% funded. Keep going.',
      ));
    }

    final unread =
        lessons.where((l) => !readLessonIds.contains(l.id)).firstOrNull;
    if (unread != null) {
      final week = (now.difference(DateTime(now.year)).inDays ~/ 7) + 1;
      result.add(note(
        'learning-${now.year}-w$week',
        NotificationType.learning,
        'Learn something small today',
        'Try "${unread.title}". It takes about ${unread.readMinutes} minutes.',
      ));
    }
    return result;
  }
}
