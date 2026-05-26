import 'package:equatable/equatable.dart';

class CreatorEntity extends Equatable {
  const CreatorEntity({
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
    this.languagesSpoken = const [],
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
  final List<String> languagesSpoken;
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

  String get rateDisplay {
    if (hourlyRateFrom == null) return 'Rate on request';
    if (hourlyRateTo == null) return '₹${hourlyRateFrom!.toStringAsFixed(0)}/hr';
    return '₹${hourlyRateFrom!.toStringAsFixed(0)}–${hourlyRateTo!.toStringAsFixed(0)}/hr';
  }

  bool get isAvailable => availability == 'available' || availability == null;

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  CreatorEntity copyWith({bool? isSaved}) => CreatorEntity(
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
        languagesSpoken: languagesSpoken,
        hourlyRateFrom: hourlyRateFrom,
        hourlyRateTo: hourlyRateTo,
        rating: rating,
        reviewsCount: reviewsCount,
        totalBookings: totalBookings,
        isVerified: isVerified,
        isSaved: isSaved ?? this.isSaved,
        followersCount: followersCount,
        availability: availability,
        instagram: instagram,
        twitter: twitter,
        tiktok: tiktok,
      );

  @override
  List<Object?> get props => [
        id, userId, displayName, bio, location, avatarUrl, coverImageUrl,
        categories, serviceTypes, skills, languagesSpoken, hourlyRateFrom,
        hourlyRateTo, rating, reviewsCount, totalBookings, isVerified, isSaved,
        followersCount, availability, instagram, twitter, tiktok,
      ];
}
