import 'dart:async';

import 'package:dio/dio.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/logging/app_logger.dart';

/// Exponential-backoff retry interceptor.
/// Only retries on transient conditions: connection loss, 429, 500-504.
/// Never retries 4xx client errors or auth failures (handled by AuthInterceptor).
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    int? maxRetries,
    Duration? initialDelay,
  })  : _dio = dio,
        _maxRetries = maxRetries ?? FlavorConfig.instance.maxRetries,
        _initialDelay = initialDelay ?? const Duration(milliseconds: 500);

  final Dio _dio;
  final int _maxRetries;
  final Duration _initialDelay;

  static const _retryableStatuses = {429, 500, 502, 503, 504};
  static const _retryKey = 'retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final retryCount = requestOptions.extra[_retryKey] as int? ?? 0;

    if (!_shouldRetry(err, retryCount)) {
      return handler.next(err);
    }

    final nextRetryCount = retryCount + 1;
    final delay = _calculateDelay(nextRetryCount);

    AppLogger.warning(
      'RetryInterceptor: attempt $nextRetryCount/$_maxRetries '
      'for ${requestOptions.method} ${requestOptions.path} '
      '(status: ${err.response?.statusCode}) — retrying in ${delay.inMilliseconds}ms',
    );

    await Future<void>.delayed(delay);

    requestOptions.extra[_retryKey] = nextRetryCount;

    try {
      final response = await _dio.fetch<dynamic>(requestOptions);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }

  bool _shouldRetry(DioException err, int retryCount) {
    if (retryCount >= _maxRetries) return false;

    // Connection / timeout errors
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // Never retry auth failures — those must be handled explicitly
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      return false;
    }

    final status = err.response?.statusCode;
    return status != null && _retryableStatuses.contains(status);
  }

  /// Full jitter exponential backoff: delay = random(0, min(cap, base * 2^attempt))
  Duration _calculateDelay(int attempt) {
    final cap = const Duration(seconds: 30).inMilliseconds;
    final base = _initialDelay.inMilliseconds;
    final exponential = base * (1 << (attempt - 1));
    final capped = exponential.clamp(base, cap);
    // Add jitter: random 50-100% of capped value
    final jitter = (capped * (0.5 + 0.5 * _jitterFactor)).round();
    return Duration(milliseconds: jitter);
  }

  // Deterministic seed for tests; overridable
  double get _jitterFactor {
    return 0.5 + (DateTime.now().millisecondsSinceEpoch % 1000) / 2000;
  }
}

/// Mixin for use cases / repositories that need manual retry logic
/// (e.g. WebSocket reconnect, non-Dio calls).
mixin RetryMixin {
  Future<T> withRetry<T>(
    Future<T> Function() call, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
    bool Function(Object error)? retryIf,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await call();
      } catch (e) {
        attempt++;
        final shouldRetry = retryIf?.call(e) ?? _defaultRetryIf(e);
        if (attempt >= maxAttempts || !shouldRetry) rethrow;
        final delay = initialDelay * (1 << (attempt - 1));
        AppLogger.warning(
          'RetryMixin: attempt $attempt/$maxAttempts — retrying in ${delay.inMilliseconds}ms',
        );
        await Future<void>.delayed(delay);
      }
    }
  }

  bool _defaultRetryIf(Object error) {
    if (error is ConnectionException || error is TimeoutException) return true;
    if (error is NetworkException) {
      final code = error.statusCode;
      return code != null && (code == 429 || code >= 500);
    }
    return false;
  }
}
