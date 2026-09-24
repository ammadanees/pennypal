import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/features/savings/domain/savings_calculator.dart';
import 'package:pennypal/features/savings/domain/savings_goal.dart';

SavingsGoal goal({
  double target = 100000,
  double current = 60000,
  double monthly = 5000,
  DateTime? date,
}) =>
    SavingsGoal(
      id: 'g',
      name: 'Laptop',
      targetAmount: target,
      currentAmount: current,
      monthlyContribution: monthly,
      status: GoalStatus.active,
      createdAt: DateTime(2026, 1, 1),
      targetDate: date,
    );

void main() {
  final now = DateTime(2026, 9, 24);

  test('remaining, ratio and months to go', () {
    final p = SavingsCalculator.progress(goal(), now: now);
    expect(p.remaining, 40000);
    expect(p.ratio, 0.6);
    expect(p.monthsToGo, 8);
    expect(p.estimatedCompletion, DateTime(2027, 5, 24));
  });

  test('on track versus behind the target date', () {
    final ok = SavingsCalculator.progress(goal(date: DateTime(2027, 6, 1)), now: now);
    expect(ok.onTrack, isTrue);
    final behind = SavingsCalculator.progress(goal(date: DateTime(2027, 1, 1)), now: now);
    expect(behind.onTrack, isFalse);
    expect(behind.neededPerMonth, 10000); // 40,000 over 4 months
  });

  test('no monthly contribution means no estimate', () {
    final p = SavingsCalculator.progress(goal(monthly: 0), now: now);
    expect(p.monthsToGo, isNull);
    expect(p.estimatedCompletion, isNull);
    expect(p.onTrack, isNull);
  });

  test('milestones are reached at 25, 50, 75 and 100 percent', () {
    List<int> reached(double current) =>
        SavingsCalculator.progress(goal(current: current), now: now).milestonesReached;
    expect(reached(10000), isEmpty);
    expect(reached(25000), [25]);
    expect(reached(60000), [25, 50]);
    expect(reached(100000), [25, 50, 75, 100]);
  });

  test('reaching the target completes the goal', () {
    final done = goal(current: 95000).withSaved(100000, now: now);
    expect(done.isCompleted, isTrue);
    expect(done.completedAt, now);
    final notYet = goal().withSaved(70000, now: now);
    expect(notYet.isCompleted, isFalse);
    expect(notYet.completedAt, isNull);
  });

  test('over-saving is capped in progress but not in the amount', () {
    final p = SavingsCalculator.progress(goal(current: 120000), now: now);
    expect(p.ratio, 1);
    expect(p.remaining, 0);
    expect(p.isComplete, isTrue);
  });
}
