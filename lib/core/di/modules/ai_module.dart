import 'package:get_it/get_it.dart';
import 'package:vibyuk/features/ai/data/datasources/ai_local_data_source.dart';
import 'package:vibyuk/features/ai/data/datasources/ai_remote_data_source.dart';
import 'package:vibyuk/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:vibyuk/features/ai/domain/repositories/ai_repository.dart';
import 'package:vibyuk/features/ai/domain/usecases/get_ai_analytics_usecase.dart';
import 'package:vibyuk/features/ai/domain/usecases/get_ai_insights_usecase.dart';
import 'package:vibyuk/features/ai/domain/usecases/get_campaign_plan_usecase.dart';
import 'package:vibyuk/features/ai/domain/usecases/get_creator_recommendations_usecase.dart';
import 'package:vibyuk/features/ai/domain/usecases/get_pricing_suggestions_usecase.dart';
import 'package:vibyuk/features/ai/domain/usecases/send_ai_chat_message_usecase.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_analytics/ai_analytics_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_campaign/ai_campaign_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_chat/ai_chat_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_insights/ai_insights_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_pricing/ai_pricing_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_recommendations/ai_recommendations_bloc.dart';

void registerAiModule(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<AiRemoteDataSource>(
    () => AiRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AiLocalDataSource>(
    () => AiLocalDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<AiRepository>(
    () => AiRepositoryImpl(
      remote: sl<AiRemoteDataSource>(),
      local: sl<AiLocalDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(
    () => GetCreatorRecommendationsUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => GenerateCampaignPlanUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => GetSavedCampaignsUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => UpdateCampaignStepUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => GetPricingSuggestionUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => GetAllPricingSuggestionsUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => GetAiAnalyticsUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => GetAiInsightsUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => DismissInsightUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => SendAiChatMessageUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => CreateConversationUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => GetConversationHistoryUseCase(sl()),
  );

  // BLoCs (factory — new instance per screen)
  sl.registerFactory(
    () => AiRecommendationsBloc(
      getRecommendations: sl(),
    ),
  );
  sl.registerFactory(
    () => AiCampaignBloc(
      generateCampaign: sl(),
      getSavedCampaigns: sl(),
      updateStep: sl(),
    ),
  );
  sl.registerFactory(
    () => AiPricingBloc(
      getPricing: sl(),
      getAllPricing: sl(),
    ),
  );
  sl.registerFactory(
    () => AiAnalyticsBloc(getAnalytics: sl()),
  );
  sl.registerFactory(
    () => AiInsightsBloc(
      getInsights: sl(),
      dismissInsight: sl(),
    ),
  );
  sl.registerFactory(
    () => AiChatBloc(
      sendMessage: sl(),
      createConversation: sl(),
      getHistory: sl(),
    ),
  );
}
