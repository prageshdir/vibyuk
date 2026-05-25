import 'package:vibyuk/features/business/domain/entities/payment_entity.dart';

class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.amount,
    this.currency = 'GBP',
    required this.status,
    required this.type,
    required this.description,
    this.bookingId,
    this.campaignId,
    required this.createdAt,
  });

  final String id;
  final double amount;
  final String currency;
  final String status;
  final String type;
  final String description;
  final String? bookingId;
  final String? campaignId;
  final DateTime createdAt;

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'GBP',
        status: json['status'] as String? ?? 'pending',
        type: json['type'] as String? ?? 'booking',
        description: json['description'] as String? ?? '',
        bookingId: json['booking_id'] as String?,
        campaignId: json['campaign_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  PaymentEntity toEntity() => PaymentEntity(
        id: id,
        amount: amount,
        currency: currency,
        status: PaymentStatus.values.firstWhere(
          (s) => s.name == status,
          orElse: () => PaymentStatus.pending,
        ),
        type: PaymentType.values.firstWhere(
          (t) => t.name == type,
          orElse: () => PaymentType.booking,
        ),
        description: description,
        bookingId: bookingId,
        campaignId: campaignId,
        createdAt: createdAt,
      );
}
