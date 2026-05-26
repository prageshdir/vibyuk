import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';
import 'package:vibyuk/features/business/domain/entities/search_filters_entity.dart';

abstract class InfluencerRemoteDataSource {
  Future<Map<String, dynamic>> getInfluencerCampaigns(
      int page, int pageSize, String? status);

  Future<Map<String, dynamic>> getCampaignById(String campaignId);

  Future<Map<String, dynamic>> createCampaign(Map<String, dynamic> body);

  Future<Map<String, dynamic>> publishCampaign(String campaignId);

  Future<List<dynamic>> getCampaignDeliverables(String campaignId);

  Future<Map<String, dynamic>> approveDeliverable(
      String campaignId, String deliverableId);

  Future<Map<String, dynamic>> requestRevision(
      String campaignId, String deliverableId, String note);

  Future<Map<String, dynamic>> submitDeliverable(
      String campaignId, String deliverableId, String contentUrl);

  Future<Map<String, dynamic>> markDeliverablePublished(
      String campaignId, String deliverableId, String postUrl);

  Future<Map<String, dynamic>> getCampaignAnalytics(String campaignId);

  Future<Map<String, dynamic>> searchInfluencers(
      SearchFiltersEntity filters, int page, int pageSize);
}

class InfluencerRemoteDataSourceImpl implements InfluencerRemoteDataSource {
  const InfluencerRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  Map<String, dynamic> _data(Response r) => r.data as Map<String, dynamic>;

  @override
  Future<Map<String, dynamic>> getInfluencerCampaigns(
      int page, int pageSize, String? status) async {
    final r = await _dio.get(
      ApiEndpoints.influencerCampaigns,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (status != null) 'status': status,
      },
    );
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> getCampaignById(String campaignId) async {
    final r = await _dio
        .get(ApiEndpoints.influencerCampaign(campaignId));
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> createCampaign(Map<String, dynamic> body) async {
    final r = await _dio.post(ApiEndpoints.influencerCampaigns, data: body);
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> publishCampaign(String campaignId) async {
    final r = await _dio
        .post(ApiEndpoints.publishInfluencerCampaign(campaignId));
    return _data(r);
  }

  @override
  Future<List<dynamic>> getCampaignDeliverables(String campaignId) async {
    final r = await _dio
        .get(ApiEndpoints.influencerCampaignDeliverables(campaignId));
    return r.data as List<dynamic>;
  }

  @override
  Future<Map<String, dynamic>> approveDeliverable(
      String campaignId, String deliverableId) async {
    final r = await _dio
        .post(ApiEndpoints.approveDeliverable(campaignId, deliverableId));
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> requestRevision(
      String campaignId, String deliverableId, String note) async {
    final r = await _dio.post(
      ApiEndpoints.requestRevision(campaignId, deliverableId),
      data: {'note': note},
    );
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> submitDeliverable(
      String campaignId, String deliverableId, String contentUrl) async {
    final r = await _dio.post(
      ApiEndpoints.influencerDeliverable(campaignId, deliverableId),
      data: {'content_url': contentUrl},
    );
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> markDeliverablePublished(
      String campaignId, String deliverableId, String postUrl) async {
    final r = await _dio.post(
      ApiEndpoints.markDeliverablePublished(campaignId, deliverableId),
      data: {'post_url': postUrl},
    );
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> getCampaignAnalytics(String campaignId) async {
    final r = await _dio
        .get(ApiEndpoints.influencerCampaignAnalytics(campaignId));
    return _data(r);
  }

  @override
  Future<Map<String, dynamic>> searchInfluencers(
      SearchFiltersEntity filters, int page, int pageSize) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (filters.categories.isNotEmpty) 'categories': filters.categories,
      if (filters.platforms.isNotEmpty)
        'platforms': filters.platforms.map((p) => p.apiValue).toList(),
      if (filters.languages.isNotEmpty) 'languages': filters.languages,
      if (filters.minFollowers != null) 'min_followers': filters.minFollowers,
      if (filters.maxFollowers != null) 'max_followers': filters.maxFollowers,
      if (filters.minEngagementRate != null)
        'min_engagement_rate': filters.minEngagementRate,
      if (filters.minRating != null) 'min_rating': filters.minRating,
      if (filters.location != null) 'location': filters.location,
      'sort': filters.sortBy.apiValue,
    };
    final r = await _dio.get(ApiEndpoints.influencerSearch,
        queryParameters: params);
    return _data(r);
  }
}
