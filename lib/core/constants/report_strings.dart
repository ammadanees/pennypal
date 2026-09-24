abstract final class ReportStrings {
  static const String title = 'Reports';
  static const String periodThisMonth = 'This month';
  static const String periodLastMonth = 'Last month';
  static const String periodLast3Months = 'Last 3 months';
  static const String periodThisYear = 'This year';

  static const String statIncome = 'Income';
  static const String statExpenses = 'Expenses';
  static const String statNet = 'Net';
  static const String statSavingsRate = 'Kept from income';
  static const String statDailyAverage = 'Daily spend';
  static const String statTopCategory = 'Top category';
  static const String notAvailable = 'Not available';

  static const String incomeVsExpenseTitle = 'Income vs expenses';
  static const String categoryTitle = 'Where your money went';
  static const String monthlyTitle = 'Monthly spending';
  static const String monthlySubtitle = 'Last 6 months';
  static const String budgetTitle = 'Budget usage';
  static const String savingsTitle = 'Savings progress';

  static const String emptyAllTitle = 'No reports yet';
  static const String emptyAllMessage =
      'Add a few transactions and your reports will appear here.';
  static const String emptyPeriod = 'No transactions in this period.';
  static const String emptySpending = 'No spending in this period.';
  static const String noBudget = 'No budget for this month yet.';
  static const String noGoals = 'No active savings goals yet.';
  static const String spent = 'spent';

  static String netSummary(String amount) => 'Net for the period: $amount';
  static String budgetFor(String month) => 'Budget for $month';
  static String savedAcross(String amount, int count) =>
      '$amount saved across $count ${count == 1 ? 'goal' : 'goals'}';
  static String completedGoals(int count) =>
      '$count ${count == 1 ? 'goal' : 'goals'} completed';
}
