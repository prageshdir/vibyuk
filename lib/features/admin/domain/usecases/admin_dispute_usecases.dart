import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_dispute.dart';
import 'package:vibyuk/features/admin/domain/repositories/admin_repository.dart';

class GetDisputesUseCase
    implements UseCase<PaginatedResponse<AdminDispute>, GetDisputesParams> {
  final AdminRepository _repository;

  const GetDisputesUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResponse<AdminDispute>>> call(
    GetDisputesParams params,
  ) {
    return _repository.getDisputes(
      page: params.page,
      statusFilter: params.statusFilter,
      typeFilter: params.typeFilter,
      searchQuery: params.searchQuery,
    );
  }
}

class GetDisputeDetailUseCase implements UseCase<AdminDispute, DisputeIdParams> {
  final AdminRepository _repository;

  const GetDisputeDetailUseCase(this._repository);

  @override
  Future<Either<Failure, AdminDispute>> call(DisputeIdParams params) {
    return _repository.getDisputeDetail(disputeId: params.disputeId);
  }
}

class AssignDisputeUseCase implements UseCase<AdminDispute, AssignDisputeParams> {
  final AdminRepository _repository;

  const AssignDisputeUseCase(this._repository);

  @override
  Future<Either<Failure, AdminDispute>> call(AssignDisputeParams params) {
    return _repository.assignDispute(
      disputeId: params.disputeId,
      moderatorId: params.moderatorId,
    );
  }
}

class ResolveDisputeUseCase implements UseCase<AdminDispute, ResolveDisputeParams> {
  final AdminRepository _repository;

  const ResolveDisputeUseCase(this._repository);

  @override
  Future<Either<Failure, AdminDispute>> call(ResolveDisputeParams params) {
    return _repository.resolveDispute(
      disputeId: params.disputeId,
      resolution: params.resolution,
      note: params.note,
      refundAmount: params.refundAmount,
    );
  }
}

class AddDisputeMessageUseCase
    implements UseCase<AdminDispute, AddDisputeMessageParams> {
  final AdminRepository _repository;

  const AddDisputeMessageUseCase(this._repository);

  @override
  Future<Either<Failure, AdminDispute>> call(AddDisputeMessageParams params) {
    return _repository.addDisputeMessage(
      disputeId: params.disputeId,
      content: params.content,
    );
  }
}

// ── Params ────────────────────────────────────────────────────────────────────

class GetDisputesParams extends Equatable {
  final int page;
  final DisputeStatus? statusFilter;
  final DisputeType? typeFilter;
  final String? searchQuery;

  const GetDisputesParams({
    this.page = 1,
    this.statusFilter,
    this.typeFilter,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [page, statusFilter, typeFilter, searchQuery];
}

class DisputeIdParams extends Equatable {
  final String disputeId;

  const DisputeIdParams({required this.disputeId});

  @override
  List<Object?> get props => [disputeId];
}

class AssignDisputeParams extends Equatable {
  final String disputeId;
  final String moderatorId;

  const AssignDisputeParams({required this.disputeId, required this.moderatorId});

  @override
  List<Object?> get props => [disputeId, moderatorId];
}

class ResolveDisputeParams extends Equatable {
  final String disputeId;
  final DisputeResolution resolution;
  final String note;
  final double? refundAmount;

  const ResolveDisputeParams({
    required this.disputeId,
    required this.resolution,
    required this.note,
    this.refundAmount,
  });

  @override
  List<Object?> get props => [disputeId, resolution, note, refundAmount];
}

class AddDisputeMessageParams extends Equatable {
  final String disputeId;
  final String content;

  const AddDisputeMessageParams({required this.disputeId, required this.content});

  @override
  List<Object?> get props => [disputeId, content];
}
