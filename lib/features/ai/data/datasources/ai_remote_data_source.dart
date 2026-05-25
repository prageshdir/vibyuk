import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';
import 'package:vibyuk/features/ai/data/models/ai_analytics_model.dart';
import 'package:vibyuk/features/ai/data/models/ai_campaign_model.dart';
import 'package:vibyuk/features/ai/data/models/ai_chat_message_model.dart';
import 'package:vibyuk/features/ai/data/models/ai_insight_model.dart';
import 'package:vibyuk/features/ai/data/models/ai_pricing_model.dart';
import 'package:vibyuk/features/ai/data/models/ai_recommendation_model.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_analytics.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_campaign.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_chat_message.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_pricing.dart';

abstract interface class AiRemoteDataSource {
  Future<List<AiRecommendationModel>> getCreatorRecommendations({
    required String eventType,
    required double budget,
    required String location,
    Map<String, dynamic>? filters,
  });

  Future<AiCampaignModel> generateCampaignPlan({
    required String title,
    required String objective,
    required String targetAudience,
    required double budget,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<AiCampaignModel>> getSavedCampaigns();

  Future<AiCampaignModel> updateCampaignStep({
    required String campaignId,
    required String stepId,
    required CampaignStepStatus status,
  });

  Future<AiPricingSuggestionModel> getPricingSuggestion({
    required PricingServiceType serviceType,
    required String location,
    required int experienceYears,
    Map<String, dynamic>? additionalFactors,
  });

  Future<List<AiPricingSuggestionModel>> getAllPricingSuggestions();

  Future<AiAnalyticsModel> getAnalytics({required AnalyticsPeriod period});

  Future<List<AiInsightModel>> getInsights();

  Future<bool> dismissInsight({required String insightId});

  Future<AiChatMessageModel> sendChatMessage({
    required String conversationId,
    required String content,
    required AiChatContext context,
    Map<String, dynamic>? attachedData,
  });

  Future<AiConversationModel> getConversation({required String conversationId});

  Future<AiConversationModel> createConversation({
    required AiChatContext context,
    String? title,
  });

  Future<List<AiConversationModel>> getConversationHistory();
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final Dio _dio;

  const AiRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AiRecommendationModel>> getCreatorRecommendations({
    required String eventType,
    required double budget,
    required String location,
    Map<String, dynamic>? filters,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.aiRecommendations,
      data: {
        'event_type': eventType,
        'budget': budget,
        'location': location,
        if (filters != null) ...filters,
      },
    );
    final data = response.data['data'] as List;
    return data
        .map((e) => AiRecommendationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AiCampaignModel> generateCampaignPlan({
    required String title,
    required String objective,
    required String targetAudience,
    required double budget,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.aiCampaignGenerate,
      data: {
        'title': title,
        'objective': objective,
        'target_audience': targetAudience,
        'budget': budget,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
    );
    return AiCampaignModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<AiCampaignModel>> getSavedCampaigns() async {
    final response = await _dio.get(ApiEndpoints.aiCampaigns);
    final data = response.data['data'] as List;
    return data
        .map((e) => AiCampaignModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AiCampaignModel> updateCampaignStep({
    required String campaignId,
    required String stepId,
    required CampaignStepStatus status,
  }) async {
    final response = await _dio.patch(
      ApiEndpoints.aiCampaignStep(campaignId, stepId),
      data: {'status': status.name},
    );
    return AiCampaignModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<AiPricingSuggestionModel> getPricingSuggestion({
    required PricingServiceType serviceType,
    required String location,
    required int experienceYears,
    Map<String, dynamic>? additionalFactors,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.aiPricing,
      data: {
        'service_type': serviceType.name,
        'location': location,
        'experience_years': experienceYears,
        if (additionalFactors != null) ...additionalFactors,
      },
    );
    return AiPricingSuggestionModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<AiPricingSuggestionModel>> getAllPricingSuggestions() async {
    final response = await _dio.get(ApiEndpoints.aiPricingSuggestions);
    final data = response.data['data'] as List;
    return data
        .map((e) => AiPricingSuggestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AiAnalyticsModel> getAnalytics({required AnalyticsPeriod period}) async {
    final response = await _dio.get(
      ApiEndpoints.aiAnalytics,
      queryParameters: {'period': period.name},
    );
    return AiAnalyticsModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<AiInsightModel>> getInsights() async {
    final response = await _dio.get(ApiEndpoints.aiInsights);
    final data = response.data['data'] as List;
    return data
        .map((e) => AiInsightModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool> dismissInsight({required String insightId}) async {
    await _dio.patch(ApiEndpoints.aiInsightDismiss(insightId));
    return true;
  }

  @override
  Future<AiChatMessageModel> sendChatMessage({
    required String conversationId,
    required String content,
    required AiChatContext context,
    Map<String, dynamic>? attachedData,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.aiChatMessages(conversationId),
      data: {
        'content': content,
        'context': context.name,
        if (attachedData != null) 'attached_data': attachedData,
      },
    );
    return AiChatMessageModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<AiConversationModel> getConversation({
    required String conversationId,
  }) async {
    final response = await _dio.get(ApiEndpoints.aiConversation(conversationId));
    return AiConversationModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<AiConversationModel> createConversation({
    required AiChatContext context,
    String? title,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.aiConversations,
      data: {
        'context': context.name,
        if (title != null) 'title': title,
      },
    );
    return AiConversationModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<AiConversationModel>> getConversationHistory() async {
    final response = await _dio.get(ApiEndpoints.aiConversations);
    final data = response.data['data'] as List;
    return data
        .map((e) => AiConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
