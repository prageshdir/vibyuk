import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/subscriptions/data/datasources/subscription_remote_data_source.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:vibyuk/features/subscriptions/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl extends BaseRepository
    implements SubscriptionRepository {
  const SubscriptionRepositoryImpl(this._remote);

  final SubscriptionRemoteDataSource _remote;

  @override
  Future<Either<Failure, SubscriptionEntity>> getSubscription() =>
      safeCall(() async {
        final dto = await _remote.getSubscription();
        return dto.toEntity();
      });

  @override
  Future<Either<Failure, RazorpayOrderEntity>> createPaymentOrder(
    SubscriptionPlan plan,
  ) =>
      safeCall(() async {
        final dto = await _remote.createPaymentOrder(plan);
        return dto.toEntity();
      });

  @override
  Future<Either<Failure, SubscriptionEntity>> verifyAndActivate({
    required String paymentId,
    required String razorpayOrderId,
    required String signature,
    required SubscriptionPlan plan,
  }) =>
      safeCall(() async {
        final dto = await _remote.verifyAndActivate(
          paymentId: paymentId,
          razorpayOrderId: razorpayOrderId,
          signature: signature,
          plan: plan,
        );
        return dto.toEntity();
      });

  @override
  Future<Either<Failure, Unit>> cancelSubscription() =>
      safeCall(() async {
        await _remote.cancelSubscription();
        return unit;
      });
}
