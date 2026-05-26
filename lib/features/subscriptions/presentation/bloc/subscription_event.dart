part of 'subscription_bloc.dart';

sealed class SubscriptionEvent {
  const SubscriptionEvent();
}

final class LoadSubscriptionEvent extends SubscriptionEvent {
  const LoadSubscriptionEvent();
}

final class InitiateUpgradeEvent extends SubscriptionEvent {
  const InitiateUpgradeEvent({required this.plan});
  final SubscriptionPlan plan;
}

final class VerifyPaymentEvent extends SubscriptionEvent {
  const VerifyPaymentEvent({
    required this.paymentId,
    required this.razorpayOrderId,
    required this.signature,
    required this.plan,
  });

  final String paymentId;
  final String razorpayOrderId;
  final String signature;
  final SubscriptionPlan plan;
}

final class PaymentCancelledEvent extends SubscriptionEvent {
  const PaymentCancelledEvent({this.previousSubscription});
  final SubscriptionEntity? previousSubscription;
}

final class CancelSubscriptionEvent extends SubscriptionEvent {
  const CancelSubscriptionEvent();
}
