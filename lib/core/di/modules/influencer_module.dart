import 'package:get_it/get_it.dart';
import 'package:vibyuk/features/influencer/data/datasources/influencer_remote_data_source.dart';
import 'package:vibyuk/features/influencer/data/repositories/influencer_repository_impl.dart';
import 'package:vibyuk/features/influencer/domain/repositories/influencer_repository.dart';
import 'package:vibyuk/features/influencer/domain/usecases/get_influencer_campaigns_use_case.dart';
import 'package:vibyuk/features/influencer/domain/usecases/review_deliverable_use_case.dart';
import 'package:vibyuk/features/influencer/presentation/blocs/influencer_campaign/influencer_campaign_bloc.dart';

void registerInfluencerModule(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<InfluencerRemoteDataSource>(
    () => InfluencerRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<InfluencerRepository>(
    () => InfluencerRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetInfluencerCampaignsUseCase(sl()));
  sl.registerLazySingleton(() => ApproveDeliverableUseCase(sl()));
  sl.registerLazySingleton(() => RequestRevisionUseCase(sl()));
  sl.registerLazySingleton(() => MarkPublishedUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => InfluencerCampaignBloc(
        getCampaigns: sl(),
        approveDeliverable: sl(),
        requestRevision: sl(),
        markPublished: sl(),
      ));
}
