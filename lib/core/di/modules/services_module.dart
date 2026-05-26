import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:vibyuk/core/observers/analytics_route_observer.dart';
import 'package:vibyuk/core/observers/app_bloc_observer.dart';
import 'package:vibyuk/core/services/analytics_service.dart';
import 'package:vibyuk/core/services/crash_reporting_service.dart';
import 'package:vibyuk/core/services/deep_link_service.dart';
import 'package:vibyuk/core/services/performance_service.dart';
import 'package:vibyuk/core/storage/encrypted_storage_service.dart';

void registerServicesModule(GetIt sl) {
  // Secure storage — versioned encrypted wrapper
  sl.registerLazySingleton<EncryptedStorageService>(
    () => EncryptedStorageService(
      sl<FlutterSecureStorage>(),
      schemaVersion: 1,
    ),
  );

  // Firebase Analytics wrapper
  sl.registerLazySingleton<AnalyticsService>(
    () => AnalyticsService(FirebaseAnalytics.instance),
  );

  // Firebase Crashlytics wrapper
  sl.registerLazySingleton<CrashReportingService>(
    () => CrashReportingService(FirebaseCrashlytics.instance),
  );

  // Firebase Performance wrapper
  sl.registerLazySingleton<PerformanceService>(
    () => PerformanceService(FirebasePerformance.instance),
  );

  // Route observer for screen-view analytics
  sl.registerLazySingleton<AnalyticsRouteObserver>(
    () => AnalyticsRouteObserver(
      analytics: sl<AnalyticsService>(),
      crashReporting: sl<CrashReportingService>(),
    ),
  );

  // BLoC observer — registered globally in main
  sl.registerLazySingleton<AppBlocObserver>(
    () => AppBlocObserver(crashReporting: sl<CrashReportingService>()),
  );

  // Deep link service (singleton, initialized in main)
  sl.registerLazySingleton<DeepLinkService>(() => DeepLinkService.instance);
}
