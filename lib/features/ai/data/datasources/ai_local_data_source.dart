import 'dart:convert';
import 'package:vibyuk/core/cache/cache_manager.dart';
import 'package:vibyuk/features/ai/data/models/ai_analytics_model.dart';
import 'package:vibyuk/features/ai/data/models/ai_campaign_model.dart';
import 'package:vibyuk/features/ai/data/models/ai_insight_model.dart';
import 'package:vibyuk/features/ai/data/models/ai_pricing_model.dart';
import 'package:vibyuk/features/ai/data/models/ai_recommendation_model.dart';

abstract interface class AiLocalDataSource {
  Future<List<AiRecommendationModel>?> getCachedRecommendations();
  Future<void> cacheRecommendations(List<AiRecommendationModel> data);

  AiAnalyticsModel? getCachedAnalytics(String periodKey);
  Future<void> cacheAnalytics(String periodKey, AiAnalyticsModel data);

  List<AiInsightModel>? getCachedInsights();
  Future<void> cacheInsights(List<AiInsightModel> data);

  List<AiCampaignModel>? getCachedCampaigns();
  Future<void> cacheCampaigns(List<AiCampaignModel> data);

  List<AiPricingSuggestionModel>? getCachedPricingSuggestions();
  Future<void> cachePricingSuggestions(List<AiPricingSuggestionModel> data);
}

class AiLocalDataSourceImpl implements AiLocalDataSource {
  final CacheManager _cache;

  static const _recommendationsKey = 'ai_recommendations';
  static const _analyticsKeyPrefix = 'ai_analytics_';
  static const _insightsKey = 'ai_insights';
  static const _campaignsKey = 'ai_campaigns';
  static const _pricingKey = 'ai_pricing_suggestions';

  static const _recommendationsTtl = Duration(hours: 6);
  static const _analyticsTtl = Duration(hours: 1);
  static const _insightsTtl = Duration(hours: 2);
  static const _campaignsTtl = Duration(hours: 12);
  static const _pricingTtl = Duration(hours: 24);

  const AiLocalDataSourceImpl(this._cache);

  @override
  Future<List<AiRecommendationModel>?> getCachedRecommendations() async {
    final raw = _cache.get<List<AiRecommendationModel>>(
      _recommendationsKey,
      deserializer: (s) => (jsonDecode(s) as List)
          .map((e) =>
              AiRecommendationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return raw;
  }

  @override
  Future<void> cacheRecommendations(List<AiRecommendationModel> data) async {
    await _cache.set(
      _recommendationsKey,
      data,
      ttl: _recommendationsTtl,
      serializer: (d) => jsonEncode(d.map((e) => e.toJson()).toList()),
    );
  }

  @override
  AiAnalyticsModel? getCachedAnalytics(String periodKey) {
    return _cache.get<AiAnalyticsModel>(
      '$_analyticsKeyPrefix$periodKey',
      deserializer: (s) =>
          AiAnalyticsModel.fromJson(jsonDecode(s) as Map<String, dynamic>),
    );
  }

  @override
  Future<void> cacheAnalytics(String periodKey, AiAnalyticsModel data) async {
    // Analytics model doesn't have full toJson — skip caching analytics body
    // to avoid incomplete serialization until toJson is implemented on all sub-models.
  }

  @override
  List<AiInsightModel>? getCachedInsights() {
    return _cache.get<List<AiInsightModel>>(
      _insightsKey,
      deserializer: (s) => (jsonDecode(s) as List)
          .map((e) => AiInsightModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<void> cacheInsights(List<AiInsightModel> data) async {
    await _cache.set(
      _insightsKey,
      data,
      ttl: _insightsTtl,
      serializer: (d) => jsonEncode(d.map((e) => e.toJson()).toList()),
    );
  }

  @override
  List<AiCampaignModel>? getCachedCampaigns() {
    return _cache.get<List<AiCampaignModel>>(
      _campaignsKey,
      deserializer: (s) => (jsonDecode(s) as List)
          .map((e) => AiCampaignModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<void> cacheCampaigns(List<AiCampaignModel> data) async {
    await _cache.set(
      _campaignsKey,
      data,
      ttl: _campaignsTtl,
      serializer: (d) => jsonEncode(d.map((e) => e.toJson()).toList()),
    );
  }

  @override
  List<AiPricingSuggestionModel>? getCachedPricingSuggestions() {
    return _cache.get<List<AiPricingSuggestionModel>>(
      _pricingKey,
      deserializer: (s) => (jsonDecode(s) as List)
          .map((e) =>
              AiPricingSuggestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<void> cachePricingSuggestions(
    List<AiPricingSuggestionModel> data,
  ) async {
    await _cache.set(
      _pricingKey,
      data,
      ttl: _pricingTtl,
      serializer: (d) => jsonEncode(d.map((e) => e.toJson()).toList()),
    );
  }
}
