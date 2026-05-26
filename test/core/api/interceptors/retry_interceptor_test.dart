import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibyuk/core/api/interceptors/retry_interceptor.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/error/exceptions.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

class _FakeDio extends Fake implements Dio {
  _FakeDio({this.fetchCallback});

  int fetchCalls = 0;
  final Future<Response<dynamic>> Function(RequestOptions)? fetchCallback;

  @override
  Future<Response<T>> fetch<T>(RequestOptions requestOptions) async {
    fetchCalls++;
    if (fetchCallback != null) {
      return (await fetchCallback!(requestOptions)) as Response<T>;
    }
    return Response<T>(requestOptions: requestOptions, statusCode: 200);
  }
}

class _FakeErrorHandler extends Fake implements ErrorInterceptorHandler {
  DioException? nextError;
  Response<dynamic>? resolved;

  @override
  void next(DioException err) => nextError = err;

  @override
  void resolve(
    Response<dynamic> response, [
    bool callFollowingResponseInterceptor = false,
  ]) =>
      resolved = response;
}

DioException _error({
  DioExceptionType type = DioExceptionType.badResponse,
  int? statusCode,
  int retryCount = 0,
}) {
  final opts = RequestOptions(
    path: '/test',
    extra: {if (retryCount > 0) 'retry_count': retryCount},
  );
  return DioException(
    requestOptions: opts,
    type: type,
    response: statusCode != null
        ? Response(requestOptions: opts, statusCode: statusCode)
        : null,
  );
}

void main() {
  setUpAll(() => FlavorConfig.initialize(AppFlavor.dev));

  group('RetryInterceptor', () {
    test('passes through non-retryable 400 immediately without fetching', () async {
      final dio = _FakeDio();
      final handler = _FakeErrorHandler();
      final interceptor =
          RetryInterceptor(dio: dio, maxRetries: 3, initialDelay: Duration.zero);

      await interceptor.onError(_error(statusCode: 400), handler);

      expect(handler.nextError, isNotNull);
      expect(dio.fetchCalls, 0);
    });

    test('never retries 401 (auth must be handled separately)', () async {
      final dio = _FakeDio();
      final handler = _FakeErrorHandler();
      final interceptor =
          RetryInterceptor(dio: dio, maxRetries: 3, initialDelay: Duration.zero);

      await interceptor.onError(_error(statusCode: 401), handler);

      expect(handler.nextError, isNotNull);
      expect(dio.fetchCalls, 0);
    });

    test('never retries 403 (forbidden)', () async {
      final dio = _FakeDio();
      final handler = _FakeErrorHandler();
      final interceptor =
          RetryInterceptor(dio: dio, maxRetries: 3, initialDelay: Duration.zero);

      await interceptor.onError(_error(statusCode: 403), handler);

      expect(handler.nextError, isNotNull);
      expect(dio.fetchCalls, 0);
    });

    test('retries on 500 and resolves when retry succeeds', () async {
      final dio = _FakeDio();
      final handler = _FakeErrorHandler();
      final interceptor =
          RetryInterceptor(dio: dio, maxRetries: 3, initialDelay: Duration.zero);

      await interceptor.onError(_error(statusCode: 500), handler);

      expect(dio.fetchCalls, 1);
      expect(handler.resolved, isNotNull);
      expect(handler.nextError, isNull);
    });

    test('retries on 429 rate-limit response', () async {
      final dio = _FakeDio();
      final handler = _FakeErrorHandler();
      final interceptor =
          RetryInterceptor(dio: dio, maxRetries: 3, initialDelay: Duration.zero);

      await interceptor.onError(_error(statusCode: 429), handler);

      expect(dio.fetchCalls, 1);
      expect(handler.resolved, isNotNull);
    });

    test('retries on 502 bad gateway', () async {
      final dio = _FakeDio();
      final handler = _FakeErrorHandler();
      final interceptor =
          RetryInterceptor(dio: dio, maxRetries: 3, initialDelay: Duration.zero);

      await interceptor.onError(_error(statusCode: 502), handler);

      expect(dio.fetchCalls, 1);
      expect(handler.resolved, isNotNull);
    });

    test('retries on connectionError type', () async {
      final dio = _FakeDio();
      final handler = _FakeErrorHandler();
      final interceptor =
          RetryInterceptor(dio: dio, maxRetries: 3, initialDelay: Duration.zero);

      await interceptor.onError(
        _error(type: DioExceptionType.connectionError),
        handler,
      );

      expect(dio.fetchCalls, 1);
      expect(handler.resolved, isNotNull);
    });

    test('retries on connectionTimeout type', () async {
      final dio = _FakeDio();
      final handler = _FakeErrorHandler();
      final interceptor =
          RetryInterceptor(dio: dio, maxRetries: 3, initialDelay: Duration.zero);

      await interceptor.onError(
        _error(type: DioExceptionType.connectionTimeout),
        handler,
      );

      expect(dio.fetchCalls, 1);
      expect(handler.resolved, isNotNull);
    });

    test('stops retrying once retry_count reaches maxRetries', () async {
      final dio = _FakeDio();
      final handler = _FakeErrorHandler();
      final interceptor =
          RetryInterceptor(dio: dio, maxRetries: 2, initialDelay: Duration.zero);

      await interceptor.onError(_error(statusCode: 500, retryCount: 2), handler);

      expect(dio.fetchCalls, 0);
      expect(handler.nextError, isNotNull);
    });

    test('forwards DioException thrown during retry attempt', () async {
      final opts = RequestOptions(path: '/test');
      final retryErr = DioException(
        requestOptions: opts,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: opts, statusCode: 500),
      );
      final dio = _FakeDio(fetchCallback: (_) async => throw retryErr);
      final handler = _FakeErrorHandler();
      final interceptor =
          RetryInterceptor(dio: dio, maxRetries: 3, initialDelay: Duration.zero);

      await interceptor.onError(_error(statusCode: 500), handler);

      expect(dio.fetchCalls, 1);
      expect(handler.nextError, isNotNull);
    });
  });

  group('RetryMixin', () {
    test('succeeds immediately on first call', () async {
      final mixin = _TestMixin();
      final result = await mixin.withRetry(() async => 99);
      expect(result, 99);
    });

    test('retries on ConnectionException and eventually succeeds', () async {
      final mixin = _TestMixin();
      int attempts = 0;
      final result = await mixin.withRetry<String>(
        () async {
          attempts++;
          if (attempts < 3) throw const ConnectionException();
          return 'done';
        },
        maxAttempts: 5,
        initialDelay: Duration.zero,
      );
      expect(result, 'done');
      expect(attempts, 3);
    });

    test('rethrows after exhausting maxAttempts', () async {
      final mixin = _TestMixin();
      await expectLater(
        () => mixin.withRetry<void>(
          () async => throw const ConnectionException(),
          maxAttempts: 3,
          initialDelay: Duration.zero,
        ),
        throwsA(isA<ConnectionException>()),
      );
    });

    test('does not retry when retryIf returns false', () async {
      final mixin = _TestMixin();
      int attempts = 0;
      await expectLater(
        () => mixin.withRetry<void>(
          () async {
            attempts++;
            throw StateError('unretryable');
          },
          maxAttempts: 5,
          initialDelay: Duration.zero,
          retryIf: (_) => false,
        ),
        throwsA(isA<StateError>()),
      );
      expect(attempts, 1);
    });
  });
}

class _TestMixin with RetryMixin {}
