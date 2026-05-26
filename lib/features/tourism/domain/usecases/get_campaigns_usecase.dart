import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_campaign_entity.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';

class GetCampaignsUseCase
    implements UseCase<PaginatedResponse<TourismCampaignEntity>, GetCampaignsParams> {
  const GetCampaignsUseCase(this._repository);

  final TourismRepository _repository;

  @override
  Future<Either<Failure, PaginatedResponse<TourismCampaignEntity>>> call(
      GetCampaignsParams params) {
    return _repository.getCampaigns(
      page: params.page,
      perPage: params.perPage,
      destinationId: params.destinationId,
      status: params.status,
    );
  }
}

class GetCampaignsParams extends Equatable {
  const GetCampaignsParams({
    this.page = 1,
    this.perPage = 20,
    this.destinationId,
    this.status,
  });

  final int page;
  final int perPage;
  final String? destinationId;
  final CampaignStatus? status;

  @override
  List<Object?> get props => [page, perPage, destinationId, status];
}
