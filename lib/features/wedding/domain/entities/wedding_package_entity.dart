import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_vendor_entity.dart';

class WeddingPackageEntity extends Equatable {
  const WeddingPackageEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.includedVendorIds,
    required this.totalPrice,
    required this.isCustom,
    this.includedVendors = const [],
    this.discountedPrice,
    this.weddingId,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final String? imageUrl;
  final List<String> includedVendorIds;
  final List<WeddingVendorEntity> includedVendors;
  final double totalPrice;
  final double? discountedPrice;
  final bool isCustom;
  final String? weddingId;

  double get effectivePrice => discountedPrice ?? totalPrice;

  double get savingsAmount =>
      discountedPrice != null ? totalPrice - discountedPrice! : 0.0;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        imageUrl,
        includedVendorIds,
        includedVendors,
        totalPrice,
        discountedPrice,
        isCustom,
        weddingId,
      ];
}
