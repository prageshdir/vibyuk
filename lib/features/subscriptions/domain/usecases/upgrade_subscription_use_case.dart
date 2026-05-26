import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:vibyuk/features/subscriptions/domain/repositories/subscription_repository.dart';

class UpgradeSubscriptionUseCase
    implements UseCase<RazorpayOrderEntity, UpgradeSubscriptionParams> {
  const UpgradeSubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, RazorpayOrderEntity>> call(
    UpgradeSubscriptionParams params,
  ) =>
      _repository.createPaymentOrder(params.plan);
}

class UpgradeSubscriptionParams extends Equatable {
  const UpgradeSubscriptionParams({required this.plan});

  final SubscriptionPlan plan;

  @override
  List<Object?> get props => [plan];
}
