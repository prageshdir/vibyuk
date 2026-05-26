import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/payment_analytics_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/payment_repository.dart';

class GetPaymentAnalyticsUseCase
    implements UseCase<PaymentAnalyticsEntity, GetPaymentAnalyticsParams> {
  const GetPaymentAnalyticsUseCase(this._repository);
  final PaymentRepository _repository;

  @override
  Future<Either<Failure, PaymentAnalyticsEntity>> call(
          GetPaymentAnalyticsParams params) =>
      _repository.getPaymentAnalytics(period: params.period);
}

class GetPaymentAnalyticsParams extends Equatable {
  const GetPaymentAnalyticsParams({this.period = '30d'});
  final String period;

  @override
  List<Object?> get props => [period];
}
