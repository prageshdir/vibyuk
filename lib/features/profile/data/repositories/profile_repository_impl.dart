import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:vibyuk/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:vibyuk/features/profile/data/dtos/change_password_dto.dart';
import 'package:vibyuk/features/profile/data/dtos/notification_settings_dto.dart';
import 'package:vibyuk/features/profile/data/dtos/update_profile_dto.dart';
import 'package:vibyuk/features/profile/data/models/notification_settings_model.dart';
import 'package:vibyuk/features/profile/domain/entities/notification_settings_entity.dart';
import 'package:vibyuk/features/profile/domain/entities/profile_entity.dart';
import 'package:vibyuk/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl extends BaseRepository implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
    required ProfileLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final ProfileRemoteDataSource _remote;
  final ProfileLocalDataSource _local;

  @override
  Future<Either<Failure, ProfileEntity>> getMyProfile() async {
    return safeCall(
      () async {
        final model = await _remote.getMyProfile();
        await _local.saveProfile(model);
        return model.toEntity();
      },
      context: 'ProfileRepository.getMyProfile',
    );
  }

  @override
  Future<Either<Failure, ProfileEntity>> getUserProfile(String userId) async {
    return safeCall(
      () async {
        final model = await _remote.getUserProfile(userId);
        return model.toEntity();
      },
      context: 'ProfileRepository.getUserProfile',
    );
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? location,
    String? website,
    String? instagram,
    String? twitter,
    String? tiktok,
    String? youtube,
    String? linkedin,
    String? companyName,
    String? industry,
    String? companySize,
    List<String>? serviceTypes,
    List<String>? skills,
    double? hourlyRateFrom,
    double? hourlyRateTo,
    String? availability,
  }) async {
    return safeCall(
      () async {
        final socialLinks = _buildSocialLinks(instagram, twitter, tiktok, youtube, linkedin);
        final creatorInfo = _buildCreatorInfo(serviceTypes, skills, hourlyRateFrom, hourlyRateTo, availability);
        final businessInfo = _buildBusinessInfo(companyName, industry, companySize);

        final dto = UpdateProfileDto(
          firstName: firstName,
          lastName: lastName,
          bio: bio,
          location: location,
          website: website,
          socialLinks: socialLinks,
          creatorInfo: creatorInfo,
          businessInfo: businessInfo,
        );

        final model = await _remote.updateProfile(dto);
        await _local.saveProfile(model);
        return model.toEntity();
      },
      context: 'ProfileRepository.updateProfile',
    );
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String filePath) async {
    return safeCall(
      () => _remote.uploadAvatar(filePath),
      context: 'ProfileRepository.uploadAvatar',
    );
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    return safeCall(
      () async {
        await _remote.changePassword(
          ChangePasswordDto(
            currentPassword: currentPassword,
            newPassword: newPassword,
            newPasswordConfirmation: newPasswordConfirmation,
          ),
        );
        return unit;
      },
      context: 'ProfileRepository.changePassword',
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount({required String password}) async {
    return safeCall(
      () async {
        await _remote.deleteAccount(password: password);
        await _local.clearProfile();
        return unit;
      },
      context: 'ProfileRepository.deleteAccount',
    );
  }

  @override
  Future<Either<Failure, NotificationSettingsEntity>> getNotificationSettings() async {
    return safeCall(
      () async {
        try {
          final model = await _remote.getNotificationSettings();
          await _local.saveNotificationSettings(model);
          return model.toEntity();
        } catch (_) {
          // Fall back to cached settings
          final cached = await _local.getNotificationSettings();
          if (cached != null) return cached.toEntity();
          return const NotificationSettingsEntity();
        }
      },
      context: 'ProfileRepository.getNotificationSettings',
    );
  }

  @override
  Future<Either<Failure, NotificationSettingsEntity>> updateNotificationSettings(
    NotificationSettingsEntity settings,
  ) async {
    return safeCall(
      () async {
        final dto = NotificationSettingsDto(settings: settings);
        final model = await _remote.updateNotificationSettings(dto);
        await _local.saveNotificationSettings(model);
        return model.toEntity();
      },
      context: 'ProfileRepository.updateNotificationSettings',
    );
  }

  @override
  Future<Either<Failure, ProfileEntity?>> getCachedProfile() async {
    return safeCall(
      () async {
        final model = await _local.getProfile();
        return model?.toEntity();
      },
      context: 'ProfileRepository.getCachedProfile',
    );
  }

  @override
  Future<Either<Failure, Unit>> cacheProfile(ProfileEntity profile) async {
    return const Right(unit); // caching handled internally after remote calls
  }

  Map<String, String?>? _buildSocialLinks(
    String? instagram, String? twitter, String? tiktok,
    String? youtube, String? linkedin,
  ) {
    if ([instagram, twitter, tiktok, youtube, linkedin].every((v) => v == null)) return null;
    return {
      if (instagram != null) 'instagram': instagram,
      if (twitter != null) 'twitter': twitter,
      if (tiktok != null) 'tiktok': tiktok,
      if (youtube != null) 'youtube': youtube,
      if (linkedin != null) 'linkedin': linkedin,
    };
  }

  Map<String, dynamic>? _buildCreatorInfo(
    List<String>? serviceTypes, List<String>? skills,
    double? rateFrom, double? rateTo, String? availability,
  ) {
    if ([serviceTypes, skills, rateFrom, rateTo, availability].every((v) => v == null)) return null;
    return {
      if (serviceTypes != null) 'service_types': serviceTypes,
      if (skills != null) 'skills': skills,
      if (rateFrom != null) 'hourly_rate_from': rateFrom,
      if (rateTo != null) 'hourly_rate_to': rateTo,
      if (availability != null) 'availability': availability,
    };
  }

  Map<String, dynamic>? _buildBusinessInfo(
    String? companyName, String? industry, String? companySize,
  ) {
    if ([companyName, industry, companySize].every((v) => v == null)) return null;
    return {
      if (companyName != null) 'company_name': companyName,
      if (industry != null) 'industry': industry,
      if (companySize != null) 'company_size': companySize,
    };
  }
}
