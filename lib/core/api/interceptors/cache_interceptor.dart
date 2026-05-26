import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:vibyuk/core/cache/cache_manager.dart';
import 'package:vibyuk/core/config/app_config.dart';
import 'package:vibyuk/core/logging/app_logger.dart';

/// HTTP-level response cache for GET requests.
/// Responses are keyed by full URL + query params.
/// Cache-Control headers from the server are respected when present.
class CacheInterceptor extends Interceptor {
  CacheInterceptor({
    required CacheManager cache,
    Duration? defaultTtl,
  })  : _cache = cache,
        _defaultTtl = defaultTtl ?? AppConfig.shortCacheDuration;

  final CacheManager _cache;
  final Duration _defaultTtl;

  // Paths that should never be cached
  static const _noCachePaths = {
    '/auth/',
    '/notifications/',
    '/admin/',
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isCacheable(options)) return handler.next(options);

    final cacheKey = _buildKey(options);
    final cached = _cache.get<Map<String, dynamic>>(
      cacheKey,
      deserializer: (s) => jsonDecode(s) as Map<String, dynamic>,
    );

    if (cached != null) {
      AppLogger.debug('CacheInterceptor: HIT $cacheKey');
      return handler.resolve(
        Response(
          requestOptions: options,
          data: cached['data'],
          statusCode: 200,
          headers: Headers.fromMap({
            'x-cache': ['HIT'],
          }),
        ),
        true,
      );
    }

    AppLogger.debug('CacheInterceptor: MISS $cacheKey');
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (!_isCacheable(response.requestOptions)) return handler.next(response);
    if (response.statusCode != 200) return handler.next(response);

    final cacheKey = _buildKey(response.requestOptions);
    final ttl = _extractTtl(response.headers) ?? _defaultTtl;

    try {
      await _cache.set<Map<String, dynamic>>(
        cacheKey,
        {'data': response.data, 'cachedAt': DateTime.now().toIso8601String()},
        ttl: ttl,
        serializer: jsonEncode,
      );
      AppLogger.debug('CacheInterceptor: STORED $cacheKey (ttl: ${ttl.inSeconds}s)');
    } catch (e) {
      // Cache write failure must not break the response flow
      AppLogger.warning('CacheInterceptor: failed to store $cacheKey', error: e);
    }

    handler.next(response);
  }

  bool _isCacheable(RequestOptions options) {
    if (options.method.toUpperCase() != 'GET') return false;
    // Opt-out via extra flag: options.extra['no_cache'] = true
    if (options.extra['no_cache'] == true) return false;
    final path = options.path;
    return !_noCachePaths.any((p) => path.contains(p));
  }

  String _buildKey(RequestOptions options) {
    final params = options.queryParameters.entries
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final query = params.map((e) => '${e.key}=${e.value}').join('&');
    return 'http_cache:${options.path}${query.isEmpty ? '' : '?$query'}';
  }

  Duration? _extractTtl(Headers headers) {
    final cc = headers.value('cache-control');
    if (cc == null) return null;
    final maxAgeMatch = RegExp(r'max-age=(\d+)').firstMatch(cc);
    if (maxAgeMatch == null) return null;
    final seconds = int.tryParse(maxAgeMatch.group(1) ?? '');
    return seconds != null ? Duration(seconds: seconds) : null;
  }
}
