import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/interceptors/auth_interceptor.dart';
import 'package:vibyuk/core/api/interceptors/connectivity_interceptor.dart';
import 'package:vibyuk/core/api/interceptors/error_interceptor.dart';
import 'package:vibyuk/core/api/interceptors/logging_interceptor.dart';
import 'package:vibyuk/core/config/flavor_config.dart';

class ApiClient {
  ApiClient._();

  static Dio create({
    required AuthInterceptor authInterceptor,
    required ConnectivityInterceptor connectivityInterceptor,
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
      connectivityInterceptor, // First: reject immediately if offline
      authInterceptor,         // Second: attach token
      ErrorInterceptor(),      // Third: normalize errors
      LoggingInterceptor(),    // Last: log everything
    ]);

    return dio;
  }
}
