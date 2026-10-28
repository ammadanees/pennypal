import '../core/constants/app_categories.dart';
import '../core/utils/app_dates.dart';
import '../features/auth/data/demo_auth_repository.dart';
import 'memory_record_store.dart';

Future<void> seedDemoData(MemoryRecordStore store, {DateTime? now}) async {
  final today = now ?? DateTime.now();
  final monthStart = AppDates.startOfMonth(today);
  const uid = DemoAuthRepository.studentUid;

  DateTime daysAgo(int days, int hour, int minute) {
    final d = today.subtract(Duration(days: days));
    final clamped = d.isBefore(monthStart) ? monthStart : d;
    return DateTime(clamped.year, clamped.month, clamped.day, hour, minute);
  }

  var n = 0;
  Future<void> expense(
    ExpenseCategory category,
    double amount,
    String description,
    DateTime date,
    PaymentMode mode, {
    String? cardId,
    String? cardName,
  }) =>
      store.upsert(uid, 'transactions', 'demo-tx-${n++}', {
        'type': 'expense',
        'amount': amount,
        'category': category.name,
        'description': description,
        'paymentMode': mode.name,
        'cardId': cardId,
        'cardName': cardName,
        'date': date,
        'createdAt': date,
      });

  await store.upsert(uid, 'cards', 'demo-card-1', {
    'name': 'Meezan Visa',
    'bank': 'Meezan Bank',
    'last4': '4128',
    'cardType': 'Debit',
    'colorIndex': 0,
    'createdAt': monthStart,
  });
  await store.upsert(uid, 'cards', 'demo-card-2', {
    'name': 'SadaPay Virtual',
    'bank': 'SadaPay',
    'last4': '9942',
    'cardType': 'Debit',
    'colorIndex': 1,
    'createdAt': monthStart,
  });

  await store.upsert(uid, 'transactions', 'demo-tx-income', {
    'type': 'income',
    'amount': 50000.0,
    'source': 'Allowance',
    'paymentMode': 'bankTransfer',
    'description': 'Monthly allowance',
    'date': DateTime(monthStart.year, monthStart.month, monthStart.day, 9, 0),
    'createdAt': monthStart,
  });

  await expense(
      ExpenseCategory.food, 450, 'Lunch', daysAgo(0, 13, 20), PaymentMode.cash);
  await expense(ExpenseCategory.food, 3200, 'Groceries', daysAgo(3, 18, 5),
      PaymentMode.card,
      cardId: 'demo-card-1', cardName: 'Meezan Visa (•••• 4128)');
  await expense(ExpenseCategory.food, 4100, 'Family dinner', daysAgo(6, 20, 30),
      PaymentMode.card,
      cardId: 'demo-card-1', cardName: 'Meezan Visa (•••• 4128)');
  await expense(ExpenseCategory.food, 2850, 'Cafeteria week', daysAgo(9, 12, 0),
      PaymentMode.wallet);
  await expense(ExpenseCategory.food, 2000, 'Snacks and drinks',
      daysAgo(12, 16, 45), PaymentMode.cash);
  await expense(ExpenseCategory.transport, 1200, 'Bus pass', daysAgo(2, 8, 10),
      PaymentMode.cash);
  await expense(ExpenseCategory.transport, 2900, 'Ride to campus events',
      daysAgo(8, 17, 0), PaymentMode.wallet);
  await expense(ExpenseCategory.entertainment, 1800, 'Movie night',
      daysAgo(4, 21, 15), PaymentMode.card,
      cardId: 'demo-card-2', cardName: 'SadaPay Virtual (•••• 9942)');
  await expense(ExpenseCategory.entertainment, 6400, 'Concert ticket',
      daysAgo(10, 11, 0), PaymentMode.bankTransfer);
  await expense(ExpenseCategory.education, 3500, 'Course books',
      daysAgo(5, 15, 30), PaymentMode.card,
      cardId: 'demo-card-1', cardName: 'Meezan Visa (•••• 4128)');
  await expense(ExpenseCategory.bills, 2800, 'Internet bill', daysAgo(7, 10, 0),
      PaymentMode.bankTransfer);

  final key = AppDates.monthKey(monthStart);
  await store.upsert(uid, 'budgets', key, {
    'month': monthStart,
    'totalAmount': 40000.0,
    'categoryLimits': {
      ExpenseCategory.food.name: 15000.0,
      ExpenseCategory.transport.name: 6000.0,
      ExpenseCategory.entertainment.name: 8000.0,
      ExpenseCategory.education.name: 5000.0,
      ExpenseCategory.bills.name: 4000.0,
    },
    'alertThreshold': 0.8,
    'createdAt': monthStart,
  });

  await store.upsert(uid, 'savingsGoals', 'demo-goal-laptop', {
    'name': 'New laptop',
    'targetAmount': 100000.0,
    'currentAmount': 60000.0,
    'monthlyContribution': 5000.0,
    'status': 'active',
    'targetDate': AppDates.addMonths(today, 9),
    'createdAt': AppDates.addMonths(today, -4),
  });
  await store.upsert(uid, 'savingsGoals', 'demo-goal-emergency', {
    'name': 'Emergency fund',
    'targetAmount': 30000.0,
    'currentAmount': 18000.0,
    'monthlyContribution': 3000.0,
    'status': 'active',
    'targetDate': AppDates.addMonths(today, 4),
    'createdAt': AppDates.addMonths(today, -2),
  });
  await store.upsertShared('users', uid, {
    'fullName': 'Alex Khan',
    'studentId': 'Student1501103',
    'email': DemoAuthRepository.studentEmail,
    'mobile': '+92 300 1234567',
    'role': 'student',
    'studentStatus': 'Full-time',
    'createdAt': AppDates.addMonths(monthStart, -4),
    'lastLogin': today,
  });

  await store.upsertShared('supportQueries', 'demo-query-1', {
    'userId': uid,
    'subject': 'Budget alert did not show up',
    'message':
        'I went over my Food budget but did not get a notification. Is this expected?',
    'status': 'answered',
    'adminResponse':
        'Thanks for flagging this! Alerts fire once you cross the threshold you set '
            '(80% by default). Since Food had no limit set that week, no alert was sent. '
            'Setting a category limit in the Budget tab will enable alerts for it.',
    'submittedOn': daysAgo(6, 10, 0),
  });
  await store.upsertShared('feedback', 'demo-feedback-1', {
    'userId': uid,
    'name': 'Alex Khan',
    'email': DemoAuthRepository.studentEmail,
    'rating': 5,
    'comments': 'Love how simple it is to log an expense between classes!',
    'createdAt': daysAgo(2, 9, 0),
  });

  await store.upsert(uid, 'savingsGoals', 'demo-goal-headphones', {
    'name': 'Headphones',
    'targetAmount': 8000.0,
    'currentAmount': 8000.0,
    'monthlyContribution': 2000.0,
    'status': 'completed',
    'completedAt': AppDates.addMonths(today, -1),
    'createdAt': AppDates.addMonths(today, -5),
  });
}
