import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:vibyuk/core/auth/auth_storage.dart';
import 'package:vibyuk/core/auth/token_manager.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/navigation/app_router.dart';
import 'package:vibyuk/core/navigation/guards/auth_guard.dart';
import 'package:vibyuk/core/observers/analytics_route_observer.dart';
import 'package:vibyuk/core/notifications/fcm_service.dart';
import 'package:vibyuk/core/notifications/notification_handler.dart';
import 'package:vibyuk/core/theme/theme_bloc.dart';
import 'package:vibyuk/core/utils/helpers/connectivity_helper.dart';

void registerCoreModule(GetIt sl) {
  // Connectivity
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<ConnectivityHelper>(
    () => ConnectivityHelper(sl<Connectivity>()),
  );

  // Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<AuthStorage>(
    () => AuthStorage(sl<FlutterSecureStorage>()),
  );

  // Auth / Token management
  sl.registerLazySingleton<TokenManager>(
    () => TokenManager(sl<AuthStorage>()),
  );

  // Navigation
  sl.registerLazySingleton<AuthGuard>(
    () => AuthGuard(sl<TokenManager>()),
  );
  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(sl<AuthGuard>(), sl<AnalyticsRouteObserver>()),
  );

  // Notifications
  sl.registerLazySingleton<NotificationHandler>(() => NotificationHandler());
  sl.registerLazySingleton<FcmService>(
    () => FcmService(sl<NotificationHandler>()),
  );

  // Theme
  sl.registerFactory<ThemeBloc>(() => ThemeBloc());

  // Bootstrap token manager config
  TokenManagerConfig.initialize(FlavorConfig.instance.baseUrl);
}
