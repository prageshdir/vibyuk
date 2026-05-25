import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/ai/data/datasources/ai_local_data_source.dart';
import 'package:vibyuk/features/ai/data/datasources/ai_remote_data_source.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_analytics.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_campaign.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_chat_message.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_insight.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_pricing.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_recommendation.dart';
import 'package:vibyuk/features/ai/domain/repositories/ai_repository.dart';

class AiRepositoryImpl extends BaseRepository implements AiRepository {
  final AiRemoteDataSource _remote;
  final AiLocalDataSource _local;

  AiRepositoryImpl({
    required AiRemoteDataSource remote,
    required AiLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<Either<Failure, List<AiRecommendation>>> getCreatorRecommendations({
    required String eventType,
    required double budget,
    required String location,
    Map<String, dynamic>? filters,
  }) async {
    final cached = await _local.getCachedRecommendations();
    if (cached != null && cached.isNotEmpty) return Right(cached as List<AiRecommendation>);

    return safeCall(
      () async {
        final result = await _remote.getCreatorRecommendations(
          eventType: eventType,
          budget: budget,
          location: location,
          filters: filters,
        );
        await _local.cacheRecommendations(result);
        return result;
      },
      context: 'AiRepository.getCreatorRecommendations',
    );
  }

  @override
  Future<Either<Failure, AiCampaign>> generateCampaignPlan({
    required String title,
    required String objective,
    required String targetAudience,
    required double budget,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return safeCall(
      () => _remote.generateCampaignPlan(
        title: title,
        objective: objective,
        targetAudience: targetAudience,
        budget: budget,
        startDate: startDate,
        endDate: endDate,
      ),
      context: 'AiRepository.generateCampaignPlan',
    );
  }

  @override
  Future<Either<Failure, List<AiCampaign>>> getSavedCampaigns() async {
    final cached = _local.getCachedCampaigns();
    if (cached != null && cached.isNotEmpty) return Right(cached as List<AiCampaign>);

    return safeCall(
      () async {
        final result = await _remote.getSavedCampaigns();
        await _local.cacheCampaigns(result);
        return result;
      },
      context: 'AiRepository.getSavedCampaigns',
    );
  }

  @override
  Future<Either<Failure, AiCampaign>> updateCampaignStep({
    required String campaignId,
    required String stepId,
    required CampaignStepStatus status,
  }) {
    return safeCall(
      () => _remote.updateCampaignStep(
        campaignId: campaignId,
        stepId: stepId,
        status: status,
      ),
      context: 'AiRepository.updateCampaignStep',
    );
  }

  @override
  Future<Either<Failure, AiPricingSuggestion>> getPricingSuggestion({
    required PricingServiceType serviceType,
    required String location,
    required int experienceYears,
    Map<String, dynamic>? additionalFactors,
  }) {
    return safeCall(
      () => _remote.getPricingSuggestion(
        serviceType: serviceType,
        location: location,
        experienceYears: experienceYears,
        additionalFactors: additionalFactors,
      ),
      context: 'AiRepository.getPricingSuggestion',
    );
  }

  @override
  Future<Either<Failure, List<AiPricingSuggestion>>>
      getAllPricingSuggestions() async {
    final cached = _local.getCachedPricingSuggestions();
    if (cached != null && cached.isNotEmpty) return Right(cached as List<AiPricingSuggestion>);

    return safeCall(
      () async {
        final result = await _remote.getAllPricingSuggestions();
        await _local.cachePricingSuggestions(result);
        return result;
      },
      context: 'AiRepository.getAllPricingSuggestions',
    );
  }

  @override
  Future<Either<Failure, AiAnalytics>> getAnalytics({
    required AnalyticsPeriod period,
  }) async {
    final cached = _local.getCachedAnalytics(period.name);
    if (cached != null) return Right(cached);

    return safeCall(
      () async {
        final result = await _remote.getAnalytics(period: period);
        await _local.cacheAnalytics(period.name, result);
        return result;
      },
      context: 'AiRepository.getAnalytics',
    );
  }

  @override
  Future<Either<Failure, List<AiInsight>>> getInsights() async {
    final cached = _local.getCachedInsights();
    if (cached != null && cached.isNotEmpty) {
      return Right(cached.where((i) => !i.isDismissed && !i.isExpired).toList());
    }

    return safeCall(
      () async {
        final result = await _remote.getInsights();
        await _local.cacheInsights(result);
        return result.where((i) => !i.isDismissed && !i.isExpired).toList();
      },
      context: 'AiRepository.getInsights',
    );
  }

  @override
  Future<Either<Failure, bool>> dismissInsight({
    required String insightId,
  }) {
    return safeCall(
      () => _remote.dismissInsight(insightId: insightId),
      context: 'AiRepository.dismissInsight',
    );
  }

  @override
  Future<Either<Failure, AiChatMessage>> sendChatMessage({
    required String conversationId,
    required String content,
    required AiChatContext context,
    Map<String, dynamic>? attachedData,
  }) {
    return safeCall(
      () => _remote.sendChatMessage(
        conversationId: conversationId,
        content: content,
        context: context,
        attachedData: attachedData,
      ),
      context: 'AiRepository.sendChatMessage',
    );
  }

  @override
  Future<Either<Failure, AiConversation>> getConversation({
    required String conversationId,
  }) {
    return safeCall(
      () => _remote.getConversation(conversationId: conversationId),
      context: 'AiRepository.getConversation',
    );
  }

  @override
  Future<Either<Failure, AiConversation>> createConversation({
    required AiChatContext context,
    String? title,
  }) {
    return safeCall(
      () => _remote.createConversation(context: context, title: title),
      context: 'AiRepository.createConversation',
    );
  }

  @override
  Future<Either<Failure, List<AiConversation>>> getConversationHistory() {
    return safeCall(
      () => _remote.getConversationHistory(),
      context: 'AiRepository.getConversationHistory',
    );
  }
}
