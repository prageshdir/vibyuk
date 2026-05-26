import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:vibyuk/core/cache/cache_manager.dart';
import 'package:vibyuk/core/cache/drift/app_database.dart';
import 'package:vibyuk/features/wedding/data/datasources/wedding_local_datasource.dart';
import 'package:vibyuk/features/wedding/data/datasources/wedding_remote_datasource.dart';
import 'package:vibyuk/features/wedding/data/repositories/wedding_repository_impl.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';
import 'package:vibyuk/features/wedding/domain/usecases/add_budget_item_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/add_timeline_task_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/build_custom_package_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/create_vendor_booking_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/create_wedding_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_budget_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_timeline_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_vendor_bookings_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_vendor_detail_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_venues_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_venue_detail_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_wedding_analytics_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_wedding_packages_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_wedding_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_wedding_vendors_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/update_budget_item_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/update_timeline_task_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/update_vendor_booking_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/update_wedding_usecase.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/budget_tracker/budget_tracker_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/package_builder/package_builder_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/vendor_detail/vendor_detail_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/venue_detail/venue_detail_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_analytics/wedding_analytics_cubit.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_dashboard/wedding_dashboard_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_marketplace/wedding_marketplace_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/wedding_timeline/wedding_timeline_bloc.dart';

void registerWeddingModule(GetIt sl) {
  // ── Data sources ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<WeddingLocalDataSource>(
    () => WeddingLocalDataSourceImpl(
      dao: sl<AppDatabase>().weddingDao,
      cache: sl<CacheManager>(),
    ),
  );

  sl.registerLazySingleton<WeddingRemoteDataSource>(
    () => WeddingRemoteDataSourceImpl(sl<Dio>()),
  );

  // ── Repository ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<WeddingRepository>(
    () => WeddingRepositoryImpl(
      local: sl<WeddingLocalDataSource>(),
      remote: sl<WeddingRemoteDataSource>(),
    ),
  );

  // ── Use cases ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => GetWeddingUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => CreateWeddingUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateWeddingUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => GetWeddingVendorsUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => GetVendorDetailUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => GetVenuesUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => GetVenueDetailUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => GetWeddingPackagesUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => BuildCustomPackageUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => CreateVendorBookingUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateVendorBookingUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => GetVendorBookingsUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => GetBudgetUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => AddBudgetItemUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateBudgetItemUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => GetTimelineUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateTimelineTaskUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => AddTimelineTaskUseCase(sl<WeddingRepository>()),
  );
  sl.registerLazySingleton(
    () => GetWeddingAnalyticsUseCase(sl<WeddingRepository>()),
  );

  // ── BLoCs (factory — screen-scoped) ──────────────────────────────────────────
  sl.registerFactory(
    () => WeddingDashboardBloc(
      getWedding: sl<GetWeddingUseCase>(),
      getTimeline: sl<GetTimelineUseCase>(),
      getAnalytics: sl<GetWeddingAnalyticsUseCase>(),
    ),
  );
  sl.registerFactory(
    () => WeddingMarketplaceBloc(
      getVendors: sl<GetWeddingVendorsUseCase>(),
      getVenues: sl<GetVenuesUseCase>(),
    ),
  );
  sl.registerFactory(
    () => VendorDetailBloc(
      getVendorDetail: sl<GetVendorDetailUseCase>(),
      createBooking: sl<CreateVendorBookingUseCase>(),
    ),
  );
  sl.registerFactory(
    () => VenueDetailBloc(
      getVenueDetail: sl<GetVenueDetailUseCase>(),
    ),
  );
  sl.registerFactory(
    () => PackageBuilderBloc(
      getPackages: sl<GetWeddingPackagesUseCase>(),
      buildPackage: sl<BuildCustomPackageUseCase>(),
    ),
  );
  sl.registerFactory(
    () => BudgetTrackerBloc(
      getBudget: sl<GetBudgetUseCase>(),
      addItem: sl<AddBudgetItemUseCase>(),
      updateItem: sl<UpdateBudgetItemUseCase>(),
    ),
  );
  sl.registerFactory(
    () => WeddingTimelineBloc(
      getTimeline: sl<GetTimelineUseCase>(),
      updateTask: sl<UpdateTimelineTaskUseCase>(),
      addTask: sl<AddTimelineTaskUseCase>(),
    ),
  );
  sl.registerFactory(
    () => WeddingAnalyticsCubit(getAnalytics: sl<GetWeddingAnalyticsUseCase>()),
  );
}
