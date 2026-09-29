import '../../../data/record_store.dart';

enum DebtType {
  lent, // I gave money -> Owed to me
  borrowed; // I took money -> I owe them

  String get label => switch (this) {
        DebtType.lent => 'Owed to Me',
        DebtType.borrowed => 'I Owe',
      };
}

class DebtRecord {
  const DebtRecord({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    this.note = '',
    this.dueDate,
    this.isSettled = false,
    this.settledAt,
    required this.createdAt,
  });

  final String id;
  final String personName;
  final double amount;
  final DebtType type;
  final String note;
  final DateTime? dueDate;
  final bool isSettled;
  final DateTime? settledAt;
  final DateTime createdAt;

  bool get isOwedToMe => type == DebtType.lent;

  DebtRecord copyWith({
    String? personName,
    double? amount,
    DebtType? type,
    String? note,
    DateTime? dueDate,
    bool? isSettled,
    DateTime? settledAt,
  }) {
    return DebtRecord(
      id: id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      isSettled: isSettled ?? this.isSettled,
      settledAt: settledAt ?? this.settledAt,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'personName': personName,
        'amount': amount,
        'type': type.name,
        'note': note,
        'dueDate': dueDate,
        'isSettled': isSettled,
        'settledAt': settledAt,
        'createdAt': createdAt,
        'updatedAt': DateTime.now(),
      };

  factory DebtRecord.fromRecord(StoredRecord record) {
    final d = record.data;
    final date = (d['createdAt'] as DateTime?) ?? DateTime.now();
    return DebtRecord(
      id: record.id,
      personName: (d['personName'] as String?) ?? 'Friend',
      amount: (d['amount'] as num?)?.toDouble() ?? 0,
      type: d['type'] == 'borrowed' ? DebtType.borrowed : DebtType.lent,
      note: (d['note'] as String?) ?? '',
      dueDate: d['dueDate'] as DateTime?,
      isSettled: (d['isSettled'] as bool?) ?? false,
      settledAt: d['settledAt'] as DateTime?,
      createdAt: date,
    );
  }
}
