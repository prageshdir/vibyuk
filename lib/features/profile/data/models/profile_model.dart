import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';
import 'package:vibyuk/features/profile/domain/entities/profile_entity.dart';
import 'package:vibyuk/features/auth/data/models/user_model.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class SocialLinksModel with _$SocialLinksModel {
  const SocialLinksModel._();

  const factory SocialLinksModel({
    String? instagram,
    String? twitter,
    String? tiktok,
    String? youtube,
    String? linkedin,
  }) = _SocialLinksModel;

  factory SocialLinksModel.fromJson(Map<String, dynamic> json) =>
      _$SocialLinksModelFromJson(json);

  SocialLinks toEntity() => SocialLinks(
        instagram: instagram,
        twitter: twitter,
        tiktok: tiktok,
        youtube: youtube,
        linkedin: linkedin,
      );
}

@freezed
class ProfileStatsModel with _$ProfileStatsModel {
  const ProfileStatsModel._();

  const factory ProfileStatsModel({
    @JsonKey(name: 'total_bookings') @Default(0) int totalBookings,
    double? rating,
    @JsonKey(name: 'reviews_count') @Default(0) int reviewsCount,
    @JsonKey(name: 'followers_count') @Default(0) int followersCount,
    @JsonKey(name: 'following_count') @Default(0) int followingCount,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
  }) = _ProfileStatsModel;

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileStatsModelFromJson(json);

  ProfileStats toEntity() => ProfileStats(
        totalBookings: totalBookings,
        rating: rating,
        reviewsCount: reviewsCount,
        followersCount: followersCount,
        followingCount: followingCount,
        isVerified: isVerified,
      );
}

@freezed
class CreatorInfoModel with _$CreatorInfoModel {
  const CreatorInfoModel._();

  const factory CreatorInfoModel({
    @JsonKey(name: 'service_types') @Default([]) List<String> serviceTypes,
    @Default([]) List<String> skills,
    @JsonKey(name: 'hourly_rate_from') double? hourlyRateFrom,
    @JsonKey(name: 'hourly_rate_to') double? hourlyRateTo,
    @JsonKey(name: 'response_rate') double? responseRate,
    String? availability,
  }) = _CreatorInfoModel;

  factory CreatorInfoModel.fromJson(Map<String, dynamic> json) =>
      _$CreatorInfoModelFromJson(json);

  CreatorInfo toEntity() => CreatorInfo(
        serviceTypes: serviceTypes,
        skills: skills,
        hourlyRateFrom: hourlyRateFrom,
        hourlyRateTo: hourlyRateTo,
        responseRate: responseRate,
        availability: availability,
      );
}

@freezed
class BusinessInfoModel with _$BusinessInfoModel {
  const BusinessInfoModel._();

  const factory BusinessInfoModel({
    @JsonKey(name: 'company_name') String? companyName,
    String? industry,
    @JsonKey(name: 'company_size') String? companySize,
  }) = _BusinessInfoModel;

  factory BusinessInfoModel.fromJson(Map<String, dynamic> json) =>
      _$BusinessInfoModelFromJson(json);

  BusinessInfo toEntity() => BusinessInfo(
        companyName: companyName,
        industry: industry,
        companySize: companySize,
      );
}

@freezed
class ProfileModel with _$ProfileModel {
  const ProfileModel._();

  const factory ProfileModel({
    required String id,
    required String email,
    String? phone,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    String? bio,
    String? location,
    String? website,
    String? role,
    @JsonKey(name: 'is_email_verified') @Default(false) bool isEmailVerified,
    @JsonKey(name: 'is_phone_verified') @Default(false) bool isPhoneVerified,
    @JsonKey(name: 'is_biometric_enabled') @Default(false) bool isBiometricEnabled,
    @JsonKey(name: 'social_links') SocialLinksModel? socialLinks,
    ProfileStatsModel? stats,
    @JsonKey(name: 'creator_info') CreatorInfoModel? creatorInfo,
    @JsonKey(name: 'business_info') BusinessInfoModel? businessInfo,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  ProfileEntity toEntity() {
    final userEntity = UserEntity(
      id: id,
      email: email,
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      avatarUrl: avatarUrl,
      role: UserRole.fromString(role),
      isEmailVerified: isEmailVerified,
      isPhoneVerified: isPhoneVerified,
      isBiometricEnabled: isBiometricEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    return ProfileEntity(
      user: userEntity,
      bio: bio,
      location: location,
      website: website,
      coverImageUrl: coverImageUrl,
      socialLinks: socialLinks?.toEntity() ?? const SocialLinks(),
      stats: stats?.toEntity() ?? const ProfileStats(),
      creatorInfo: creatorInfo?.toEntity(),
      businessInfo: businessInfo?.toEntity(),
    );
  }
}
