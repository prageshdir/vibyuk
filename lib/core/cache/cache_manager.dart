import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:vibyuk/core/config/app_config.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/logging/app_logger.dart';

/// A generic key-value cache backed by Hive with TTL support.
class CacheManager {
  CacheManager(this._box);

  final Box<String> _box;

  static const String _metaSuffix = '__meta';

  Future<void> set<T>(
    String key,
    T value, {
    Duration ttl = AppConfig.defaultCacheDuration,
    required String Function(T) serializer,
  }) async {
    try {
      final json = serializer(value);
      final meta = jsonEncode({
        'expiry': DateTime.now().add(ttl).toIso8601String(),
      });
      await _box.put(key, json);
      await _box.put('$key$_metaSuffix', meta);
    } catch (e, st) {
      AppLogger.error('CacheManager.set failed for key: $key', error: e, stackTrace: st);
      throw CacheException(message: 'Failed to write cache entry.');
    }
  }

  T? get<T>(
    String key, {
    required T Function(String) deserializer,
  }) {
    try {
      final metaJson = _box.get('$key$_metaSuffix');
      if (metaJson == null) return null;

      final meta = jsonDecode(metaJson) as Map<String, dynamic>;
      final expiry = DateTime.parse(meta['expiry'] as String);
      if (DateTime.now().isAfter(expiry)) {
        _evict(key);
        return null;
      }

      final value = _box.get(key);
      if (value == null) return null;
      return deserializer(value);
    } catch (e, st) {
      AppLogger.warning('CacheManager.get failed for key: $key', error: e, stackTrace: st);
      return null;
    }
  }

  Future<void> remove(String key) async {
    await _box.delete(key);
    await _box.delete('$key$_metaSuffix');
  }

  Future<void> clear() async => _box.clear();

  bool containsKey(String key) {
    final metaJson = _box.get('$key$_metaSuffix');
    if (metaJson == null) return false;
    try {
      final meta = jsonDecode(metaJson) as Map<String, dynamic>;
      final expiry = DateTime.parse(meta['expiry'] as String);
      if (DateTime.now().isAfter(expiry)) {
        _evict(key);
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  void _evict(String key) {
    _box.delete(key);
    _box.delete('$key$_metaSuffix');
  }

  /// Removes all stale entries (runs on app start to prevent unbounded growth).
  Future<void> evictExpired() async {
    final keys = _box.keys
        .where((k) => k.toString().endsWith(_metaSuffix))
        .toList();

    for (final metaKey in keys) {
      final dataKey = metaKey.toString().replaceFirst(_metaSuffix, '');
      final metaJson = _box.get(metaKey.toString());
      if (metaJson == null) continue;
      try {
        final meta = jsonDecode(metaJson) as Map<String, dynamic>;
        final expiry = DateTime.parse(meta['expiry'] as String);
        if (DateTime.now().isAfter(expiry)) {
          await _box.delete(dataKey);
          await _box.delete(metaKey);
        }
      } catch (_) {
        await _box.delete(dataKey);
        await _box.delete(metaKey);
      }
    }

    AppLogger.debug('CacheManager: evictExpired complete');
  }
}
