import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';

part 'tourism_destination_dto.freezed.dart';
part 'tourism_destination_dto.g.dart';

@freezed
class TourismDestinationDto with _$TourismDestinationDto {
  const factory TourismDestinationDto({
    required String id,
    required String name,
    required String country,
    required String region,
    required String description,
    @JsonKey(name: 'hero_image_url') String? heroImageUrl,
    @JsonKey(name: 'gallery_urls', defaultValue: []) required List<String> galleryUrls,
    required String category,
    @Default(0.0) double rating,
    @JsonKey(name: 'review_count', defaultValue: 0) required int reviewCount,
    @JsonKey(defaultValue: []) required List<String> highlights,
    @JsonKey(name: 'best_time_to_visit') String? bestTimeToVisit,
    @JsonKey(name: 'average_cost_per_day', defaultValue: 0.0) required double averageCostPerDay,
    @Default('USD') String currency,
    @JsonKey(name: 'is_featured', defaultValue: false) required bool isFeatured,
    @JsonKey(defaultValue: []) required List<String> tags,
    @JsonKey(name: 'creator_count', defaultValue: 0) required int creatorCount,
    @JsonKey(name: 'campaign_count', defaultValue: 0) required int campaignCount,
  }) = _TourismDestinationDto;

  factory TourismDestinationDto.fromJson(Map<String, dynamic> json) =>
      _$TourismDestinationDtoFromJson(json);

  factory TourismDestinationDto.fromEntity(TourismDestinationEntity entity) =>
      TourismDestinationDto(
        id: entity.id,
        name: entity.name,
        country: entity.country,
        region: entity.region,
        description: entity.description,
        heroImageUrl: entity.heroImageUrl,
        galleryUrls: entity.galleryUrls,
        category: entity.category,
        rating: entity.rating,
        reviewCount: entity.reviewCount,
        highlights: entity.highlights,
        bestTimeToVisit: entity.bestTimeToVisit,
        averageCostPerDay: entity.averageCostPerDay,
        currency: entity.currency,
        isFeatured: entity.isFeatured,
        tags: entity.tags,
        creatorCount: entity.creatorCount,
        campaignCount: entity.campaignCount,
      );
}

extension TourismDestinationDtoX on TourismDestinationDto {
  TourismDestinationEntity toEntity() => TourismDestinationEntity(
        id: id,
        name: name,
        country: country,
        region: region,
        description: description,
        heroImageUrl: heroImageUrl,
        galleryUrls: galleryUrls,
        category: category,
        rating: rating,
        reviewCount: reviewCount,
        highlights: highlights,
        bestTimeToVisit: bestTimeToVisit,
        averageCostPerDay: averageCostPerDay,
        currency: currency,
        isFeatured: isFeatured,
        tags: tags,
        creatorCount: creatorCount,
        campaignCount: campaignCount,
      );
}
