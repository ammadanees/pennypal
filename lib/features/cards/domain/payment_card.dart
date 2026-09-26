import '../../../data/record_store.dart';

class PaymentCard {
  const PaymentCard({
    required this.id,
    required this.name,
    this.bank,
    this.last4,
    this.cardType = 'Debit',
    this.colorIndex = 0,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? bank;
  final String? last4;
  final String cardType;
  final int colorIndex;
  final DateTime createdAt;

  String get displayName {
    final buffer = StringBuffer(name);
    if (last4 != null && last4!.trim().isNotEmpty) {
      buffer.write(' (•••• ${last4!.trim()})');
    }
    return buffer.toString();
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'bank': bank,
        'last4': last4,
        'cardType': cardType,
        'colorIndex': colorIndex,
        'createdAt': createdAt,
        'updatedAt': DateTime.now(),
      };

  factory PaymentCard.fromRecord(StoredRecord record) {
    final d = record.data;
    final date = (d['createdAt'] as DateTime?) ?? DateTime.now();
    return PaymentCard(
      id: record.id,
      name: (d['name'] as String?) ?? 'Card',
      bank: d['bank'] as String?,
      last4: d['last4'] as String?,
      cardType: (d['cardType'] as String?) ?? 'Debit',
      colorIndex: (d['colorIndex'] as int?) ?? 0,
      createdAt: date,
    );
  }
}
