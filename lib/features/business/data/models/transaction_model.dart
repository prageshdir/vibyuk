import 'package:vibyuk/features/business/domain/entities/transaction_entity.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
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
  final String type;
  final String status;
  final double amount;
  final String currency;
  final String description;
  final String? bookingId;
  final String? paymentId;
  final String? escrowId;
  final String? gatewayTransactionId;
  final String? gateway;
  final String createdAt;
  final String? settledAt;
  final Map<String, dynamic>? metadata;

  factory TransactionModel.fromJson(Map<String, dynamic> j) => TransactionModel(
        id: j['id'] as String,
        type: j['type'] as String? ?? 'payment',
        status: j['status'] as String? ?? 'pending',
        amount: (j['amount'] as num).toDouble(),
        currency: j['currency'] as String? ?? 'INR',
        description: j['description'] as String? ?? '',
        bookingId: j['booking_id'] as String?,
        paymentId: j['payment_id'] as String?,
        escrowId: j['escrow_id'] as String?,
        gatewayTransactionId: j['gateway_transaction_id'] as String?,
        gateway: j['gateway'] as String?,
        createdAt: j['created_at'] as String,
        settledAt: j['settled_at'] as String?,
        metadata: j['metadata'] as Map<String, dynamic>?,
      );

  TransactionEntity toEntity() => TransactionEntity(
        id: id,
        type: _typeFromString(type),
        status: _statusFromString(status),
        amount: amount,
        currency: currency,
        description: description,
        bookingId: bookingId,
        paymentId: paymentId,
        escrowId: escrowId,
        gatewayTransactionId: gatewayTransactionId,
        gateway: gateway,
        createdAt: DateTime.parse(createdAt),
        settledAt: settledAt != null ? DateTime.parse(settledAt!) : null,
        metadata: metadata,
      );

  static TransactionType _typeFromString(String s) => switch (s) {
        'payment' => TransactionType.payment,
        'refund' => TransactionType.refund,
        'escrow_hold' => TransactionType.escrowHold,
        'escrow_release' => TransactionType.escrowRelease,
        'payout' => TransactionType.payout,
        'platform_fee' => TransactionType.platformFee,
        'adjustment' => TransactionType.adjustment,
        _ => TransactionType.payment,
      };

  static TransactionStatus _statusFromString(String s) => switch (s) {
        'pending' => TransactionStatus.pending,
        'processing' => TransactionStatus.processing,
        'completed' => TransactionStatus.completed,
        'failed' => TransactionStatus.failed,
        'reversed' => TransactionStatus.reversed,
        _ => TransactionStatus.pending,
      };
}
