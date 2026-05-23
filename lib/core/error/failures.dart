import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'Failure($code): $message';
}

final class NetworkFailure extends Failure {
  final int? statusCode;
  const NetworkFailure({
    required super.message,
    this.statusCode,
    super.code,
  });

  @override
  List<Object?> get props => [...super.props, statusCode];
}

final class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code,
  });
}

final class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors,
    super.code,
  });

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

final class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
  });
}

final class ConnectionFailure extends Failure {
  const ConnectionFailure({
    super.message = 'No internet connection.',
    super.code = 'NO_CONNECTION',
  });
}

final class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

final class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
  });
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timed out.',
    super.code = 'TIMEOUT',
  });
}

final class RateLimitFailure extends Failure {
  final Duration? retryAfter;

  const RateLimitFailure({
    super.message = 'Too many requests.',
    super.code = 'RATE_LIMIT',
    this.retryAfter,
  });

  @override
  List<Object?> get props => [...super.props, retryAfter];
}

final class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code = 'UNKNOWN',
  });
}
