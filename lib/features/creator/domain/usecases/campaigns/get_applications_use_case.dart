import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/creator/domain/entities/campaign_application_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class GetApplicationsUseCase
    extends UseCase<PaginatedResult<CampaignApplicationEntity>, GetApplicationsParams> {
  final CreatorRepository _repository;
  const GetApplicationsUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<CampaignApplicationEntity>>> call(
          GetApplicationsParams params) =>
      _repository.getApplications(
        page: params.page,
        pageSize: params.pageSize,
        statusFilter: params.statusFilter,
      );
}

class GetApplicationsParams extends Equatable {
  final int page;
  final int pageSize;
  final ApplicationStatus? statusFilter;

  const GetApplicationsParams({
    required this.page,
    this.pageSize = 20,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [page, pageSize, statusFilter];
}
