import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:vibyuk/core/api/interceptors/cache_interceptor.dart';
import 'package:vibyuk/core/cache/cache_manager.dart';
import 'package:vibyuk/core/config/flavor_config.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

class _FakeBox extends Fake implements Box<String> {
  final _data = <dynamic, String>{};

  @override
  String? get(dynamic key, {String? defaultValue}) => _data[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, String value) async => _data[key] = value;

  @override
  Future<void> delete(dynamic key) async => _data.remove(key);

  @override
  Iterable<dynamic> get keys => _data.keys.toList();

  @override
  Future<int> clear() async {
    _data.clear();
    return 0;
  }
}

class _FakeRequestHandler extends Fake implements RequestInterceptorHandler {
  RequestOptions? nextOptions;
  Response<dynamic>? resolved;

  @override
  void next(RequestOptions options) => nextOptions = options;

  @override
  void resolve(
    Response<dynamic> response, [
    bool callFollowingResponseInterceptor = false,
  ]) =>
      resolved = response;
}

class _FakeResponseHandler extends Fake implements ResponseInterceptorHandler {
  Response<dynamic>? nextResponse;

  @override
  void next(Response<dynamic> response) => nextResponse = response;
}

RequestOptions _getOptions({
  String path = '/api/creators',
  Map<String, dynamic>? query,
  Map<String, dynamic>? extra,
}) =>
    RequestOptions(
      path: path,
      method: 'GET',
      queryParameters: query ?? {},
      extra: extra ?? {},
    );

void main() {
  late _FakeBox box;
  late CacheManager cacheManager;
  late CacheInterceptor interceptor;

  setUpAll(() => FlavorConfig.initialize(AppFlavor.dev));

  setUp(() {
    box = _FakeBox();
    cacheManager = CacheManager(box);
    interceptor = CacheInterceptor(
      cache: cacheManager,
      defaultTtl: const Duration(minutes: 5),
    );
  });

  group('CacheInterceptor.onRequest', () {
    test('cache MISS passes request to next', () async {
      final handler = _FakeRequestHandler();
      await interceptor.onRequest(_getOptions(), handler);

      expect(handler.nextOptions, isNotNull);
      expect(handler.resolved, isNull);
    });

    test('cache HIT resolves request with cached data', () async {
      // Seed the cache manually via onResponse
      final reqOpts = _getOptions();
      final resHandler = _FakeResponseHandler();
      await interceptor.onResponse(
        Response(
          requestOptions: reqOpts,
          statusCode: 200,
          data: {'items': [1, 2, 3]},
        ),
        resHandler,
      );

      // Second request should hit cache
      final reqHandler = _FakeRequestHandler();
      await interceptor.onRequest(reqOpts, reqHandler);

      expect(reqHandler.resolved, isNotNull);
      expect(reqHandler.nextOptions, isNull);
    });

    test('non-GET request bypasses cache and passes through', () async {
      final handler = _FakeRequestHandler();
      final opts = RequestOptions(path: '/api/creators', method: 'POST');
      await interceptor.onRequest(opts, handler);

      expect(handler.nextOptions, isNotNull);
      expect(handler.resolved, isNull);
    });

    test('/auth/ path bypasses cache', () async {
      final handler = _FakeRequestHandler();
      await interceptor.onRequest(_getOptions(path: '/auth/login'), handler);

      expect(handler.nextOptions, isNotNull);
      expect(handler.resolved, isNull);
    });

    test('/notifications/ path bypasses cache', () async {
      final handler = _FakeRequestHandler();
      await interceptor.onRequest(
        _getOptions(path: '/notifications/unread'),
        handler,
      );

      expect(handler.nextOptions, isNotNull);
      expect(handler.resolved, isNull);
    });

    test('/admin/ path bypasses cache', () async {
      final handler = _FakeRequestHandler();
      await interceptor.onRequest(
        _getOptions(path: '/admin/dashboard'),
        handler,
      );

      expect(handler.nextOptions, isNotNull);
      expect(handler.resolved, isNull);
    });

    test('no_cache=true extra flag bypasses cache', () async {
      // Seed cache first
      final reqOpts = _getOptions();
      final resHandler = _FakeResponseHandler();
      await interceptor.onResponse(
        Response(requestOptions: reqOpts, statusCode: 200, data: 'cached'),
        resHandler,
      );

      // Request with no_cache flag
      final handler = _FakeRequestHandler();
      await interceptor.onRequest(
        _getOptions(extra: {'no_cache': true}),
        handler,
      );

      expect(handler.nextOptions, isNotNull);
      expect(handler.resolved, isNull);
    });
  });

  group('CacheInterceptor.onResponse', () {
    test('stores 200 GET response in cache', () async {
      final reqOpts = _getOptions();
      final handler = _FakeResponseHandler();

      await interceptor.onResponse(
        Response(requestOptions: reqOpts, statusCode: 200, data: {'ok': true}),
        handler,
      );

      expect(handler.nextResponse, isNotNull);
      // Verify cache was populated
      expect(cacheManager.containsKey('http_cache:/api/creators'), isTrue);
    });

    test('does not cache non-200 responses', () async {
      final reqOpts = _getOptions();
      final handler = _FakeResponseHandler();

      await interceptor.onResponse(
        Response(requestOptions: reqOpts, statusCode: 201, data: {}),
        handler,
      );

      expect(cacheManager.containsKey('http_cache:/api/creators'), isFalse);
    });

    test('does not cache POST responses', () async {
      final opts = RequestOptions(path: '/api/creators', method: 'POST');
      final handler = _FakeResponseHandler();

      await interceptor.onResponse(
        Response(requestOptions: opts, statusCode: 200, data: {}),
        handler,
      );

      expect(cacheManager.containsKey('http_cache:/api/creators'), isFalse);
    });

    test('respects cache-control max-age header', () async {
      final reqOpts = _getOptions(path: '/api/events');
      final handler = _FakeResponseHandler();
      final headers = Headers.fromMap({
        'cache-control': ['max-age=3600'],
      });

      await interceptor.onResponse(
        Response(
          requestOptions: reqOpts,
          statusCode: 200,
          data: {},
          headers: headers,
        ),
        handler,
      );

      expect(cacheManager.containsKey('http_cache:/api/events'), isTrue);
    });

    test('cache key includes sorted query parameters', () async {
      final reqOpts = _getOptions(
        path: '/api/search',
        query: {'page': '2', 'category': 'music'},
      );
      final handler = _FakeResponseHandler();

      await interceptor.onResponse(
        Response(requestOptions: reqOpts, statusCode: 200, data: {}),
        handler,
      );

      // Sorted: category before page
      expect(
        cacheManager.containsKey('http_cache:/api/search?category=music&page=2'),
        isTrue,
      );
    });
  });
}
