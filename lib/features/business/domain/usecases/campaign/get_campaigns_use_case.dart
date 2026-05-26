import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/campaign_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/repositories/campaign_repository.dart';

class GetCampaignsUseCase
    implements UseCase<PaginatedResult<CampaignEntity>, GetCampaignsParams> {
  GetCampaignsUseCase(this._repository);
  final CampaignRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<CampaignEntity>>> call(
      GetCampaignsParams params) {
    return _repository.getCampaigns(
      status: params.status,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetCampaignsParams extends Equatable {
  const GetCampaignsParams({this.status, this.page = 1, this.pageSize = 20});
  final CampaignStatus? status;
  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [status, page, pageSize];
}
