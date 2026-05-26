import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';

class SubscriptionDto {
  const SubscriptionDto({
    required this.id,
    required this.plan,
    required this.status,
    this.expiresAt,
    this.nextBillingDate,
    this.razorpaySubscriptionId,
    this.cancelledAt,
  });

  final String id;
  final String plan;
  final String status;
  final String? expiresAt;
  final String? nextBillingDate;
  final String? razorpaySubscriptionId;
  final String? cancelledAt;

  factory SubscriptionDto.fromJson(Map<String, dynamic> json) =>
      SubscriptionDto(
        id: json['id'] as String,
        plan: json['plan'] as String? ?? 'free',
        status: json['status'] as String? ?? 'active',
        expiresAt: json['expires_at'] as String?,
        nextBillingDate: json['next_billing_date'] as String?,
        razorpaySubscriptionId: json['razorpay_subscription_id'] as String?,
        cancelledAt: json['cancelled_at'] as String?,
      );

  SubscriptionEntity toEntity() => SubscriptionEntity(
        id: id,
        plan: SubscriptionPlan.fromString(plan),
        status: SubscriptionStatus.fromString(status),
        expiresAt: expiresAt != null ? DateTime.tryParse(expiresAt!) : null,
        nextBillingDate:
            nextBillingDate != null ? DateTime.tryParse(nextBillingDate!) : null,
        razorpaySubscriptionId: razorpaySubscriptionId,
        cancelledAt:
            cancelledAt != null ? DateTime.tryParse(cancelledAt!) : null,
      );
}

class RazorpayOrderDto {
  const RazorpayOrderDto({
    required this.orderId,
    required this.razorpayOrderId,
    required this.keyId,
    required this.amount,
    required this.currency,
    required this.plan,
  });

  final String orderId;
  final String razorpayOrderId;
  final String keyId;
  final double amount;
  final String currency;
  final String plan;

  factory RazorpayOrderDto.fromJson(Map<String, dynamic> json) =>
      RazorpayOrderDto(
        orderId: json['order_id'] as String,
        razorpayOrderId: json['razorpay_order_id'] as String,
        keyId: json['key_id'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'INR',
        plan: json['plan'] as String,
      );

  RazorpayOrderEntity toEntity() => RazorpayOrderEntity(
        orderId: orderId,
        razorpayOrderId: razorpayOrderId,
        keyId: keyId,
        amount: amount,
        currency: currency,
        plan: SubscriptionPlan.fromString(plan),
      );
}
