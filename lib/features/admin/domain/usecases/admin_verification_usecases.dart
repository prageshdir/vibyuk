import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_verification.dart';
import 'package:vibyuk/features/admin/domain/repositories/admin_repository.dart';

class GetVerificationsUseCase
    implements UseCase<PaginatedResponse<AdminVerification>, GetVerificationsParams> {
  final AdminRepository _repository;

  const GetVerificationsUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResponse<AdminVerification>>> call(
    GetVerificationsParams params,
  ) {
    return _repository.getVerifications(
      page: params.page,
      statusFilter: params.statusFilter,
      typeFilter: params.typeFilter,
    );
  }
}

class GetVerificationDetailUseCase
    implements UseCase<AdminVerification, VerificationIdParams> {
  final AdminRepository _repository;

  const GetVerificationDetailUseCase(this._repository);

  @override
  Future<Either<Failure, AdminVerification>> call(VerificationIdParams params) {
    return _repository.getVerificationDetail(
      verificationId: params.verificationId,
    );
  }
}

class ReviewVerificationUseCase
    implements UseCase<AdminVerification, ReviewVerificationParams> {
  final AdminRepository _repository;

  const ReviewVerificationUseCase(this._repository);

  @override
  Future<Either<Failure, AdminVerification>> call(
    ReviewVerificationParams params,
  ) {
    return _repository.reviewVerification(
      verificationId: params.verificationId,
      decision: params.decision,
      note: params.note,
      rejectionReason: params.rejectionReason,
    );
  }
}

// ── Params ────────────────────────────────────────────────────────────────────

class GetVerificationsParams extends Equatable {
  final int page;
  final VerificationStatus? statusFilter;
  final VerificationType? typeFilter;

  const GetVerificationsParams({
    this.page = 1,
    this.statusFilter,
    this.typeFilter,
  });

  @override
  List<Object?> get props => [page, statusFilter, typeFilter];
}

class VerificationIdParams extends Equatable {
  final String verificationId;

  const VerificationIdParams({required this.verificationId});

  @override
  List<Object?> get props => [verificationId];
}

class ReviewVerificationParams extends Equatable {
  final String verificationId;
  final VerificationStatus decision;
  final String? note;
  final String? rejectionReason;

  const ReviewVerificationParams({
    required this.verificationId,
    required this.decision,
    this.note,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [verificationId, decision, note, rejectionReason];
}
