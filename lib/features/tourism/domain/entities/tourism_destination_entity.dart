import 'package:equatable/equatable.dart';

enum DestinationCategory {
  beach,
  mountain,
  city,
  cultural,
  adventure,
  wildlife,
  luxury,
  island,
}

class TourismDestinationEntity extends Equatable {
  const TourismDestinationEntity({
    required this.id,
    required this.name,
    required this.country,
    required this.region,
    required this.description,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.highlights,
    required this.bestTimeToVisit,
    required this.averageCostPerDay,
    required this.currency,
    required this.isFeatured,
    required this.tags,
    required this.creatorCount,
    required this.campaignCount,
    required this.galleryUrls,
    this.heroImageUrl,
  });

  final String id;
  final String name;
  final String country;
  final String region;
  final String description;
  final String? heroImageUrl;
  final List<String> galleryUrls;
  final String category;
  final double rating;
  final int reviewCount;
  final List<String> highlights;
  final String bestTimeToVisit;
  final double averageCostPerDay;
  final String currency;
  final bool isFeatured;
  final List<String> tags;
  final int creatorCount;
  final int campaignCount;

  String get fullLocation => '$name, $country';

  String get formattedCost =>
      '${currency} ${averageCostPerDay.toStringAsFixed(0)}/day';

  DestinationCategory get categoryEnum {
    try {
      return DestinationCategory.values.firstWhere(
        (e) => e.name == category,
        orElse: () => DestinationCategory.city,
      );
    } catch (_) {
      return DestinationCategory.city;
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        country,
        region,
        description,
        heroImageUrl,
        galleryUrls,
        category,
        rating,
        reviewCount,
        highlights,
        bestTimeToVisit,
        averageCostPerDay,
        currency,
        isFeatured,
        tags,
        creatorCount,
        campaignCount,
      ];
}
