import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/features/profile/data/models/notification_settings_model.dart';
import 'package:vibyuk/features/profile/data/models/profile_model.dart';

abstract interface class ProfileLocalDataSource {
  Future<void> saveProfile(ProfileModel profile);
  Future<ProfileModel?> getProfile();
  Future<void> clearProfile();
  Future<void> saveNotificationSettings(NotificationSettingsModel settings);
  Future<NotificationSettingsModel?> getNotificationSettings();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  ProfileLocalDataSourceImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const _profileKey = 'vibyuk_profile_cache';
  static const _notifSettingsKey = 'vibyuk_notif_settings';

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  @override
  Future<void> saveProfile(ProfileModel profile) async {
    try {
      await _storage.write(
        key: _profileKey,
        value: jsonEncode(profile.toJson()),
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
    } catch (e, st) {
      AppLogger.error('Failed to cache profile', error: e, stackTrace: st);
      throw StorageException(message: 'Failed to cache profile data.');
    }
  }

  @override
  Future<ProfileModel?> getProfile() async {
    try {
      final raw = await _storage.read(
        key: _profileKey,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
      if (raw == null) return null;
      return ProfileModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e, st) {
      AppLogger.error('Failed to read cached profile', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<void> clearProfile() async {
    try {
      await _storage.delete(
        key: _profileKey,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
    } catch (e, st) {
      AppLogger.error('Failed to clear cached profile', error: e, stackTrace: st);
    }
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettingsModel settings) async {
    try {
      await _storage.write(
        key: _notifSettingsKey,
        value: jsonEncode(settings.toJson()),
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
    } catch (e, st) {
      AppLogger.error('Failed to save notification settings', error: e, stackTrace: st);
    }
  }

  @override
  Future<NotificationSettingsModel?> getNotificationSettings() async {
    try {
      final raw = await _storage.read(
        key: _notifSettingsKey,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
      if (raw == null) return null;
      return NotificationSettingsModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}
