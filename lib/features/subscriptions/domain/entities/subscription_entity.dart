import 'package:equatable/equatable.dart';

enum UserSubscriptionType { creator, business }

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

  int get monthlyPricePaise => switch (this) {
        SubscriptionPlan.free => 0,
        SubscriptionPlan.pro => 79900,
        SubscriptionPlan.elite => 199900,
      };

  String get formattedPrice => switch (this) {
        SubscriptionPlan.free => 'Free',
        SubscriptionPlan.pro => '₹799/mo',
        SubscriptionPlan.elite => '₹1,999/mo',
      };
}

enum BusinessPlan {
  free,
  starter,
  professional,
  enterprise;

  String get displayName => switch (this) {
        BusinessPlan.free => 'Free',
        BusinessPlan.starter => 'Starter',
        BusinessPlan.professional => 'Professional',
        BusinessPlan.enterprise => 'Enterprise',
      };

  int get monthlyPriceINR => switch (this) {
        BusinessPlan.free => 0,
        BusinessPlan.starter => 199900,
        BusinessPlan.professional => 499900,
        BusinessPlan.enterprise => 1299900,
      };

  String get formattedPrice => switch (this) {
        BusinessPlan.free => 'Free',
        BusinessPlan.starter => '₹1,999/mo',
        BusinessPlan.professional => '₹4,999/mo',
        BusinessPlan.enterprise => '₹12,999/mo',
      };

  double get commissionRate => switch (this) {
        BusinessPlan.free => 0.18,
        BusinessPlan.starter => 0.15,
        BusinessPlan.professional => 0.12,
        BusinessPlan.enterprise => 0.10,
      };

  int get maxCampaignsPerMonth => switch (this) {
        BusinessPlan.free => 2,
        BusinessPlan.starter => 10,
        BusinessPlan.professional => 999,
        BusinessPlan.enterprise => 999,
      };

  int get maxTeamMembers => switch (this) {
        BusinessPlan.free => 0,
        BusinessPlan.starter => 1,
        BusinessPlan.professional => 5,
        BusinessPlan.enterprise => 999,
      };

  bool get hasAIRecommendations => switch (this) {
        BusinessPlan.free => false,
        BusinessPlan.starter => false,
        BusinessPlan.professional => true,
        BusinessPlan.enterprise => true,
      };

  bool get hasWhiteLabel => switch (this) {
        BusinessPlan.free => false,
        BusinessPlan.starter => false,
        BusinessPlan.professional => false,
        BusinessPlan.enterprise => true,
      };

  bool get hasAPIAccess => switch (this) {
        BusinessPlan.free => false,
        BusinessPlan.starter => false,
        BusinessPlan.professional => false,
        BusinessPlan.enterprise => true,
      };

  bool get hasSLA => switch (this) {
        BusinessPlan.free => false,
        BusinessPlan.starter => false,
        BusinessPlan.professional => false,
        BusinessPlan.enterprise => true,
      };

  bool get isPaid => this != BusinessPlan.free;

  String get serverValue => switch (this) {
        BusinessPlan.free => 'free',
        BusinessPlan.starter => 'starter',
        BusinessPlan.professional => 'professional',
        BusinessPlan.enterprise => 'enterprise',
      };

  static BusinessPlan fromString(String? value) => switch (value) {
        'starter' => BusinessPlan.starter,
        'professional' => BusinessPlan.professional,
        'enterprise' => BusinessPlan.enterprise,
        _ => BusinessPlan.free,
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

  factory SubscriptionEntity.free() => const SubscriptionEntity(
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

class BusinessSubscriptionEntity extends Equatable {
  const BusinessSubscriptionEntity({
    required this.id,
    required this.plan,
    required this.status,
    this.expiresAt,
    this.nextBillingDate,
    this.razorpaySubscriptionId,
    this.cancelledAt,
  });

  final String id;
  final BusinessPlan plan;
  final SubscriptionStatus status;
  final DateTime? expiresAt;
  final DateTime? nextBillingDate;
  final String? razorpaySubscriptionId;
  final DateTime? cancelledAt;

  bool get isActive => status.isActive;

  factory BusinessSubscriptionEntity.free() => const BusinessSubscriptionEntity(
        id: 'free',
        plan: BusinessPlan.free,
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
