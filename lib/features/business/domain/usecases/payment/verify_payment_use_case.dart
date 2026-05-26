import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/payment_entity.dart';
import 'package:vibyuk/features/business/domain/entities/payment_order_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/payment_repository.dart';

class VerifyPaymentUseCase
    implements UseCase<PaymentEntity, VerifyPaymentParams> {
  const VerifyPaymentUseCase(this._repository);
  final PaymentRepository _repository;

  @override
  Future<Either<Failure, PaymentEntity>> call(VerifyPaymentParams params) =>
      _repository.verifyPayment(
        paymentId: params.paymentId,
        gatewayOrderId: params.gatewayOrderId,
        gatewayPaymentId: params.gatewayPaymentId,
        signature: params.signature,
        gateway: params.gateway,
      );
}

class VerifyPaymentParams extends Equatable {
  const VerifyPaymentParams({
    required this.paymentId,
    required this.gatewayOrderId,
    required this.gatewayPaymentId,
    required this.signature,
    required this.gateway,
  });
  final String paymentId;
  final String gatewayOrderId;
  final String gatewayPaymentId;
  final String signature;
  final PaymentGateway gateway;

  @override
  List<Object?> get props => [
        paymentId, gatewayOrderId, gatewayPaymentId, signature, gateway,
      ];
}
