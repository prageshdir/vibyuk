import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/interceptors/auth_interceptor.dart';
import 'package:vibyuk/core/api/interceptors/cache_interceptor.dart';
import 'package:vibyuk/core/api/interceptors/connectivity_interceptor.dart';
import 'package:vibyuk/core/api/interceptors/error_interceptor.dart';
import 'package:vibyuk/core/api/interceptors/logging_interceptor.dart';
import 'package:vibyuk/core/api/interceptors/retry_interceptor.dart';
import 'package:vibyuk/core/cache/cache_manager.dart';
import 'package:vibyuk/core/config/flavor_config.dart';

class ApiClient {
  ApiClient._();

  static Dio create({
    required AuthInterceptor authInterceptor,
    required ConnectivityInterceptor connectivityInterceptor,
    required CacheManager cacheManager,
  }) {
    final config = FlavorConfig.instance;
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-App-Version': '1.0.0',
          'X-Platform': 'flutter',
        },
      ),
    );

    dio.interceptors.addAll([
      connectivityInterceptor,                      // 1: reject immediately if offline
      authInterceptor,                              // 2: attach token
      CacheInterceptor(cacheManager),               // 3: serve/store GET cache
      ErrorInterceptor(),                           // 4: normalize errors
      RetryInterceptor(                             // 5: retry on transient failures
        dio,
        maxRetries: config.maxRetries,
        initialDelay: const Duration(milliseconds: 500),
      ),
      LoggingInterceptor(),                         // 6: log everything
    ]);

    return dio;
  }
}
