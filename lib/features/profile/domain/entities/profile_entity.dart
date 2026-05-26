import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';

class SocialLinks extends Equatable {
  final String? instagram;
  final String? twitter;
  final String? tiktok;
  final String? youtube;
  final String? linkedin;

  const SocialLinks({
    this.instagram,
    this.twitter,
    this.tiktok,
    this.youtube,
    this.linkedin,
  });

  bool get isEmpty =>
      instagram == null &&
      twitter == null &&
      tiktok == null &&
      youtube == null &&
      linkedin == null;

  @override
  List<Object?> get props => [instagram, twitter, tiktok, youtube, linkedin];
}

class ProfileStats extends Equatable {
  final int totalBookings;
  final double? rating;
  final int reviewsCount;
  final int followersCount;
  final int followingCount;
  final bool isVerified;

  const ProfileStats({
    this.totalBookings = 0,
    this.rating,
    this.reviewsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isVerified = false,
  });

  String get ratingDisplay =>
      rating != null ? rating!.toStringAsFixed(1) : '—';

  @override
  List<Object?> get props => [
        totalBookings,
        rating,
        reviewsCount,
        followersCount,
        followingCount,
        isVerified,
      ];
}

class CreatorInfo extends Equatable {
  final List<String> serviceTypes;
  final List<String> skills;
  final double? hourlyRateFrom;
  final double? hourlyRateTo;
  final double? responseRate;
  final String? availability;

  const CreatorInfo({
    this.serviceTypes = const [],
    this.skills = const [],
    this.hourlyRateFrom,
    this.hourlyRateTo,
    this.responseRate,
    this.availability,
  });

  String get rateDisplay {
    if (hourlyRateFrom == null) return 'Rate on request';
    if (hourlyRateTo == null) return 'From ₹${hourlyRateFrom!.toInt()}/hr';
    return '₹${hourlyRateFrom!.toInt()} – ₹${hourlyRateTo!.toInt()}/hr';
  }

  String get responseRateDisplay =>
      responseRate != null ? '${(responseRate! * 100).toInt()}%' : '—';

  @override
  List<Object?> get props => [
        serviceTypes,
        skills,
        hourlyRateFrom,
        hourlyRateTo,
        responseRate,
        availability,
      ];
}

class BusinessInfo extends Equatable {
  final String? companyName;
  final String? industry;
  final String? companySize;

  const BusinessInfo({
    this.companyName,
    this.industry,
    this.companySize,
  });

  @override
  List<Object?> get props => [companyName, industry, companySize];
}

class ProfileEntity extends Equatable {
  final UserEntity user;
  final String? bio;
  final String? location;
  final String? website;
  final String? coverImageUrl;
  final SocialLinks socialLinks;
  final ProfileStats stats;
  final CreatorInfo? creatorInfo;
  final BusinessInfo? businessInfo;

  const ProfileEntity({
    required this.user,
    this.bio,
    this.location,
    this.website,
    this.coverImageUrl,
    this.socialLinks = const SocialLinks(),
    this.stats = const ProfileStats(),
    this.creatorInfo,
    this.businessInfo,
  });

  bool get isCreator => user.role == UserRole.creator;
  bool get isBusiness => user.role == UserRole.business;

  ProfileEntity copyWith({
    UserEntity? user,
    String? bio,
    String? location,
    String? website,
    String? coverImageUrl,
    SocialLinks? socialLinks,
    ProfileStats? stats,
    CreatorInfo? creatorInfo,
    BusinessInfo? businessInfo,
  }) {
    return ProfileEntity(
      user: user ?? this.user,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      website: website ?? this.website,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      socialLinks: socialLinks ?? this.socialLinks,
      stats: stats ?? this.stats,
      creatorInfo: creatorInfo ?? this.creatorInfo,
      businessInfo: businessInfo ?? this.businessInfo,
    );
  }

  @override
  List<Object?> get props => [
        user,
        bio,
        location,
        website,
        coverImageUrl,
        socialLinks,
        stats,
        creatorInfo,
        businessInfo,
      ];
}
