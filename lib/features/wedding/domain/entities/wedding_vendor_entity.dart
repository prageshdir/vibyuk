import 'package:equatable/equatable.dart';

class WeddingVendorEntity extends Equatable {
  const WeddingVendorEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.minPrice,
    required this.maxPrice,
    required this.location,
    required this.isVerified,
    required this.isAvailable,
    required this.galleryUrls,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final String? imageUrl;
  final List<String> galleryUrls;
  final double rating;
  final int reviewCount;
  final double minPrice;
  final double maxPrice;
  final String location;
  final bool isVerified;
  final bool isAvailable;

  String get priceRange => '₹${minPrice.toStringAsFixed(0)} – ₹${maxPrice.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        description,
        imageUrl,
        galleryUrls,
        rating,
        reviewCount,
        minPrice,
        maxPrice,
        location,
        isVerified,
        isAvailable,
      ];
}
