import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/entities/search_filters_entity.dart';
import 'package:vibyuk/features/influencer/domain/entities/influencer_campaign_entity.dart';

abstract class InfluencerRepository {
  Future<Either<Failure, PaginatedResult<InfluencerCampaignEntity>>>
      getInfluencerCampaigns({
    required int page,
    required int pageSize,
    InfluencerCampaignStatus? status,
  });

  Future<Either<Failure, InfluencerCampaignEntity>> getCampaignById(
      String campaignId);

  Future<Either<Failure, InfluencerCampaignEntity>> createCampaign(
      InfluencerCampaignEntity campaign);

  Future<Either<Failure, InfluencerCampaignEntity>> publishCampaign(
      String campaignId);

  Future<Either<Failure, List<ContentDeliverableEntity>>> getCampaignDeliverables(
      String campaignId);

  Future<Either<Failure, ContentDeliverableEntity>> approveDeliverable({
    required String deliverableId,
    required String campaignId,
  });

  Future<Either<Failure, ContentDeliverableEntity>> requestRevision({
    required String deliverableId,
    required String campaignId,
    required String note,
  });

  Future<Either<Failure, ContentDeliverableEntity>> submitDeliverable({
    required String deliverableId,
    required String campaignId,
    required String contentUrl,
  });

  Future<Either<Failure, ContentDeliverableEntity>> markDeliverablePublished({
    required String deliverableId,
    required String campaignId,
    required String postUrl,
  });

  Future<Either<Failure, InfluencerCampaignAnalytics>> getCampaignAnalytics(
      String campaignId);

  Future<Either<Failure, PaginatedResult<dynamic>>> searchInfluencers({
    required SearchFiltersEntity filters,
    required int page,
    required int pageSize,
  });
}
