import 'package:dio/dio.dart';
import 'package:vibyuk/core/auth/token_manager.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/logging/app_logger.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenManager);

  final TokenManager _tokenManager;

  // Endpoints that must never carry auth headers
  static const _publicPaths = {
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/google',
    '/auth/phone/send-otp',
    '/auth/phone/verify-otp',
    '/auth/refresh',
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;

    if (_publicPaths.any((p) => path.contains(p))) {
      return handler.next(options);
    }

    try {
      final accessToken = await _tokenManager.getValidAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    } catch (e) {
      // Token retrieval failed; let the request proceed and 401 will be caught
      AppLogger.warning('Could not attach auth token to request: $path');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 401s on public paths propagate normally
    if (err.response?.statusCode == 401) {
      final path = err.requestOptions.path;
      if (_publicPaths.any((p) => path.contains(p))) {
        return handler.next(err);
      }

      // Proactively signal session expiry — token_manager handles the broadcast
      AppLogger.warning('401 received for protected path: $path');
    }

    handler.next(err);
  }
}
