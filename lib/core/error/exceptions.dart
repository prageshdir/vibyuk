sealed class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException($code): $message';
}

final class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required super.message,
    this.statusCode,
    super.code,
    super.stackTrace,
  });
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized. Please log in again.',
    super.code = 'AUTH_401',
    super.stackTrace,
  });
}

final class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.code = 'AUTH_403',
    super.stackTrace,
  });
}

final class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code = 'NOT_FOUND_404',
    super.stackTrace,
  });
}

final class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    super.message = 'Validation failed.',
    super.code = 'VALIDATION_422',
    this.fieldErrors,
    super.stackTrace,
  });
}

final class ServerException extends AppException {
  const ServerException({
    super.message = 'An unexpected server error occurred.',
    super.code = 'SERVER_500',
    super.stackTrace,
  });
}

final class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Request timed out. Please try again.',
    super.code = 'TIMEOUT',
    super.stackTrace,
  });
}

final class ConnectionException extends AppException {
  const ConnectionException({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NO_CONNECTION',
    super.stackTrace,
  });
}

final class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code = 'CACHE_ERROR',
    super.stackTrace,
  });
}

final class TokenRefreshException extends AppException {
  const TokenRefreshException({
    super.message = 'Session expired. Please log in again.',
    super.code = 'TOKEN_REFRESH_FAILED',
    super.stackTrace,
  });
}

final class ParseException extends AppException {
  const ParseException({
    required super.message,
    super.code = 'PARSE_ERROR',
    super.stackTrace,
  });
}

final class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code = 'STORAGE_ERROR',
    super.stackTrace,
  });
}

final class RateLimitException extends AppException {
  final Duration? retryAfter;

  const RateLimitException({
    super.message = 'Too many requests. Please wait before trying again.',
    super.code = 'RATE_LIMIT_429',
    this.retryAfter,
    super.stackTrace,
  });
}
