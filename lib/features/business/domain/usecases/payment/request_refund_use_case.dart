import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/escrow_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/payment_repository.dart';

class RequestRefundUseCase implements UseCase<EscrowEntity, RequestRefundParams> {
  const RequestRefundUseCase(this._repository);
  final PaymentRepository _repository;

  @override
  Future<Either<Failure, EscrowEntity>> call(RequestRefundParams params) =>
      _repository.requestRefund(
        escrowId: params.escrowId,
        reason: params.reason,
      );
}

class RequestRefundParams extends Equatable {
  const RequestRefundParams({required this.escrowId, required this.reason});
  final String escrowId;
  final String reason;

  @override
  List<Object?> get props => [escrowId, reason];
}
