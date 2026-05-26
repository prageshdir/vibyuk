import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/subscriptions/domain/repositories/subscription_repository.dart';

class CancelSubscriptionUseCase implements NoParamUseCase<Unit> {
  const CancelSubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, Unit>> call() => _repository.cancelSubscription();
}
