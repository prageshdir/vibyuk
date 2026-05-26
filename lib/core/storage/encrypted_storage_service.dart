import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/logging/app_logger.dart';

/// Versioned, typed wrapper over [FlutterSecureStorage].
///
/// Key versioning: every stored key is prefixed with the current schema version
/// (`_v{version}_`). On schema bump, old data is migrated or evicted lazily.
/// This prevents breaking reads after upgrades without wiping the keychain.
class EncryptedStorageService {
  EncryptedStorageService(this._storage, {int schemaVersion = 1})
      : _version = schemaVersion;

  final FlutterSecureStorage _storage;
  final int _version;

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  String _key(String key) => 'v${_version}_$key';

  // ── String ───────────────────────────────────────────────────────────────

  Future<void> writeString(String key, String value) async {
    try {
      await _storage.write(
        key: _key(key),
        value: value,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
    } catch (e, st) {
      AppLogger.error('EncryptedStorage.writeString failed: $key', error: e, stackTrace: st);
      throw StorageException(message: 'Failed to write secure value for key: $key');
    }
  }

  Future<String?> readString(String key) async {
    try {
      return await _storage.read(
        key: _key(key),
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
    } catch (e, st) {
      AppLogger.error('EncryptedStorage.readString failed: $key', error: e, stackTrace: st);
      return null;
    }
  }

  // ── JSON object ───────────────────────────────────────────────────────────

  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    await writeString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> readJson(String key) async {
    final raw = await readString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.warning('EncryptedStorage.readJson parse error: $key', error: e);
      await delete(key);
      return null;
    }
  }

  // ── Boolean ──────────────────────────────────────────────────────────────

  Future<void> writeBool(String key, bool value) async {
    await writeString(key, value ? '1' : '0');
  }

  Future<bool?> readBool(String key) async {
    final raw = await readString(key);
    if (raw == null) return null;
    return raw == '1';
  }

  // ── Integer ───────────────────────────────────────────────────────────────

  Future<void> writeInt(String key, int value) async {
    await writeString(key, value.toString());
  }

  Future<int?> readInt(String key) async {
    final raw = await readString(key);
    return raw == null ? null : int.tryParse(raw);
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> delete(String key) async {
    try {
      await _storage.delete(
        key: _key(key),
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
    } catch (e, st) {
      AppLogger.error('EncryptedStorage.delete failed: $key', error: e, stackTrace: st);
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll(
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
    } catch (e, st) {
      AppLogger.error('EncryptedStorage.clearAll failed', error: e, stackTrace: st);
      throw StorageException(message: 'Failed to clear secure storage.');
    }
  }

  /// Evicts all keys belonging to an older schema version.
  /// Call during startup after bumping [schemaVersion].
  Future<void> evictOldVersions({required int previousVersion}) async {
    try {
      final all = await _storage.readAll(
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
      final staleKeys = all.keys
          .where((k) => k.startsWith('v${previousVersion}_'))
          .toList();
      for (final k in staleKeys) {
        await _storage.delete(key: k, iOptions: _iosOptions, aOptions: _androidOptions);
      }
      AppLogger.info('EncryptedStorage: evicted ${staleKeys.length} v$previousVersion keys');
    } catch (e, st) {
      AppLogger.error('EncryptedStorage.evictOldVersions failed', error: e, stackTrace: st);
    }
  }

  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(
        key: _key(key),
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
    } catch (_) {
      return false;
    }
  }
}
