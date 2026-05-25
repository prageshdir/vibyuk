import 'package:equatable/equatable.dart';

class WeddingVenueEntity extends Equatable {
  const WeddingVenueEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.capacity,
    required this.pricePerHead,
    required this.minimumGuests,
    required this.amenities,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    required this.galleryUrls,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<String> galleryUrls;
  final String location;
  final int capacity;
  final double pricePerHead;
  final int minimumGuests;
  final List<String> amenities;
  final double rating;
  final int reviewCount;
  final bool isAvailable;

  double estimatedCost(int guests) => guests * pricePerHead;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        galleryUrls,
        location,
        capacity,
        pricePerHead,
        minimumGuests,
        amenities,
        rating,
        reviewCount,
        isAvailable,
      ];
}
