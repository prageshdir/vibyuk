import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/profile/domain/entities/notification_settings_entity.dart';
import 'package:vibyuk/features/profile/domain/entities/profile_entity.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getMyProfile();

  Future<Either<Failure, ProfileEntity>> getUserProfile(String userId);

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
  });

  Future<Either<Failure, String>> uploadAvatar(String filePath);

  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  Future<Either<Failure, Unit>> deleteAccount({
    required String password,
  });

  Future<Either<Failure, NotificationSettingsEntity>> getNotificationSettings();

  Future<Either<Failure, NotificationSettingsEntity>> updateNotificationSettings(
    NotificationSettingsEntity settings,
  );

  Future<Either<Failure, ProfileEntity?>> getCachedProfile();

  Future<Either<Failure, Unit>> cacheProfile(ProfileEntity profile);
}
