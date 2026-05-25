import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_analytics.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_campaign.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_chat_message.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_insight.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_pricing.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_recommendation.dart';

abstract interface class AiRepository {
  Future<Either<Failure, List<AiRecommendation>>> getCreatorRecommendations({
    required String eventType,
    required double budget,
    required String location,
    Map<String, dynamic>? filters,
  });

  Future<Either<Failure, AiCampaign>> generateCampaignPlan({
    required String title,
    required String objective,
    required String targetAudience,
    required double budget,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, List<AiCampaign>>> getSavedCampaigns();

  Future<Either<Failure, AiCampaign>> updateCampaignStep({
    required String campaignId,
    required String stepId,
    required CampaignStepStatus status,
  });

  Future<Either<Failure, AiPricingSuggestion>> getPricingSuggestion({
    required PricingServiceType serviceType,
    required String location,
    required int experienceYears,
    Map<String, dynamic>? additionalFactors,
  });

  Future<Either<Failure, List<AiPricingSuggestion>>> getAllPricingSuggestions();

  Future<Either<Failure, AiAnalytics>> getAnalytics({
    required AnalyticsPeriod period,
  });

  Future<Either<Failure, List<AiInsight>>> getInsights();

  Future<Either<Failure, bool>> dismissInsight({required String insightId});

  Future<Either<Failure, AiChatMessage>> sendChatMessage({
    required String conversationId,
    required String content,
    required AiChatContext context,
    Map<String, dynamic>? attachedData,
  });

  Future<Either<Failure, AiConversation>> getConversation({
    required String conversationId,
  });

  Future<Either<Failure, AiConversation>> createConversation({
    required AiChatContext context,
    String? title,
  });

  Future<Either<Failure, List<AiConversation>>> getConversationHistory();
}
