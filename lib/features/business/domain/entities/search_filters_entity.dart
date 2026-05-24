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

  bool get isEmpty =>
      categories.isEmpty &&
      minRate == null &&
      maxRate == null &&
      location == null &&
      minRating == null &&
      !isVerifiedOnly &&
      sortBy == SortBy.relevant &&
      availability == null;

  int get activeFilterCount {
    var count = 0;
    if (categories.isNotEmpty) count++;
    if (minRate != null || maxRate != null) count++;
    if (location != null) count++;
    if (minRating != null) count++;
    if (isVerifiedOnly) count++;
    if (availability != null) count++;
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
      );

  SearchFiltersEntity clearRateRange() => copyWith(minRate: null, maxRate: null);

  @override
  List<Object?> get props => [
        categories, minRate, maxRate, location, minRating,
        isVerifiedOnly, sortBy, availability,
      ];
}
