import 'package:flutter/material.dart';

enum TransactionType { expense, income }

enum PaymentMode { cash, gpayUpi, creditCard, debitCard, netBanking }

class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final TransactionType type;
  final PaymentMode paymentMode;
  final String? notes;
  final String? accountTail;
  final bool isAutoParsed;
  final String? rawSms;

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.type,
    required this.paymentMode,
    this.notes,
    this.accountTail,
    this.isAutoParsed = false,
    this.rawSms,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'type': type.name,
      'paymentMode': paymentMode.name,
      'notes': notes,
      'accountTail': accountTail,
      'isAutoParsed': isAutoParsed,
      'rawSms': rawSms,
    };
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      categoryId: json['categoryId'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      paymentMode: PaymentMode.values.firstWhere(
        (e) => e.name == json['paymentMode'],
        orElse: () => PaymentMode.cash,
      ),
      notes: json['notes'],
      accountTail: json['accountTail'],
      isAutoParsed: json['isAutoParsed'] ?? false,
      rawSms: json['rawSms'],
    );
  }

  static String paymentModeLabel(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.gpayUpi:
        return 'GPay / UPI';
      case PaymentMode.creditCard:
        return 'Credit Card';
      case PaymentMode.debitCard:
        return 'Debit Card';
      case PaymentMode.netBanking:
        return 'Net Banking';
    }
  }

  static IconData paymentModeIcon(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return Icons.payments_rounded;
      case PaymentMode.gpayUpi:
        return Icons.account_balance_wallet_rounded;
      case PaymentMode.creditCard:
        return Icons.credit_card_rounded;
      case PaymentMode.debitCard:
        return Icons.credit_score_rounded;
      case PaymentMode.netBanking:
        return Icons.account_balance_rounded;
    }
  }
}
