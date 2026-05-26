import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/storage/encrypted_storage_service.dart';

// ── In-memory FlutterSecureStorage fake ──────────────────────────────────────

class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final _store = <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store[key];

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store.remove(key);

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      Map<String, String>.from(_store);

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store.clear();

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store.containsKey(key);
}

void main() {
  late _FakeSecureStorage raw;
  late EncryptedStorageService storage;

  setUpAll(() => FlavorConfig.initialize(AppFlavor.dev));

  setUp(() {
    raw = _FakeSecureStorage();
    storage = EncryptedStorageService(raw, schemaVersion: 1);
  });

  group('EncryptedStorageService — key versioning', () {
    test('stored key is prefixed with v1_', () async {
      await storage.writeString('token', 'abc');
      expect(raw._store.containsKey('v1_token'), isTrue);
      expect(raw._store.containsKey('token'), isFalse);
    });

    test('readString retrieves via versioned key', () async {
      raw._store['v1_token'] = 'secret';
      final value = await storage.readString('token');
      expect(value, 'secret');
    });

    test('readString returns null for missing key', () async {
      expect(await storage.readString('missing'), isNull);
    });
  });

  group('EncryptedStorageService — typed I/O', () {
    test('writeString / readString round-trip', () async {
      await storage.writeString('key', 'hello world');
      expect(await storage.readString('key'), 'hello world');
    });

    test('writeJson / readJson round-trip', () async {
      await storage.writeJson('profile', {'id': '1', 'name': 'Alice'});
      final result = await storage.readJson('profile');
      expect(result, {'id': '1', 'name': 'Alice'});
    });

    test('readJson returns null for malformed JSON and deletes corrupt entry', () async {
      raw._store['v1_bad_json'] = 'not-json{{{';
      final result = await storage.readJson('bad_json');
      expect(result, isNull);
      expect(raw._store.containsKey('v1_bad_json'), isFalse);
    });

    test('writeBool true stores "1", readBool returns true', () async {
      await storage.writeBool('flag', true);
      expect(await storage.readBool('flag'), isTrue);
    });

    test('writeBool false stores "0", readBool returns false', () async {
      await storage.writeBool('flag', false);
      expect(await storage.readBool('flag'), isFalse);
    });

    test('readBool returns null for missing key', () async {
      expect(await storage.readBool('missing'), isNull);
    });

    test('writeInt / readInt round-trip', () async {
      await storage.writeInt('count', 42);
      expect(await storage.readInt('count'), 42);
    });

    test('readInt returns null for missing key', () async {
      expect(await storage.readInt('missing'), isNull);
    });
  });

  group('EncryptedStorageService — lifecycle', () {
    test('delete removes the versioned key', () async {
      await storage.writeString('toDelete', 'bye');
      await storage.delete('toDelete');
      expect(await storage.readString('toDelete'), isNull);
      expect(raw._store.containsKey('v1_toDelete'), isFalse);
    });

    test('clearAll removes all keys', () async {
      await storage.writeString('a', 'va');
      await storage.writeString('b', 'vb');
      await storage.clearAll();
      expect(await storage.readString('a'), isNull);
      expect(await storage.readString('b'), isNull);
    });

    test('containsKey returns true after write', () async {
      await storage.writeString('present', 'v');
      expect(await storage.containsKey('present'), isTrue);
    });

    test('containsKey returns false for missing key', () async {
      expect(await storage.containsKey('ghost'), isFalse);
    });
  });

  group('EncryptedStorageService — schema eviction', () {
    test('evictOldVersions removes keys with previous version prefix', () async {
      // Simulate v1 keys already present
      raw._store['v1_token'] = 'old_token';
      raw._store['v1_refresh'] = 'old_refresh';
      raw._store['v2_token'] = 'new_token'; // newer key, must be kept

      final v2Storage = EncryptedStorageService(raw, schemaVersion: 2);
      await v2Storage.evictOldVersions(previousVersion: 1);

      expect(raw._store.containsKey('v1_token'), isFalse);
      expect(raw._store.containsKey('v1_refresh'), isFalse);
      expect(raw._store.containsKey('v2_token'), isTrue);
    });

    test('evictOldVersions is a no-op when no old keys exist', () async {
      raw._store['v2_token'] = 'val';
      final v2Storage = EncryptedStorageService(raw, schemaVersion: 2);
      await v2Storage.evictOldVersions(previousVersion: 1);
      expect(raw._store.containsKey('v2_token'), isTrue);
    });
  });
}
