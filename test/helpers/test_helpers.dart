import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vibyuk/core/error/failures.dart';

// ── Fake RequestOptions ───────────────────────────────────────────────────

RequestOptions fakeRequest({String path = '/test', String method = 'GET'}) =>
    RequestOptions(path: path, method: method);

Response<T> fakeResponse<T>({
  required int statusCode,
  T? data,
  String path = '/test',
}) =>
    Response<T>(
      requestOptions: fakeRequest(path: path),
      statusCode: statusCode,
      data: data,
    );

DioException fakeDioError({
  DioExceptionType type = DioExceptionType.badResponse,
  int? statusCode,
  String path = '/test',
}) =>
    DioException(
      requestOptions: fakeRequest(path: path),
      type: type,
      response: statusCode != null
          ? fakeResponse(statusCode: statusCode, path: path)
          : null,
    );

// ── Failure matchers ──────────────────────────────────────────────────────

Matcher isNetworkFailure({int? statusCode}) => isA<NetworkFailure>()
    .having((f) => statusCode == null || f.statusCode == statusCode, 'statusCode', true);

Matcher isAuthFailure() => isA<AuthFailure>();
Matcher isServerFailure() => isA<ServerFailure>();
Matcher isConnectionFailure() => isA<ConnectionFailure>();
Matcher isNotFoundFailure() => isA<NotFoundFailure>();
