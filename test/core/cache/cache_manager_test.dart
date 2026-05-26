import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:vibyuk/core/cache/cache_manager.dart';
import 'package:vibyuk/core/config/flavor_config.dart';

// ── In-memory Hive Box fake ───────────────────────────────────────────────

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
    final n = _data.length;
    _data.clear();
    return n;
  }
}

void main() {
  late _FakeBox box;
  late CacheManager cache;

  setUpAll(() => FlavorConfig.initialize(AppFlavor.dev));

  setUp(() {
    box = _FakeBox();
    cache = CacheManager(box);
  });

  group('CacheManager', () {
    test('set and get round-trips a string value', () async {
      await cache.set<String>(
        'k1',
        'hello',
        ttl: const Duration(minutes: 5),
        serializer: (v) => v,
      );

      final result = cache.get<String>('k1', deserializer: (s) => s);
      expect(result, 'hello');
    });

    test('get returns null for missing key', () {
      expect(cache.get<String>('ghost', deserializer: (s) => s), isNull);
    });

    test('get returns null and evicts an expired entry', () async {
      await cache.set<String>(
        'exp',
        'v',
        ttl: const Duration(milliseconds: 1),
        serializer: (v) => v,
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(cache.get<String>('exp', deserializer: (s) => s), isNull);
      expect(box.get('exp'), isNull);
      expect(box.get('exp__meta'), isNull);
    });

    test('containsKey returns true for a valid entry', () async {
      await cache.set<String>(
        'present',
        'v',
        ttl: const Duration(minutes: 5),
        serializer: (v) => v,
      );
      expect(cache.containsKey('present'), isTrue);
    });

    test('containsKey returns false for a missing key', () {
      expect(cache.containsKey('absent'), isFalse);
    });

    test('containsKey evicts expired entry and returns false', () async {
      await cache.set<String>(
        'stale',
        'v',
        ttl: const Duration(milliseconds: 1),
        serializer: (v) => v,
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(cache.containsKey('stale'), isFalse);
      expect(box.get('stale'), isNull);
    });

    test('remove deletes both data and meta keys', () async {
      await cache.set<String>(
        'toGo',
        'v',
        ttl: const Duration(minutes: 5),
        serializer: (v) => v,
      );
      await cache.remove('toGo');

      expect(box.get('toGo'), isNull);
      expect(box.get('toGo__meta'), isNull);
    });

    test('clear wipes all entries', () async {
      await cache.set<String>('a', 'va', ttl: const Duration(minutes: 5), serializer: (v) => v);
      await cache.set<String>('b', 'vb', ttl: const Duration(minutes: 5), serializer: (v) => v);
      await cache.clear();

      expect(cache.containsKey('a'), isFalse);
      expect(cache.containsKey('b'), isFalse);
    });

    test('evictExpired removes stale entries and keeps fresh ones', () async {
      await cache.set<String>('fresh', 'v', ttl: const Duration(hours: 1), serializer: (v) => v);
      await cache.set<String>(
        'stale',
        'v',
        ttl: const Duration(milliseconds: 1),
        serializer: (v) => v,
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      await cache.evictExpired();

      expect(cache.containsKey('fresh'), isTrue);
      expect(box.get('stale'), isNull);
    });

    test('set serializes and get deserializes correctly', () async {
      const payload = {'id': 42, 'name': 'test'};
      await cache.set<String>(
        'json',
        '{"id":42,"name":"test"}',
        ttl: const Duration(minutes: 5),
        serializer: (v) => v,
      );

      final raw = cache.get<String>('json', deserializer: (s) => s);
      expect(raw, contains('"name":"test"'));
    });
  });
}
