/// Copy for the Home, Activity, Budget and Savings tabs.
abstract final class FinanceStrings {
  // Home
  static const String greetingMorning = 'Good morning';
  static const String greetingAfternoon = 'Good afternoon';
  static const String greetingEvening = 'Good evening';
  static const String availableBalance = 'Available balance';
  static const String income = 'Income';
  static const String expenses = 'Expenses';
  static const String thisMonth = 'This month';
  static const String quickAddIncome = 'Add income';
  static const String quickAddExpense = 'Add expense';
  static const String quickBudget = 'Budget';
  static const String quickSavings = 'Savings';
  static const String sectionBudget = 'This month\'s budget';
  static const String sectionSavings = 'Savings goal';
  static const String sectionRecent = 'Recent transactions';
  static const String seeAll = 'See all';
  static const String details = 'Details';
  static const String overall = 'Overall';
  static const String whereItWent = 'Where it went';
  static const String categoriesCount = 'categories';
  static const String leftToSpend = 'Left to spend';
  static const String overBudgetLabel = 'Over budget by';
  static const String balanceNote = 'this month';
  static const String noActiveGoals = 'No active goals right now.';

  static String pendingChanges(int count) => count == 1
      ? '1 change is saved on this device and will sync when you are back online.'
      : '$count changes are saved on this device and will sync when you are back online.';

  // Activity
  static const String activityTitle = 'Activity';
  static const String add = 'Add';
  static const String searchLabel = 'Search transactions';
  static const String filterAll = 'All';
  static const String filterIncome = 'Income';
  static const String filterExpense = 'Expense';
  static const String filterAnyDate = 'Any date';
  static const String clearFilters = 'Clear filters';
  static const String noMatchTitle = 'No matching transactions';
  static const String noMatchMessage =
      'Try a different search or clear the filters.';
  static const String chooseType = 'What would you like to add?';

  // Transaction form and details
  static const String newExpense = 'New expense';
  static const String newIncome = 'New income';
  static const String editExpense = 'Edit expense';
  static const String editIncome = 'Edit income';
  static const String labelAmount = 'Amount';
  static const String labelCategory = 'Category';
  static const String labelSource = 'Source';
  static const String labelDate = 'Date';
  static const String labelDescription = 'Description (optional)';
  static const String labelNote = 'Note';
  static const String save = 'Save';
  static const String labelPaidWith = 'Paid with';
  static const String categoryRequired = 'Choose a category.';
  static const String transactionSaved = 'Transaction saved.';
  static const String deleteTransactionTitle = 'Delete this transaction?';
  static const String deleteMessage = 'This cannot be undone.';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String transactionDeleted = 'Transaction deleted.';
  static const String waitingToSync = 'Waiting to sync';
  static const String labelReceipt = 'Receipt photo (optional)';
  static const String addReceipt = 'Add receipt photo';
  static const String paymentNote =
      'Only a note for your records. PennyPal never moves money.';

  // Budget
  static const String budgetTitle = 'Budget';
  static const String budgetTotal = 'Total budget';
  static const String budgetSpent = 'Spent';
  static const String budgetRemaining = 'Remaining';
  static const String budgetOverBy = 'Over by';
  static const String budgetByCategory = 'By category';
  static const String budgetNoLimit = 'No limit set';
  static const String budgetSaved = 'Budget saved.';
  static const String budgetDeleted = 'Budget deleted.';
  static const String budgetDeleteTitle = 'Delete this budget?';
  static const String budgetDeleteMessage =
      'Your transactions stay. Only the limits are removed.';
  static const String budgetFormNew = 'Create budget';
  static const String budgetFormEdit = 'Edit budget';
  static const String labelBudgetTotal = 'Total monthly budget';
  static const String categoryLimits = 'Category limits (optional)';
  static const String alertAt = 'Alert me at';
  static const String limitsTooHigh =
      'Category limits add up to more than the total budget.';
  static const String previousMonth = 'Previous month';
  static const String nextMonth = 'Next month';
  static const String used = 'used';

  static String noBudgetFor(String month) => 'No budget for $month';
  static String overBudgetMessage(String amount) =>
      'You are $amount over budget this month.';
  static String nearingBudgetMessage(String percent) =>
      'You have used $percent of this month\'s budget.';

  // Savings
  static const String savingsTitle = 'Savings';
  static const String newGoal = 'New goal';
  static const String goalHistory = 'Goal history';
  static const String addMoney = 'Add money';
  static const String editGoal = 'Edit goal';
  static const String goalFormNew = 'New savings goal';
  static const String goalFormEdit = 'Edit savings goal';
  static const String labelGoalName = 'Goal name';
  static const String labelGoalTarget = 'Target amount';
  static const String labelGoalCurrent = 'Current savings';
  static const String labelGoalDate = 'Target date';
  static const String labelGoalMonthly = 'Monthly contribution';
  static const String dateRequired = 'Choose a target date.';
  static const String goalSaved = 'Goal saved.';
  static const String goalDeleted = 'Goal deleted.';
  static const String deleteGoalTitle = 'Delete this goal?';
  static const String deleteGoalMessage = 'Its progress will be removed.';
  static const String contributeTitle = 'Add to this goal';
  static const String contributeSaved = 'Added to your goal.';
  static const String remaining = 'Remaining';
  static const String monthly = 'Monthly';
  static const String notSet = 'Not set';
  static const String onTrack = 'On track for your target date.';
  static const String behind = 'Behind your target date.';
  static const String completedOn = 'Completed';

  static String goalReached(String name) => 'Goal reached: $name. Well done!';
  static String estimate(String monthly, String month) =>
      'At $monthly a month you will reach this around $month.';
  static String neededToFinish(String amount, String date) =>
      'To finish by $date, save about $amount a month.';
  static String milestone(int percent) => '$percent%';

  /// Shown by progress: [0-25), [25-50), [50-75), [75-100), 100.
  static const List<String> goalMessages = [
    'Every rupee counts. You have started, and that is the hardest part.',
    'A quarter of the way there. Keep the habit going.',
    'Halfway and moving. Your future self says thanks.',
    'Nearly there. The finish line is in sight.',
    'You did it. Time to enjoy what you saved for.',
  ];
}
