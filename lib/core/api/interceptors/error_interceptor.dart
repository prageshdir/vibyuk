import 'package:dio/dio.dart';
import 'package:vibyuk/core/error/error_handler.dart';
import 'package:vibyuk/core/error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = ErrorHandler.handleDioError(err);

    // Re-throw as a typed exception wrapped in DioException so the repository
    // catch block can handle AppException subtypes uniformly.
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appException,
        response: err.response,
        type: err.type,
        stackTrace: err.stackTrace,
        message: appException.message,
      ),
    );
  }

  // Extracts the AppException from a DioException.error for callers
  static AppException? extractAppException(DioException err) {
    final error = err.error;
    if (error is AppException) return error;
    return null;
  }
}
