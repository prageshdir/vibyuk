import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_package_entity.dart';

part 'wedding_package_dto.freezed.dart';
part 'wedding_package_dto.g.dart';

@freezed
class WeddingPackageDto with _$WeddingPackageDto {
  const factory WeddingPackageDto({
    required String id,
    required String name,
    required String description,
    required String category,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'included_vendor_ids')
    @Default([])
    List<String> includedVendorIds,
    @JsonKey(name: 'total_price') required double totalPrice,
    @JsonKey(name: 'discounted_price') double? discountedPrice,
    @JsonKey(name: 'is_custom') @Default(false) bool isCustom,
    @JsonKey(name: 'wedding_id') String? weddingId,
  }) = _WeddingPackageDto;

  factory WeddingPackageDto.fromJson(Map<String, dynamic> json) =>
      _$WeddingPackageDtoFromJson(json);

  factory WeddingPackageDto.fromEntity(WeddingPackageEntity e) =>
      WeddingPackageDto(
        id: e.id,
        name: e.name,
        description: e.description,
        category: e.category,
        imageUrl: e.imageUrl,
        includedVendorIds: e.includedVendorIds,
        totalPrice: e.totalPrice,
        discountedPrice: e.discountedPrice,
        isCustom: e.isCustom,
        weddingId: e.weddingId,
      );
}

extension WeddingPackageDtoX on WeddingPackageDto {
  WeddingPackageEntity toEntity() => WeddingPackageEntity(
        id: id,
        name: name,
        description: description,
        category: category,
        imageUrl: imageUrl,
        includedVendorIds: includedVendorIds,
        totalPrice: totalPrice,
        discountedPrice: discountedPrice,
        isCustom: isCustom,
        weddingId: weddingId,
      );
}
