import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:vibyuk/core/api/api_client.dart';
import 'package:vibyuk/core/api/interceptors/auth_interceptor.dart';
import 'package:vibyuk/core/api/interceptors/connectivity_interceptor.dart';
import 'package:vibyuk/core/auth/token_manager.dart';
import 'package:vibyuk/core/utils/helpers/connectivity_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void registerApiModule(GetIt sl) {
  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(sl<TokenManager>()),
  );

  sl.registerLazySingleton<ConnectivityInterceptor>(
    () => ConnectivityInterceptor(sl<Connectivity>()),
  );

  sl.registerLazySingleton<Dio>(
    () => ApiClient.create(
      authInterceptor: sl<AuthInterceptor>(),
      connectivityInterceptor: sl<ConnectivityInterceptor>(),
    ),
  );
}
