import 'package:flutter/material.dart';

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

  static const List<LinearGradient> cardGradients = [
    LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFD946EF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF0D9488), Color(0xFF10B981), Color(0xFF06B6D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFEA580C), Color(0xFFF97316), Color(0xFFFBBF24)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF38BDF8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF881337), Color(0xFFBE123C), Color(0xFFF43F5E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  LinearGradient get gradient =>
      cardGradients[(colorIndex >= 0 && colorIndex < cardGradients.length)
          ? colorIndex
          : 0];

  final String id;
  final String name;
  final String? bank;
  final String? last4;
  final String cardType;
  final int colorIndex;
  final DateTime createdAt;

  PaymentCard copyWith({
    String? id,
    String? name,
    String? bank,
    String? last4,
    String? cardType,
    int? colorIndex,
    DateTime? createdAt,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      name: name ?? this.name,
      bank: bank ?? this.bank,
      last4: last4 ?? this.last4,
      cardType: cardType ?? this.cardType,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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
