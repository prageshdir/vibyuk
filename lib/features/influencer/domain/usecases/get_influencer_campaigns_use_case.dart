import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/influencer/domain/entities/influencer_campaign_entity.dart';
import 'package:vibyuk/features/influencer/domain/repositories/influencer_repository.dart';

class GetInfluencerCampaignsUseCase
    extends UseCase<PaginatedResult<InfluencerCampaignEntity>,
        GetInfluencerCampaignsParams> {
  final InfluencerRepository _repository;
  const GetInfluencerCampaignsUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<InfluencerCampaignEntity>>> call(
          GetInfluencerCampaignsParams params) =>
      _repository.getInfluencerCampaigns(
        page: params.page,
        pageSize: params.pageSize,
        status: params.status,
      );
}

class GetInfluencerCampaignsParams extends Equatable {
  final int page;
  final int pageSize;
  final InfluencerCampaignStatus? status;

  const GetInfluencerCampaignsParams({
    required this.page,
    this.pageSize = 20,
    this.status,
  });

  @override
  List<Object?> get props => [page, pageSize, status];
}
