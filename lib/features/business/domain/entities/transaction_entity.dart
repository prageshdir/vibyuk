import 'package:equatable/equatable.dart';

enum TransactionType {
  payment,
  refund,
  escrowHold,
  escrowRelease,
  payout,
  platformFee,
  adjustment,
}

enum TransactionStatus { pending, processing, completed, failed, reversed }

extension TransactionTypeX on TransactionType {
  String get label => switch (this) {
        TransactionType.payment => 'Payment',
        TransactionType.refund => 'Refund',
        TransactionType.escrowHold => 'Escrow Hold',
        TransactionType.escrowRelease => 'Escrow Release',
        TransactionType.payout => 'Payout',
        TransactionType.platformFee => 'Platform Fee',
        TransactionType.adjustment => 'Adjustment',
      };

  bool get isCredit => this == TransactionType.escrowRelease ||
      this == TransactionType.payout ||
      this == TransactionType.refund;
}

class TransactionEntity extends Equatable {
  const TransactionEntity({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    this.currency = 'INR',
    required this.description,
    this.bookingId,
    this.paymentId,
    this.escrowId,
    this.gatewayTransactionId,
    this.gateway,
    required this.createdAt,
    this.settledAt,
    this.metadata,
  });

  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final String currency;
  final String description;
  final String? bookingId;
  final String? paymentId;
  final String? escrowId;
  final String? gatewayTransactionId;
  final String? gateway;
  final DateTime createdAt;
  final DateTime? settledAt;
  final Map<String, dynamic>? metadata;

  String get amountDisplay => '₹${amount.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        id, type, status, amount, currency, description,
        bookingId, paymentId, escrowId, gatewayTransactionId,
        gateway, createdAt, settledAt,
      ];
}
