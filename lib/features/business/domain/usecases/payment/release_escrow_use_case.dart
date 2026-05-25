import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/escrow_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/payment_repository.dart';

class ReleaseEscrowUseCase implements UseCase<EscrowEntity, ReleaseEscrowParams> {
  const ReleaseEscrowUseCase(this._repository);
  final PaymentRepository _repository;

  @override
  Future<Either<Failure, EscrowEntity>> call(ReleaseEscrowParams params) =>
      _repository.releaseEscrow(
        escrowId: params.escrowId,
        milestoneId: params.milestoneId,
      );
}

class ReleaseEscrowParams extends Equatable {
  const ReleaseEscrowParams({required this.escrowId, this.milestoneId});
  final String escrowId;
  final String? milestoneId;

  @override
  List<Object?> get props => [escrowId, milestoneId];
}
