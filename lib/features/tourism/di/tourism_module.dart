import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:vibyuk/core/cache/cache_manager.dart';
import 'package:vibyuk/core/cache/drift/app_database.dart';
import 'package:vibyuk/features/tourism/data/datasources/tourism_local_datasource.dart';
import 'package:vibyuk/features/tourism/data/datasources/tourism_remote_datasource.dart';
import 'package:vibyuk/features/tourism/data/repositories/tourism_repository_impl.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';
import 'package:vibyuk/features/tourism/domain/usecases/apply_for_fam_trip_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/create_campaign_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/create_collaboration_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_campaign_detail_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_campaigns_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_collaborations_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_destination_detail_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_destinations_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_fam_trip_detail_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_fam_trips_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_featured_destinations_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/get_tourism_analytics_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/update_campaign_usecase.dart';
import 'package:vibyuk/features/tourism/domain/usecases/update_collaboration_usecase.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/campaign_list/campaign_list_bloc.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/creator_collaboration/creator_collaboration_bloc.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/destination_detail/destination_detail_bloc.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/destination_list/destination_list_bloc.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/fam_trip/fam_trip_bloc.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/tourism_analytics/tourism_analytics_cubit.dart';

void registerTourismModule(GetIt sl) {
  // ── Data sources ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<TourismLocalDataSource>(
    () => TourismLocalDataSourceImpl(
      dao: sl<AppDatabase>().tourismDao,
      cache: sl<CacheManager>(),
    ),
  );

  sl.registerLazySingleton<TourismRemoteDataSource>(
    () => TourismRemoteDataSourceImpl(sl<Dio>()),
  );

  // ── Repository ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<TourismRepository>(
    () => TourismRepositoryImpl(
      local: sl<TourismLocalDataSource>(),
      remote: sl<TourismRemoteDataSource>(),
    ),
  );

  // ── Use cases ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => GetDestinationsUseCase(sl<TourismRepository>()),
  );
  sl.registerLazySingleton(
    () => GetDestinationDetailUseCase(sl<TourismRepository>()),
  );
  sl.registerLazySingleton(
    () => GetFeaturedDestinationsUseCase(sl<TourismRepository>()),
  );
  sl.registerLazySingleton(
    () => GetCampaignsUseCase(sl<TourismRepository>()),
  );
  sl.registerLazySingleton(
    () => GetCampaignDetailUseCase(sl<TourismRepository>()),
  );
  sl.registerLazySingleton(
    () => CreateCampaignUseCase(sl<TourismRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateCampaignUseCase(sl<TourismRepository>()),
  );
  sl.registerLazySingleton(
    () => GetFamTripsUseCase(sl<TourismRepository>()),
  );
  sl.registerLazySingleton(
    () => GetFamTripDetailUseCase(sl<TourismRepository>()),
  );
  sl.registerLazySingleton(
    () => ApplyForFamTripUseCase(sl<TourismRepository>()),
  );
  sl.registerLazySingleton(
    () => GetCollaborationsUseCase(sl<TourismRepository>()),
  );
  sl.registerLazySingleton(
    () => CreateCollaborationUseCase(sl<TourismRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateCollaborationUseCase(sl<TourismRepository>()),
  );
  sl.registerLazySingleton(
    () => GetTourismAnalyticsUseCase(sl<TourismRepository>()),
  );

  // ── BLoCs ────────────────────────────────────────────────────────────────────
  sl.registerFactory(
    () => DestinationListBloc(
      getDestinations: sl<GetDestinationsUseCase>(),
      getFeaturedDestinations: sl<GetFeaturedDestinationsUseCase>(),
    ),
  );
  sl.registerFactory(
    () => DestinationDetailBloc(
      getDestinationDetail: sl<GetDestinationDetailUseCase>(),
      getFeaturedDestinations: sl<GetFeaturedDestinationsUseCase>(),
    ),
  );
  sl.registerFactory(
    () => CampaignListBloc(
      getCampaigns: sl<GetCampaignsUseCase>(),
    ),
  );
  sl.registerFactory(
    () => FamTripBloc(
      getFamTrips: sl<GetFamTripsUseCase>(),
      getFamTripDetail: sl<GetFamTripDetailUseCase>(),
      applyForFamTrip: sl<ApplyForFamTripUseCase>(),
    ),
  );
  sl.registerFactory(
    () => CreatorCollaborationBloc(
      getCollaborations: sl<GetCollaborationsUseCase>(),
      createCollaboration: sl<CreateCollaborationUseCase>(),
      updateCollaboration: sl<UpdateCollaborationUseCase>(),
    ),
  );
  sl.registerFactory(
    () => TourismAnalyticsCubit(
      getAnalytics: sl<GetTourismAnalyticsUseCase>(),
    ),
  );
}
