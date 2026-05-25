import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class DiscoveryLocalDataSource {
  Future<List<String>> getRecentSearches();
  Future<void> saveRecentSearch(String query);
  Future<void> clearRecentSearches();
}

class DiscoveryLocalDataSourceImpl implements DiscoveryLocalDataSource {
  DiscoveryLocalDataSourceImpl(this._storage);
  final FlutterSecureStorage _storage;

  static const _recentSearchesKey = 'vibyuk_recent_searches';
  static const _maxRecentSearches = 10;

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  @override
  Future<List<String>> getRecentSearches() async {
    try {
      final raw = await _storage.read(
        key: _recentSearchesKey,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list.cast<String>();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveRecentSearch(String query) async {
    final current = await getRecentSearches();
    final updated = [query, ...current.where((q) => q != query)]
        .take(_maxRecentSearches)
        .toList();
    await _storage.write(
      key: _recentSearchesKey,
      value: jsonEncode(updated),
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
  }

  @override
  Future<void> clearRecentSearches() async {
    await _storage.delete(
      key: _recentSearchesKey,
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
  }
}
