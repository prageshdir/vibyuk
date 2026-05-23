import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibyuk/core/error/error_handler.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/error/failures.dart';

void main() {
  group('ErrorHandler', () {
    group('handleDioError', () {
      test('returns TimeoutException on connectionTimeout', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );
        final result = ErrorHandler.handleDioError(dioError);
        expect(result, isA<TimeoutException>());
      });

      test('returns ConnectionException on connectionError', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
        );
        final result = ErrorHandler.handleDioError(dioError);
        expect(result, isA<ConnectionException>());
      });

      test('returns UnauthorizedException on 401 response', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 401,
          ),
        );
        final result = ErrorHandler.handleDioError(dioError);
        expect(result, isA<UnauthorizedException>());
      });

      test('returns ServerException on 500 response', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 500,
          ),
        );
        final result = ErrorHandler.handleDioError(dioError);
        expect(result, isA<ServerException>());
      });
    });

    group('mapExceptionToFailure', () {
      test('maps UnauthorizedException to AuthFailure', () {
        const exception = UnauthorizedException();
        final failure = ErrorHandler.mapExceptionToFailure(exception);
        expect(failure, isA<AuthFailure>());
      });

      test('maps ConnectionException to ConnectionFailure', () {
        const exception = ConnectionException();
        final failure = ErrorHandler.mapExceptionToFailure(exception);
        expect(failure, isA<ConnectionFailure>());
      });

      test('maps ServerException to ServerFailure', () {
        const exception = ServerException();
        final failure = ErrorHandler.mapExceptionToFailure(exception);
        expect(failure, isA<ServerFailure>());
      });
    });
  });
}
