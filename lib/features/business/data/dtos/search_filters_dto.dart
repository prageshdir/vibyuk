import 'package:vibyuk/features/business/domain/entities/search_filters_entity.dart';

class SearchFiltersDto {
  const SearchFiltersDto(this._filters);
  final SearchFiltersEntity _filters;

  Map<String, dynamic> toQueryParams() {
    final map = <String, dynamic>{};
    if (_filters.categories.isNotEmpty) {
      map['categories'] = _filters.categories.join(',');
    }
    if (_filters.minRate != null) map['min_rate'] = _filters.minRate;
    if (_filters.maxRate != null) map['max_rate'] = _filters.maxRate;
    if (_filters.location != null) map['location'] = _filters.location;
    if (_filters.minRating != null) map['min_rating'] = _filters.minRating;
    if (_filters.isVerifiedOnly) map['is_verified'] = true;
    if (_filters.availability != null) map['availability'] = _filters.availability;
    if (_filters.sortBy != SortBy.relevant) {
      map['sort'] = _filters.sortBy.apiValue;
    }
    return map;
  }
}
