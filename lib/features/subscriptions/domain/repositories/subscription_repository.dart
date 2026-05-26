import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';

abstract interface class SubscriptionRepository {
  Future<Either<Failure, SubscriptionEntity>> getSubscription();

  Future<Either<Failure, RazorpayOrderEntity>> createPaymentOrder(
    SubscriptionPlan plan,
  );

  Future<Either<Failure, SubscriptionEntity>> verifyAndActivate({
    required String paymentId,
    required String razorpayOrderId,
    required String signature,
    required SubscriptionPlan plan,
  });

  Future<Either<Failure, Unit>> cancelSubscription();
}
