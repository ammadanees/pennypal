import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/local_notification_service.dart';
import '../../../data/record_store.dart';
import '../../../data/record_store_provider.dart';
import '../../auth/data/auth_providers.dart';
import '../../budgets/data/budget_repository.dart';
import '../../learning/data/learning_progress_repository.dart';
import '../../learning/data/lessons.dart';
import '../../savings/data/savings_repository.dart';
import '../../transactions/data/transaction_repository.dart';
import '../domain/app_notification.dart';
import '../domain/notification_engine.dart';

class NotificationRepository {
  NotificationRepository(this._store, this._uid);

  static const _collection = 'notifications';

  final RecordStore _store;
  final String _uid;

  Stream<List<AppNotification>> watchAll() =>
      _store.watch(_uid, _collection).map((records) {
        final list = records.map(AppNotification.fromRecord).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  Future<void> save(AppNotification n) =>
      _store.upsert(_uid, _collection, n.id, n.toMap());

  Future<void> markRead(String id) =>
      _store.upsert(_uid, _collection, id, {'read': true});

  Future<void> markAllRead(List<AppNotification> all) async {
    for (final n in all.where((n) => !n.read)) {
      await markRead(n.id);
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(
    ref.watch(recordStoreProvider),
    ref.watch(currentUidProvider) ?? '',
  ),
);

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  if (ref.watch(currentUidProvider) == null) {
    return Stream.value(const <AppNotification>[]);
  }
  return ref.watch(notificationRepositoryProvider).watchAll();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsProvider).valueOrNull ?? const [];
  return list.where((n) => !n.read).length;
});

final notificationEngineProvider = Provider<void>((ref) {
  void run() {
    if (ref.read(currentUidProvider) == null) return;
    final existing = ref.read(notificationsProvider).valueOrNull;
    final transactions = ref.read(transactionsProvider).valueOrNull;
    final budgets = ref.read(budgetsProvider).valueOrNull;
    final goals = ref.read(savingsGoalsProvider).valueOrNull;
    final read = ref.read(readLessonsProvider).valueOrNull;
    if (existing == null ||
        transactions == null ||
        budgets == null ||
        goals == null ||
        read == null) {
      return;
    }

    final existingIds = existing.map((n) => n.id).toSet();
    final repo = ref.read(notificationRepositoryProvider);
    final candidates = NotificationEngine.generate(
      transactions: transactions,
      budgets: budgets,
      goals: goals,
      lessons: bundledLessons,
      readLessonIds: read,
      now: DateTime.now(),
    );
    final user = ref.read(authStateProvider).valueOrNull;
    final notificationsAllowed = user?.notificationsEnabled ?? true;

    for (final n in candidates) {
      if (!existingIds.contains(n.id)) {
        repo.save(n);
        if (notificationsAllowed && existingIds.isNotEmpty) {
          LocalNotificationService.showNotification(
            id: n.id.hashCode,
            title: n.title,
            body: n.message,
            payload: n.type.name,
          );
        }
      }
    }
  }

  ref.listen(transactionsProvider, (_, __) => run());
  ref.listen(budgetsProvider, (_, __) => run());
  ref.listen(savingsGoalsProvider, (_, __) => run());
  ref.listen(readLessonsProvider, (_, __) => run());
  ref.listen(notificationsProvider, (_, __) => run());
  run();
});
