import 'package:vibyuk/features/creator/domain/entities/creator_profile_entity.dart';

class CreatorProfileModel {
  const CreatorProfileModel({
    required this.id,
    required this.userId,
    required this.displayName,
    this.bio,
    this.profileImageUrl,
    this.coverImageUrl,
    this.categories = const [],
    this.skills = const [],
    this.socialLinks = const [],
    this.location,
    this.website,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.completedBookings = 0,
    this.isVerified = false,
    this.isActive = true,
    required this.availabilityStatus,
    required this.onboardingStep,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String displayName;
  final String? bio;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final List<String> categories;
  final List<String> skills;
  final List<SocialLinkModel> socialLinks;
  final String? location;
  final String? website;
  final double rating;
  final int reviewCount;
  final int completedBookings;
  final bool isVerified;
  final bool isActive;
  final String availabilityStatus;
  final String onboardingStep;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CreatorProfileModel.fromJson(Map<String, dynamic> json) =>
      CreatorProfileModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        displayName: json['display_name'] as String? ?? '',
        bio: json['bio'] as String?,
        profileImageUrl: json['profile_image_url'] as String?,
        coverImageUrl: json['cover_image_url'] as String?,
        categories: (json['categories'] as List?)?.cast<String>() ?? [],
        skills: (json['skills'] as List?)?.cast<String>() ?? [],
        socialLinks: (json['social_links'] as List?)
                ?.map((e) =>
                    SocialLinkModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        location: json['location'] as String?,
        website: json['website'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: json['review_count'] as int? ?? 0,
        completedBookings: json['completed_bookings'] as int? ?? 0,
        isVerified: json['is_verified'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        availabilityStatus: json['availability_status'] as String? ?? 'available',
        onboardingStep: json['onboarding_step'] as String? ?? 'basicInfo',
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  CreatorProfileEntity toEntity() => CreatorProfileEntity(
        id: id,
        userId: userId,
        displayName: displayName,
        bio: bio,
        profileImageUrl: profileImageUrl,
        coverImageUrl: coverImageUrl,
        categories: categories,
        skills: skills,
        socialLinks: socialLinks.map((e) => e.toEntity()).toList(),
        location: location,
        website: website,
        rating: rating,
        reviewCount: reviewCount,
        completedBookings: completedBookings,
        isVerified: isVerified,
        isActive: isActive,
        availabilityStatus: _parseAvailabilityStatus(availabilityStatus),
        onboardingStep: _parseOnboardingStep(onboardingStep),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static CreatorAvailabilityStatus _parseAvailabilityStatus(String v) =>
      CreatorAvailabilityStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => CreatorAvailabilityStatus.available,
      );

  static OnboardingStep _parseOnboardingStep(String v) =>
      OnboardingStep.values.firstWhere(
        (e) => e.name == v,
        orElse: () => OnboardingStep.basicInfo,
      );
}

class SocialLinkModel {
  const SocialLinkModel({
    required this.platform,
    required this.url,
    this.followerCount,
  });

  final String platform;
  final String url;
  final int? followerCount;

  factory SocialLinkModel.fromJson(Map<String, dynamic> json) =>
      SocialLinkModel(
        platform: json['platform'] as String,
        url: json['url'] as String,
        followerCount: json['follower_count'] as int?,
      );

  SocialLinkEntity toEntity() =>
      SocialLinkEntity(platform: platform, url: url, followerCount: followerCount);
}
