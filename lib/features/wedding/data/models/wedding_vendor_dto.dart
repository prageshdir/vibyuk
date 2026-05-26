import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_vendor_entity.dart';

part 'wedding_vendor_dto.freezed.dart';
part 'wedding_vendor_dto.g.dart';

@freezed
class WeddingVendorDto with _$WeddingVendorDto {
  const factory WeddingVendorDto({
    required String id,
    required String name,
    required String category,
    required String description,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'gallery_urls') @Default([]) List<String> galleryUrls,
    @Default(0.0) double rating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @JsonKey(name: 'min_price') required double minPrice,
    @JsonKey(name: 'max_price') required double maxPrice,
    required String location,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'is_available') @Default(true) bool isAvailable,
  }) = _WeddingVendorDto;

  factory WeddingVendorDto.fromJson(Map<String, dynamic> json) =>
      _$WeddingVendorDtoFromJson(json);

  factory WeddingVendorDto.fromEntity(WeddingVendorEntity e) => WeddingVendorDto(
        id: e.id,
        name: e.name,
        category: e.category,
        description: e.description,
        imageUrl: e.imageUrl,
        galleryUrls: e.galleryUrls,
        rating: e.rating,
        reviewCount: e.reviewCount,
        minPrice: e.minPrice,
        maxPrice: e.maxPrice,
        location: e.location,
        isVerified: e.isVerified,
        isAvailable: e.isAvailable,
      );
}

extension WeddingVendorDtoX on WeddingVendorDto {
  WeddingVendorEntity toEntity() => WeddingVendorEntity(
        id: id,
        name: name,
        category: category,
        description: description,
        imageUrl: imageUrl,
        galleryUrls: galleryUrls,
        rating: rating,
        reviewCount: reviewCount,
        minPrice: minPrice,
        maxPrice: maxPrice,
        location: location,
        isVerified: isVerified,
        isAvailable: isAvailable,
      );
}
