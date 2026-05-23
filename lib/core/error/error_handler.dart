import 'package:dio/dio.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/logging/app_logger.dart';

class ErrorHandler {
  ErrorHandler._();

  static AppException handleDioError(DioException error) {
    AppLogger.error('DioException', error: error, stackTrace: error.stackTrace);

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const TimeoutException(),
      DioExceptionType.connectionError => const ConnectionException(),
      DioExceptionType.badResponse => _handleBadResponse(error.response),
      DioExceptionType.cancel =>
        const NetworkException(message: 'Request was cancelled.', code: 'CANCELLED'),
      _ => NetworkException(
          message: error.message ?? 'Network error occurred.',
          code: 'NETWORK_ERROR',
        ),
    };
  }

  static AppException _handleBadResponse(Response? response) {
    if (response == null) {
      return const ServerException();
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    String message = _extractMessage(data) ?? 'An error occurred.';

    return switch (statusCode) {
      400 => ValidationException(
          message: message,
          code: 'BAD_REQUEST_400',
          fieldErrors: _extractFieldErrors(data),
        ),
      401 => const UnauthorizedException(),
      403 => const ForbiddenException(),
      404 => NotFoundException(message: message),
      409 => NetworkException(message: message, statusCode: statusCode, code: 'CONFLICT_409'),
      422 => ValidationException(
          message: message,
          code: 'UNPROCESSABLE_422',
          fieldErrors: _extractFieldErrors(data),
        ),
      429 => RateLimitException(
          retryAfter: _extractRetryAfter(response.headers),
        ),
      500 || 502 || 503 || 504 => const ServerException(),
      _ => NetworkException(message: message, statusCode: statusCode),
    };
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error'] ?? data['detail'])?.toString();
    }
    return null;
  }

  static Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final errors = data['errors'] ?? data['field_errors'];
    if (errors is! Map<String, dynamic>) return null;

    return errors.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.map((e) => e.toString()).toList());
      }
      return MapEntry(key, [value.toString()]);
    });
  }

  static Duration? _extractRetryAfter(Headers headers) {
    final retryAfter = headers.value('retry-after');
    if (retryAfter == null) return null;
    final seconds = int.tryParse(retryAfter);
    return seconds != null ? Duration(seconds: seconds) : null;
  }

  // Maps AppException → Failure for repository layer
  static Failure mapExceptionToFailure(AppException exception) {
    return switch (exception) {
      UnauthorizedException() => AuthFailure(message: exception.message, code: exception.code),
      ForbiddenException() => AuthFailure(message: exception.message, code: exception.code),
      NotFoundException() => NotFoundFailure(message: exception.message, code: exception.code),
      ValidationException e => ValidationFailure(
          message: e.message,
          fieldErrors: e.fieldErrors,
          code: e.code,
        ),
      ServerException() => ServerFailure(message: exception.message, code: exception.code),
      TimeoutException() => const TimeoutFailure(),
      ConnectionException() => const ConnectionFailure(),
      CacheException() => CacheFailure(message: exception.message, code: exception.code),
      StorageException() => StorageFailure(message: exception.message, code: exception.code),
      TokenRefreshException() =>
        AuthFailure(message: exception.message, code: exception.code),
      RateLimitException e =>
        RateLimitFailure(retryAfter: e.retryAfter, code: exception.code),
      _ => NetworkFailure(
          message: exception.message,
          statusCode: exception is NetworkException ? (exception as NetworkException).statusCode : null,
          code: exception.code,
        ),
    };
  }
}
