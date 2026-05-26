import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:vibyuk/features/subscriptions/domain/repositories/subscription_repository.dart';

class VerifySubscriptionPaymentUseCase
    implements UseCase<SubscriptionEntity, VerifyPaymentParams> {
  const VerifySubscriptionPaymentUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, SubscriptionEntity>> call(
    VerifyPaymentParams params,
  ) =>
      _repository.verifyAndActivate(
        paymentId: params.paymentId,
        razorpayOrderId: params.razorpayOrderId,
        signature: params.signature,
        plan: params.plan,
      );
}

class VerifyPaymentParams extends Equatable {
  const VerifyPaymentParams({
    required this.paymentId,
    required this.razorpayOrderId,
    required this.signature,
    required this.plan,
  });

  final String paymentId;
  final String razorpayOrderId;
  final String signature;
  final SubscriptionPlan plan;

  @override
  List<Object?> get props => [paymentId, razorpayOrderId, signature, plan];
}
