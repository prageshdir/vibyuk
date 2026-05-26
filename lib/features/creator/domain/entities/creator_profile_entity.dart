import 'package:equatable/equatable.dart';

enum OnboardingStep { basicInfo, portfolio, pricing, availability, done }

enum CreatorAvailabilityStatus { available, busy, unavailable }

class CreatorProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String displayName;
  final String? bio;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final List<String> categories;
  final List<String> skills;
  final List<String> languagesSpoken;
  final List<SocialLinkEntity> socialLinks;
  final String? location;
  final String? website;
  final double rating;
  final int reviewCount;
  final int completedBookings;
  final bool isVerified;
  final bool isActive;
  final CreatorAvailabilityStatus availabilityStatus;
  final OnboardingStep onboardingStep;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreatorProfileEntity({
    required this.id,
    required this.userId,
    required this.displayName,
    this.bio,
    this.profileImageUrl,
    this.coverImageUrl,
    required this.categories,
    required this.skills,
    this.languagesSpoken = const [],
    required this.socialLinks,
    this.location,
    this.website,
    required this.rating,
    required this.reviewCount,
    required this.completedBookings,
    required this.isVerified,
    required this.isActive,
    required this.availabilityStatus,
    required this.onboardingStep,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOnboardingComplete => onboardingStep == OnboardingStep.done;

  @override
  List<Object?> get props => [
        id,
        userId,
        displayName,
        bio,
        profileImageUrl,
        coverImageUrl,
        categories,
        skills,
        languagesSpoken,
        socialLinks,
        location,
        website,
        rating,
        reviewCount,
        completedBookings,
        isVerified,
        isActive,
        availabilityStatus,
        onboardingStep,
        createdAt,
        updatedAt,
      ];
}

class SocialLinkEntity extends Equatable {
  final String platform;
  final String url;
  final int? followerCount;

  const SocialLinkEntity({
    required this.platform,
    required this.url,
    this.followerCount,
  });

  @override
  List<Object?> get props => [platform, url, followerCount];
}
