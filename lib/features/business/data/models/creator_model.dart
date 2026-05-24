import 'package:vibyuk/features/business/domain/entities/creator_entity.dart';

class CreatorModel {
  const CreatorModel({
    required this.id,
    this.userId,
    required this.displayName,
    this.bio,
    this.location,
    this.avatarUrl,
    this.coverImageUrl,
    this.categories = const [],
    this.serviceTypes = const [],
    this.skills = const [],
    this.hourlyRateFrom,
    this.hourlyRateTo,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.totalBookings = 0,
    this.isVerified = false,
    this.isSaved = false,
    this.followersCount = 0,
    this.availability,
    this.instagram,
    this.twitter,
    this.tiktok,
  });

  final String id;
  final String? userId;
  final String displayName;
  final String? bio;
  final String? location;
  final String? avatarUrl;
  final String? coverImageUrl;
  final List<String> categories;
  final List<String> serviceTypes;
  final List<String> skills;
  final double? hourlyRateFrom;
  final double? hourlyRateTo;
  final double rating;
  final int reviewsCount;
  final int totalBookings;
  final bool isVerified;
  final bool isSaved;
  final int followersCount;
  final String? availability;
  final String? instagram;
  final String? twitter;
  final String? tiktok;

  factory CreatorModel.fromJson(Map<String, dynamic> json) => CreatorModel(
        id: json['id'] as String,
        userId: json['user_id'] as String?,
        displayName: json['display_name'] as String? ?? json['name'] as String? ?? '',
        bio: json['bio'] as String?,
        location: json['location'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        coverImageUrl: json['cover_image_url'] as String?,
        categories: (json['categories'] as List?)?.cast<String>() ?? [],
        serviceTypes: (json['service_types'] as List?)?.cast<String>() ?? [],
        skills: (json['skills'] as List?)?.cast<String>() ?? [],
        hourlyRateFrom: (json['hourly_rate_from'] as num?)?.toDouble(),
        hourlyRateTo: (json['hourly_rate_to'] as num?)?.toDouble(),
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        reviewsCount: json['reviews_count'] as int? ?? 0,
        totalBookings: json['total_bookings'] as int? ?? 0,
        isVerified: json['is_verified'] as bool? ?? false,
        isSaved: json['is_saved'] as bool? ?? false,
        followersCount: json['followers_count'] as int? ?? 0,
        availability: json['availability'] as String?,
        instagram: json['instagram'] as String?,
        twitter: json['twitter'] as String?,
        tiktok: json['tiktok'] as String?,
      );

  CreatorEntity toEntity() => CreatorEntity(
        id: id,
        userId: userId,
        displayName: displayName,
        bio: bio,
        location: location,
        avatarUrl: avatarUrl,
        coverImageUrl: coverImageUrl,
        categories: categories,
        serviceTypes: serviceTypes,
        skills: skills,
        hourlyRateFrom: hourlyRateFrom,
        hourlyRateTo: hourlyRateTo,
        rating: rating,
        reviewsCount: reviewsCount,
        totalBookings: totalBookings,
        isVerified: isVerified,
        isSaved: isSaved,
        followersCount: followersCount,
        availability: availability,
        instagram: instagram,
        twitter: twitter,
        tiktok: tiktok,
      );
}
