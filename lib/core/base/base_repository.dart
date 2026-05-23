import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/interceptors/error_interceptor.dart';
import 'package:vibyuk/core/error/error_handler.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/logging/app_logger.dart';

abstract class BaseRepository {
  /// Wraps a data-source call in uniform error handling.
  ///
  /// Returns [Right] on success and [Left] on any [AppException] or
  /// [DioException], converting both to the appropriate [Failure] subtype.
  Future<Either<Failure, T>> safeCall<T>(
    Future<T> Function() call, {
    String? context,
  }) async {
    try {
      final result = await call();
      return Right(result);
    } on DioException catch (e, st) {
      final appException = ErrorInterceptor.extractAppException(e) ??
          ErrorHandler.handleDioError(e);
      AppLogger.error(
        '[${context ?? runtimeType}] DioException',
        error: appException,
        stackTrace: st,
      );
      return Left(ErrorHandler.mapExceptionToFailure(appException));
    } on AppException catch (e, st) {
      AppLogger.error(
        '[${context ?? runtimeType}] AppException',
        error: e,
        stackTrace: st,
      );
      return Left(ErrorHandler.mapExceptionToFailure(e));
    } catch (e, st) {
      AppLogger.error(
        '[${context ?? runtimeType}] Unexpected error',
        error: e,
        stackTrace: st,
      );
      return const Left(UnknownFailure());
    }
  }

  /// Same as [safeCall] but for synchronous operations (e.g., cache reads).
  Either<Failure, T> safeSyncCall<T>(
    T Function() call, {
    String? context,
  }) {
    try {
      return Right(call());
    } on AppException catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    } catch (e, st) {
      AppLogger.error('[${context ?? runtimeType}] Sync error', error: e, stackTrace: st);
      return const Left(UnknownFailure());
    }
  }
}
