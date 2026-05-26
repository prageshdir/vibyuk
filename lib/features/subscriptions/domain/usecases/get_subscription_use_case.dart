import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:vibyuk/features/subscriptions/domain/repositories/subscription_repository.dart';

class GetSubscriptionUseCase implements NoParamUseCase<SubscriptionEntity> {
  const GetSubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, SubscriptionEntity>> call() =>
      _repository.getSubscription();
}
