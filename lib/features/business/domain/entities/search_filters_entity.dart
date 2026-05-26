import 'package:equatable/equatable.dart';

enum SortBy { relevant, ratingDesc, priceAsc, priceDesc, newest }

extension SortByX on SortBy {
  String get label => switch (this) {
        SortBy.relevant => 'Most Relevant',
        SortBy.ratingDesc => 'Highest Rated',
        SortBy.priceAsc => 'Price: Low to High',
        SortBy.priceDesc => 'Price: High to Low',
        SortBy.newest => 'Newest',
      };

  String get apiValue => switch (this) {
        SortBy.relevant => 'relevant',
        SortBy.ratingDesc => 'rating_desc',
        SortBy.priceAsc => 'price_asc',
        SortBy.priceDesc => 'price_desc',
        SortBy.newest => 'newest',
      };
}

enum InfluencerPlatform { instagram, youtube, tiktok, twitter }

extension InfluencerPlatformX on InfluencerPlatform {
  String get label => switch (this) {
        InfluencerPlatform.instagram => 'Instagram',
        InfluencerPlatform.youtube => 'YouTube',
        InfluencerPlatform.tiktok => 'TikTok',
        InfluencerPlatform.twitter => 'Twitter / X',
      };

  String get apiValue => switch (this) {
        InfluencerPlatform.instagram => 'instagram',
        InfluencerPlatform.youtube => 'youtube',
        InfluencerPlatform.tiktok => 'tiktok',
        InfluencerPlatform.twitter => 'twitter',
      };
}

class SearchFiltersEntity extends Equatable {
  const SearchFiltersEntity({
    this.categories = const [],
    this.minRate,
    this.maxRate,
    this.location,
    this.minRating,
    this.isVerifiedOnly = false,
    this.sortBy = SortBy.relevant,
    this.availability,
    this.languages = const [],
    this.platforms = const [],
    this.minFollowers,
    this.maxFollowers,
    this.minEngagementRate,
  });

  const SearchFiltersEntity.empty() : this();

  final List<String> categories;
  final double? minRate;
  final double? maxRate;
  final String? location;
  final double? minRating;
  final bool isVerifiedOnly;
  final SortBy sortBy;
  final String? availability;

  // Influencer-specific filters (SRS §Influencer Marketing)
  final List<String> languages;
  final List<InfluencerPlatform> platforms;
  final int? minFollowers;
  final int? maxFollowers;
  final double? minEngagementRate;

  bool get isEmpty =>
      categories.isEmpty &&
      minRate == null &&
      maxRate == null &&
      location == null &&
      minRating == null &&
      !isVerifiedOnly &&
      sortBy == SortBy.relevant &&
      availability == null &&
      languages.isEmpty &&
      platforms.isEmpty &&
      minFollowers == null &&
      maxFollowers == null &&
      minEngagementRate == null;

  int get activeFilterCount {
    var count = 0;
    if (categories.isNotEmpty) count++;
    if (minRate != null || maxRate != null) count++;
    if (location != null) count++;
    if (minRating != null) count++;
    if (isVerifiedOnly) count++;
    if (availability != null) count++;
    if (languages.isNotEmpty) count++;
    if (platforms.isNotEmpty) count++;
    if (minFollowers != null || maxFollowers != null) count++;
    if (minEngagementRate != null) count++;
    return count;
  }

  SearchFiltersEntity copyWith({
    List<String>? categories,
    double? minRate,
    double? maxRate,
    String? location,
    double? minRating,
    bool? isVerifiedOnly,
    SortBy? sortBy,
    String? availability,
    List<String>? languages,
    List<InfluencerPlatform>? platforms,
    int? minFollowers,
    int? maxFollowers,
    double? minEngagementRate,
  }) =>
      SearchFiltersEntity(
        categories: categories ?? this.categories,
        minRate: minRate ?? this.minRate,
        maxRate: maxRate ?? this.maxRate,
        location: location ?? this.location,
        minRating: minRating ?? this.minRating,
        isVerifiedOnly: isVerifiedOnly ?? this.isVerifiedOnly,
        sortBy: sortBy ?? this.sortBy,
        availability: availability ?? this.availability,
        languages: languages ?? this.languages,
        platforms: platforms ?? this.platforms,
        minFollowers: minFollowers ?? this.minFollowers,
        maxFollowers: maxFollowers ?? this.maxFollowers,
        minEngagementRate: minEngagementRate ?? this.minEngagementRate,
      );

  SearchFiltersEntity clearRateRange() => copyWith(minRate: null, maxRate: null);

  @override
  List<Object?> get props => [
        categories, minRate, maxRate, location, minRating,
        isVerifiedOnly, sortBy, availability,
        languages, platforms, minFollowers, maxFollowers, minEngagementRate,
      ];
}
