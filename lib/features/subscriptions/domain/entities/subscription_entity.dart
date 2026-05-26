import 'package:equatable/equatable.dart';

enum SubscriptionPlan {
  free,
  pro,
  elite;

  String get displayName => switch (this) {
        SubscriptionPlan.free => 'Free',
        SubscriptionPlan.pro => 'Pro',
        SubscriptionPlan.elite => 'Elite',
      };

  String get serverValue => name;

  static SubscriptionPlan fromString(String? value) => switch (value) {
        'pro' => SubscriptionPlan.pro,
        'elite' => SubscriptionPlan.elite,
        _ => SubscriptionPlan.free,
      };

  bool get isPaid => this != SubscriptionPlan.free;
  bool get isElite => this == SubscriptionPlan.elite;

  // Monthly price in smallest currency unit (pence)
  int get monthlyPricePence => switch (this) {
        SubscriptionPlan.free => 0,
        SubscriptionPlan.pro => 999,
        SubscriptionPlan.elite => 2499,
      };

  String get formattedPrice => switch (this) {
        SubscriptionPlan.free => 'Free',
        SubscriptionPlan.pro => '£9.99/mo',
        SubscriptionPlan.elite => '£24.99/mo',
      };
}

enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  pending;

  static SubscriptionStatus fromString(String? value) => switch (value) {
        'active' => SubscriptionStatus.active,
        'expired' => SubscriptionStatus.expired,
        'cancelled' => SubscriptionStatus.cancelled,
        'pending' => SubscriptionStatus.pending,
        _ => SubscriptionStatus.expired,
      };

  bool get isActive => this == SubscriptionStatus.active;
}

class SubscriptionEntity extends Equatable {
  const SubscriptionEntity({
    required this.id,
    required this.plan,
    required this.status,
    this.expiresAt,
    this.nextBillingDate,
    this.razorpaySubscriptionId,
    this.cancelledAt,
  });

  final String id;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime? expiresAt;
  final DateTime? nextBillingDate;
  final String? razorpaySubscriptionId;
  final DateTime? cancelledAt;

  bool get isActive => status.isActive;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  factory SubscriptionEntity.free() => SubscriptionEntity(
        id: 'free',
        plan: SubscriptionPlan.free,
        status: SubscriptionStatus.active,
      );

  @override
  List<Object?> get props => [
        id, plan, status, expiresAt, nextBillingDate,
        razorpaySubscriptionId, cancelledAt,
      ];
}

class RazorpayOrderEntity extends Equatable {
  const RazorpayOrderEntity({
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
  final SubscriptionPlan plan;

  @override
  List<Object?> get props => [orderId, razorpayOrderId, keyId, amount, currency, plan];
}
