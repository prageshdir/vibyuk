import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/payment_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/payment_repository.dart';

class GetPaymentDetailUseCase implements UseCase<PaymentEntity, String> {
  const GetPaymentDetailUseCase(this._repository);
  final PaymentRepository _repository;

  @override
  Future<Either<Failure, PaymentEntity>> call(String paymentId) =>
      _repository.getPaymentDetail(paymentId);
}
