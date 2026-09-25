import '../../../data/record_store.dart';

enum NotificationType { budgetWarning, budgetOver, savingsMilestone, learning }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.read = false,
    this.pending = false,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool read;
  final bool pending;

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'title': title,
        'message': message,
        'createdAt': createdAt,
        'read': read,
      };

  factory AppNotification.fromRecord(StoredRecord record) {
    final d = record.data;
    return AppNotification(
      id: record.id,
      type: NotificationType.values
              .where((t) => t.name == d['type'])
              .firstOrNull ??
          NotificationType.budgetWarning,
      title: (d['title'] as String?) ?? '',
      message: (d['message'] as String?) ?? '',
      createdAt: (d['createdAt'] as DateTime?) ?? DateTime.now(),
      read: d['read'] == true,
      pending: record.hasPendingWrites,
    );
  }
}
