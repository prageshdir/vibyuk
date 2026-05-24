import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/payment_order_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/payment_repository.dart';

class InitiatePaymentUseCase
    implements UseCase<PaymentOrderEntity, InitiatePaymentParams> {
  const InitiatePaymentUseCase(this._repository);
  final PaymentRepository _repository;

  @override
  Future<Either<Failure, PaymentOrderEntity>> call(
          InitiatePaymentParams params) =>
      _repository.initiatePayment(
        bookingId: params.bookingId,
        amount: params.amount,
        gateway: params.gateway,
      );
}

class InitiatePaymentParams extends Equatable {
  const InitiatePaymentParams({
    required this.bookingId,
    required this.amount,
    required this.gateway,
  });
  final String bookingId;
  final double amount;
  final PaymentGateway gateway;

  @override
  List<Object?> get props => [bookingId, amount, gateway];
}
