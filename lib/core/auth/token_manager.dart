import 'dart:async';
import 'package:dio/dio.dart';
import 'package:vibyuk/core/auth/auth_storage.dart';
import 'package:vibyuk/core/auth/models/token_model.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/logging/app_logger.dart';

typedef TokenRefreshedCallback = void Function(TokenModel newTokens);
typedef SessionExpiredCallback = void Function();

class TokenManager {
  TokenManager(this._storage);

  final AuthStorage _storage;

  // Queues concurrent requests that arrive while a refresh is in flight
  Completer<TokenModel>? _refreshCompleter;

  TokenRefreshedCallback? onTokenRefreshed;
  SessionExpiredCallback? onSessionExpired;

  Future<TokenModel?> getValidTokens() async {
    final tokens = await _storage.getTokens();
    if (tokens == null) return null;

    if (tokens.isAccessTokenValid) return tokens;

    return _refreshTokens(tokens.refreshToken);
  }

  Future<String?> getValidAccessToken() async {
    final tokens = await getValidTokens();
    return tokens?.accessToken;
  }

  // Handles concurrent refresh requests: only one network call goes out
  Future<TokenModel> _refreshTokens(String refreshToken) async {
    if (_refreshCompleter != null) {
      AppLogger.debug('Token refresh already in flight — queuing request');
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<TokenModel>();

    try {
      final newTokens = await _performRefresh(refreshToken);
      await _storage.saveTokens(newTokens);
      onTokenRefreshed?.call(newTokens);
      _refreshCompleter!.complete(newTokens);
      return newTokens;
    } catch (e, st) {
      AppLogger.error('Token refresh failed', error: e, stackTrace: st);
      final exception = const TokenRefreshException();
      _refreshCompleter!.completeError(exception, st);
      await _storage.clearAll();
      onSessionExpired?.call();
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<TokenModel> _performRefresh(String refreshToken) async {
    // Uses a fresh Dio instance to avoid interceptor loops
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    try {
      final config = TokenManagerConfig.instance;
      final response = await dio.post(
        config.refreshEndpoint,
        data: {'refresh_token': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      return TokenModel(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
        accessTokenExpiresAt: DateTime.now().add(
          Duration(seconds: (data['expires_in'] as int? ?? 3600)),
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw const TokenRefreshException();
      }
      rethrow;
    } finally {
      dio.close();
    }
  }

  Future<void> saveTokens(TokenModel tokens) => _storage.saveTokens(tokens);

  Future<void> clearTokens() => _storage.clearAll();

  Future<bool> hasValidSession() => _storage.hasValidSession();
}

// Separate config to avoid circular dependency
class TokenManagerConfig {
  static TokenManagerConfig? _instance;

  static TokenManagerConfig get instance {
    assert(_instance != null, 'TokenManagerConfig must be initialized.');
    return _instance!;
  }

  static void initialize(String baseUrl) {
    _instance = TokenManagerConfig._(refreshEndpoint: '$baseUrl/auth/refresh');
  }

  final String refreshEndpoint;
  TokenManagerConfig._({required this.refreshEndpoint});
}
