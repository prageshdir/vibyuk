part of 'subscription_bloc.dart';

sealed class SubscriptionState {
  const SubscriptionState();
}

final class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

final class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

final class SubscriptionLoaded extends SubscriptionState {
  const SubscriptionLoaded(this.subscription);

  final SubscriptionEntity subscription;

  SubscriptionPlan get plan => subscription.plan;
  SubscriptionPlanFeatures get features =>
      SubscriptionPlanFeatures.forPlan(plan);

  bool hasAccess(SubscriptionFeature feature) => features.hasAccess(feature);
}

/// Razorpay order created — screen must launch the payment sheet.
final class SubscriptionPaymentReady extends SubscriptionState {
  const SubscriptionPaymentReady({required this.order});
  final RazorpayOrderEntity order;
}

final class SubscriptionUpgrading extends SubscriptionState {
  const SubscriptionUpgrading({this.currentSubscription});
  final SubscriptionEntity? currentSubscription;
}

final class SubscriptionVerifying extends SubscriptionState {
  const SubscriptionVerifying();
}

final class SubscriptionActivated extends SubscriptionState {
  const SubscriptionActivated(this.subscription);
  final SubscriptionEntity subscription;
}

final class SubscriptionError extends SubscriptionState {
  const SubscriptionError(this.message);
  final String message;
}
