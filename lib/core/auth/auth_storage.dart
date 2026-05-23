import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vibyuk/core/auth/models/token_model.dart';
import 'package:vibyuk/core/config/app_config.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/logging/app_logger.dart';

class AuthStorage {
  AuthStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _options = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  Future<void> saveTokens(TokenModel tokens) async {
    try {
      await _storage.write(
        key: AppConfig.accessTokenKey,
        value: tokens.accessToken,
        iOptions: _options,
        aOptions: _androidOptions,
      );
      await _storage.write(
        key: AppConfig.refreshTokenKey,
        value: tokens.refreshToken,
        iOptions: _options,
        aOptions: _androidOptions,
      );
      await _storage.write(
        key: '${AppConfig.accessTokenKey}_expiry',
        value: tokens.accessTokenExpiresAt.toIso8601String(),
        iOptions: _options,
        aOptions: _androidOptions,
      );
    } catch (e, st) {
      AppLogger.error('Failed to save tokens', error: e, stackTrace: st);
      throw StorageException(message: 'Failed to persist authentication tokens.');
    }
  }

  Future<TokenModel?> getTokens() async {
    try {
      final accessToken = await _storage.read(
        key: AppConfig.accessTokenKey,
        iOptions: _options,
        aOptions: _androidOptions,
      );
      final refreshToken = await _storage.read(
        key: AppConfig.refreshTokenKey,
        iOptions: _options,
        aOptions: _androidOptions,
      );
      final expiryStr = await _storage.read(
        key: '${AppConfig.accessTokenKey}_expiry',
        iOptions: _options,
        aOptions: _androidOptions,
      );

      if (accessToken == null || refreshToken == null || expiryStr == null) {
        return null;
      }

      return TokenModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiresAt: DateTime.parse(expiryStr),
      );
    } catch (e, st) {
      AppLogger.error('Failed to read tokens', error: e, stackTrace: st);
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(
        key: AppConfig.accessTokenKey,
        iOptions: _options,
        aOptions: _androidOptions,
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(
        key: AppConfig.refreshTokenKey,
        iOptions: _options,
        aOptions: _androidOptions,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      await _storage.write(
        key: AppConfig.userDataKey,
        value: jsonEncode(userData),
        iOptions: _options,
        aOptions: _androidOptions,
      );
    } catch (e, st) {
      AppLogger.error('Failed to save user data', error: e, stackTrace: st);
      throw StorageException(message: 'Failed to persist user data.');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final data = await _storage.read(
        key: AppConfig.userDataKey,
        iOptions: _options,
        aOptions: _androidOptions,
      );
      if (data == null) return null;
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll(
        iOptions: _options,
        aOptions: _androidOptions,
      );
    } catch (e, st) {
      AppLogger.error('Failed to clear storage', error: e, stackTrace: st);
      throw StorageException(message: 'Failed to clear authentication data.');
    }
  }

  Future<bool> hasValidSession() async {
    final tokens = await getTokens();
    if (tokens == null) return false;
    return tokens.refreshToken.isNotEmpty;
  }
}
