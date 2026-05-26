import 'package:vibyuk/features/business/domain/entities/escrow_entity.dart';

class EscrowModel {
  const EscrowModel({
    required this.id,
    required this.bookingId,
    required this.paymentId,
    required this.amount,
    required this.platformFee,
    required this.creatorAmount,
    required this.currency,
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
  final String status;
  final String heldAt;
  final String? releasedAt;
  final String? refundedAt;
  final String? releaseCondition;
  final String? milestoneId;

  factory EscrowModel.fromJson(Map<String, dynamic> j) => EscrowModel(
        id: j['id'] as String,
        bookingId: j['booking_id'] as String,
        paymentId: j['payment_id'] as String,
        amount: (j['amount'] as num).toDouble(),
        platformFee: (j['platform_fee'] as num? ?? 0).toDouble(),
        creatorAmount: (j['creator_amount'] as num? ?? 0).toDouble(),
        currency: j['currency'] as String? ?? 'INR',
        status: j['status'] as String? ?? 'held',
        heldAt: j['held_at'] as String,
        releasedAt: j['released_at'] as String?,
        refundedAt: j['refunded_at'] as String?,
        releaseCondition: j['release_condition'] as String?,
        milestoneId: j['milestone_id'] as String?,
      );

  EscrowEntity toEntity() => EscrowEntity(
        id: id,
        bookingId: bookingId,
        paymentId: paymentId,
        amount: amount,
        platformFee: platformFee,
        creatorAmount: creatorAmount,
        currency: currency,
        status: _statusFromString(status),
        heldAt: DateTime.parse(heldAt),
        releasedAt: releasedAt != null ? DateTime.parse(releasedAt!) : null,
        refundedAt: refundedAt != null ? DateTime.parse(refundedAt!) : null,
        releaseCondition: releaseCondition,
        milestoneId: milestoneId,
      );

  static EscrowStatus _statusFromString(String s) {
    return switch (s) {
      'held' => EscrowStatus.held,
      'release_pending' => EscrowStatus.releasePending,
      'released' => EscrowStatus.released,
      'refund_pending' => EscrowStatus.refundPending,
      'refunded' => EscrowStatus.refunded,
      'disputed' => EscrowStatus.disputed,
      _ => EscrowStatus.held,
    };
  }
}
