import 'dart:io';

import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/features/profile/data/dtos/change_password_dto.dart';
import 'package:vibyuk/features/profile/data/dtos/notification_settings_dto.dart';
import 'package:vibyuk/features/profile/data/dtos/update_profile_dto.dart';
import 'package:vibyuk/features/profile/data/models/notification_settings_model.dart';
import 'package:vibyuk/features/profile/data/models/profile_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ProfileModel> getMyProfile();
  Future<ProfileModel> getUserProfile(String userId);
  Future<ProfileModel> updateProfile(UpdateProfileDto dto);
  Future<String> uploadAvatar(String filePath);
  Future<void> changePassword(ChangePasswordDto dto);
  Future<void> deleteAccount({required String password});
  Future<NotificationSettingsModel> getNotificationSettings();
  Future<NotificationSettingsModel> updateNotificationSettings(NotificationSettingsDto dto);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ProfileModel> getMyProfile() async {
    final response = await _dio.get(ApiEndpoints.me);
    return ProfileModel.fromJson(_data(response));
  }

  @override
  Future<ProfileModel> getUserProfile(String userId) async {
    final response = await _dio.get(ApiEndpoints.userProfile(userId));
    return ProfileModel.fromJson(_data(response));
  }

  @override
  Future<ProfileModel> updateProfile(UpdateProfileDto dto) async {
    final response = await _dio.patch(
      ApiEndpoints.updateProfile,
      data: dto.toJson(),
    );
    return ProfileModel.fromJson(_data(response));
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw const StorageException(message: 'Image file not found.');
    }

    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        filePath,
        filename: 'avatar.jpg',
      ),
    });

    final response = await _dio.post(
      ApiEndpoints.uploadAvatar,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = _data(response);
    final url = data['avatar_url'] as String?;
    if (url == null) {
      throw const ParseException(message: 'Avatar URL missing from response.');
    }
    return url;
  }

  @override
  Future<void> changePassword(ChangePasswordDto dto) async {
    await _dio.put(
      ApiEndpoints.changePassword,
      data: dto.toJson(),
    );
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    await _dio.delete(
      ApiEndpoints.deleteAccount,
      data: {'password': password},
    );
  }

  @override
  Future<NotificationSettingsModel> getNotificationSettings() async {
    final response = await _dio.get(ApiEndpoints.notificationSettings);
    return NotificationSettingsModel.fromJson(_data(response));
  }

  @override
  Future<NotificationSettingsModel> updateNotificationSettings(
    NotificationSettingsDto dto,
  ) async {
    final response = await _dio.put(
      ApiEndpoints.notificationSettings,
      data: dto.toJson(),
    );
    return NotificationSettingsModel.fromJson(_data(response));
  }

  Map<String, dynamic> _data(Response response) {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw ParseException(message: 'Unexpected response format: ${body.runtimeType}');
    }
    if (body.containsKey('data') && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return body;
  }
}
