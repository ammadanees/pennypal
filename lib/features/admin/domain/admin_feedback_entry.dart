import '../../../data/record_store.dart';

class AdminFeedbackEntry {
  const AdminFeedbackEntry({
    required this.id,
    required this.name,
    required this.email,
    required this.rating,
    required this.comments,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final int rating;
  final String comments;
  final DateTime createdAt;

  factory AdminFeedbackEntry.fromRecord(StoredRecord record) {
    final d = record.data;
    return AdminFeedbackEntry(
      id: record.id,
      name: (d['name'] as String?) ?? '',
      email: (d['email'] as String?) ?? '',
      rating: (d['rating'] as num?)?.toInt() ?? 0,
      comments: (d['comments'] as String?) ?? '',
      createdAt: (d['createdAt'] as DateTime?) ?? DateTime.now(),
    );
  }
}
