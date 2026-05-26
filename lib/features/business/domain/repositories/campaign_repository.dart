import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/campaign_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';

abstract interface class CampaignRepository {
  Future<Either<Failure, PaginatedResult<CampaignEntity>>> getCampaigns({
    CampaignStatus? status,
    required int page,
    int pageSize = 20,
  });

  Future<Either<Failure, CampaignEntity>> getCampaignDetail(String campaignId);

  Future<Either<Failure, CampaignEntity>> createCampaign({
    required String title,
    String? description,
    required double budget,
    required DateTime startDate,
    DateTime? endDate,
    required List<String> categories,
    int targetCreatorCount = 1,
  });

  Future<Either<Failure, CampaignEntity>> updateCampaign({
    required String campaignId,
    String? title,
    String? description,
    double? budget,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categories,
    int? targetCreatorCount,
  });

  Future<Either<Failure, Unit>> deleteCampaign(String campaignId);

  Future<Either<Failure, CampaignEntity>> publishCampaign(String campaignId);
}
