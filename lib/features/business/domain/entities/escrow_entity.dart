import 'package:equatable/equatable.dart';

enum EscrowStatus {
  held,
  releasePending,
  released,
  refundPending,
  refunded,
  disputed,
}

extension EscrowStatusX on EscrowStatus {
  String get label => switch (this) {
        EscrowStatus.held => 'Held',
        EscrowStatus.releasePending => 'Release Pending',
        EscrowStatus.released => 'Released',
        EscrowStatus.refundPending => 'Refund Pending',
        EscrowStatus.refunded => 'Refunded',
        EscrowStatus.disputed => 'Disputed',
      };

  bool get isActive => this == EscrowStatus.held || this == EscrowStatus.releasePending;
  bool get isSettled => this == EscrowStatus.released || this == EscrowStatus.refunded;
}

class EscrowEntity extends Equatable {
  const EscrowEntity({
    required this.id,
    required this.bookingId,
    required this.paymentId,
    required this.amount,
    required this.platformFee,
    required this.creatorAmount,
    this.currency = 'INR',
    required this.status,
    required this.heldAt,
    this.releasedAt,
    this.refundedAt,
    this.releaseCondition,
    this.milestoneId,
  });

  final String id;
  final String bookingId;
  final String paymentId;
  final double amount;
  final double platformFee;
  final double creatorAmount;
  final String currency;
  final EscrowStatus status;
  final DateTime heldAt;
  final DateTime? releasedAt;
  final DateTime? refundedAt;
  final String? releaseCondition;
  final String? milestoneId;

  String get amountDisplay => '₹${amount.toStringAsFixed(2)}';
  String get creatorAmountDisplay => '₹${creatorAmount.toStringAsFixed(2)}';
  double get platformFeePercent => amount > 0 ? (platformFee / amount) * 100 : 0;

  @override
  List<Object?> get props => [
        id, bookingId, paymentId, amount, platformFee, creatorAmount,
        currency, status, heldAt, releasedAt, refundedAt,
        releaseCondition, milestoneId,
      ];
}
