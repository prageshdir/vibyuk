import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_venue_entity.dart';

part 'wedding_venue_dto.freezed.dart';
part 'wedding_venue_dto.g.dart';

@freezed
class WeddingVenueDto with _$WeddingVenueDto {
  const factory WeddingVenueDto({
    required String id,
    required String name,
    required String description,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'gallery_urls') @Default([]) List<String> galleryUrls,
    required String location,
    required int capacity,
    @JsonKey(name: 'price_per_head') required double pricePerHead,
    @JsonKey(name: 'minimum_guests') @Default(0) int minimumGuests,
    @Default([]) List<String> amenities,
    @Default(0.0) double rating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @JsonKey(name: 'is_available') @Default(true) bool isAvailable,
  }) = _WeddingVenueDto;

  factory WeddingVenueDto.fromJson(Map<String, dynamic> json) =>
      _$WeddingVenueDtoFromJson(json);

  factory WeddingVenueDto.fromEntity(WeddingVenueEntity e) => WeddingVenueDto(
        id: e.id,
        name: e.name,
        description: e.description,
        imageUrl: e.imageUrl,
        galleryUrls: e.galleryUrls,
        location: e.location,
        capacity: e.capacity,
        pricePerHead: e.pricePerHead,
        minimumGuests: e.minimumGuests,
        amenities: e.amenities,
        rating: e.rating,
        reviewCount: e.reviewCount,
        isAvailable: e.isAvailable,
      );
}

extension WeddingVenueDtoX on WeddingVenueDto {
  WeddingVenueEntity toEntity() => WeddingVenueEntity(
        id: id,
        name: name,
        description: description,
        imageUrl: imageUrl,
        galleryUrls: galleryUrls,
        location: location,
        capacity: capacity,
        pricePerHead: pricePerHead,
        minimumGuests: minimumGuests,
        amenities: amenities,
        rating: rating,
        reviewCount: reviewCount,
        isAvailable: isAvailable,
      );
}
