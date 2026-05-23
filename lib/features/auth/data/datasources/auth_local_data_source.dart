import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vibyuk/core/config/app_config.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/features/auth/data/models/user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await _storage.write(
        key: AppConfig.userDataKey,
        value: jsonEncode(user.toJson()),
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
    } catch (e, st) {
      AppLogger.error('Failed to save user locally', error: e, stackTrace: st);
      throw StorageException(message: 'Failed to cache user data.');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final raw = await _storage.read(
        key: AppConfig.userDataKey,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
      if (raw == null) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e, st) {
      AppLogger.error('Failed to read cached user', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await _storage.delete(
        key: AppConfig.userDataKey,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
    } catch (e, st) {
      AppLogger.error('Failed to clear cached user', error: e, stackTrace: st);
    }
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: AppConfig.biometricEnabledKey,
        value: enabled.toString(),
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
    } catch (e, st) {
      AppLogger.error('Failed to save biometric preference', error: e, stackTrace: st);
      throw StorageException(message: 'Failed to save biometric preference.');
    }
  }

  @override
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(
        key: AppConfig.biometricEnabledKey,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
      return value == 'true';
    } catch (e) {
      return false;
    }
  }
}
