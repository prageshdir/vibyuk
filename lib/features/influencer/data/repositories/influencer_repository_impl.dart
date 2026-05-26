import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/creator_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/entities/search_filters_entity.dart';
import 'package:vibyuk/features/business/data/models/creator_model.dart';
import 'package:vibyuk/features/influencer/data/datasources/influencer_remote_data_source.dart';
import 'package:vibyuk/features/influencer/data/models/influencer_campaign_model.dart';
import 'package:vibyuk/features/influencer/domain/entities/influencer_campaign_entity.dart';
import 'package:vibyuk/features/influencer/domain/repositories/influencer_repository.dart';

class InfluencerRepositoryImpl extends BaseRepository
    implements InfluencerRepository {
  const InfluencerRepositoryImpl({
    required InfluencerRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final InfluencerRemoteDataSource _remote;

  PaginatedResult<T> _parsePaginated<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final raw = data['items'] as List? ?? data['data'] as List? ?? [];
    final items = raw.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    return PaginatedResult<T>(
      items: items,
      currentPage: data['current_page'] as int? ?? 1,
      totalPages: data['total_pages'] as int? ?? 1,
      totalItems: data['total_items'] as int? ?? items.length,
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<InfluencerCampaignEntity>>>
      getInfluencerCampaigns({
    required int page,
    required int pageSize,
    InfluencerCampaignStatus? status,
  }) =>
          safeCall(() async {
            final data = await _remote.getInfluencerCampaigns(
                page, pageSize, status?.name);
            return _parsePaginated(
                data, (e) => InfluencerCampaignModel.fromJson(e).toEntity());
          });

  @override
  Future<Either<Failure, InfluencerCampaignEntity>> getCampaignById(
          String campaignId) =>
      safeCall(() async {
        final data = await _remote.getCampaignById(campaignId);
        return InfluencerCampaignModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, InfluencerCampaignEntity>> createCampaign(
          InfluencerCampaignEntity campaign) =>
      safeCall(() async {
        final body = {
          'title': campaign.title,
          'description': campaign.description,
          'budget_paise': campaign.budgetPaise,
          'start_date': campaign.startDate.toIso8601String(),
          'end_date': campaign.endDate?.toIso8601String(),
          'categories': campaign.categories,
          'platforms': campaign.platforms.map((p) => p.apiValue).toList(),
          'languages': campaign.languages,
          'min_followers': campaign.minFollowers,
          'max_followers': campaign.maxFollowers,
          'min_engagement_rate': campaign.minEngagementRate,
          'max_influencers': campaign.maxInfluencers,
        };
        final data = await _remote.createCampaign(body);
        return InfluencerCampaignModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, InfluencerCampaignEntity>> publishCampaign(
          String campaignId) =>
      safeCall(() async {
        final data = await _remote.publishCampaign(campaignId);
        return InfluencerCampaignModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, List<ContentDeliverableEntity>>>
      getCampaignDeliverables(String campaignId) =>
          safeCall(() async {
            final list = await _remote.getCampaignDeliverables(campaignId);
            return list
                .map((e) => ContentDeliverableModel.fromJson(
                    e as Map<String, dynamic>).toEntity())
                .toList();
          });

  @override
  Future<Either<Failure, ContentDeliverableEntity>> approveDeliverable({
    required String deliverableId,
    required String campaignId,
  }) =>
      safeCall(() async {
        final data =
            await _remote.approveDeliverable(campaignId, deliverableId);
        return ContentDeliverableModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, ContentDeliverableEntity>> requestRevision({
    required String deliverableId,
    required String campaignId,
    required String note,
  }) =>
      safeCall(() async {
        final data =
            await _remote.requestRevision(campaignId, deliverableId, note);
        return ContentDeliverableModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, ContentDeliverableEntity>> submitDeliverable({
    required String deliverableId,
    required String campaignId,
    required String contentUrl,
  }) =>
      safeCall(() async {
        final data = await _remote.submitDeliverable(
            campaignId, deliverableId, contentUrl);
        return ContentDeliverableModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, ContentDeliverableEntity>> markDeliverablePublished({
    required String deliverableId,
    required String campaignId,
    required String postUrl,
  }) =>
      safeCall(() async {
        final data = await _remote.markDeliverablePublished(
            campaignId, deliverableId, postUrl);
        return ContentDeliverableModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, InfluencerCampaignAnalytics>> getCampaignAnalytics(
          String campaignId) =>
      safeCall(() async {
        final data = await _remote.getCampaignAnalytics(campaignId);
        return InfluencerCampaignAnalyticsModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, PaginatedResult<dynamic>>> searchInfluencers({
    required SearchFiltersEntity filters,
    required int page,
    required int pageSize,
  }) =>
      safeCall(() async {
        final data =
            await _remote.searchInfluencers(filters, page, pageSize);
        return _parsePaginated(data, (e) => CreatorModel.fromJson(e).toEntity());
      });
}
