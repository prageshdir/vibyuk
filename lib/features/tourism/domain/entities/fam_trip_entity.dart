import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';

enum FamTripStatus { upcoming, inProgress, completed, cancelled }

class FamTripDayEntity extends Equatable {
  const FamTripDayEntity({
    required this.day,
    required this.title,
    required this.activities,
    this.accommodation,
    this.meals = const [],
  });

  final int day;
  final String title;
  final List<String> activities;
  final String? accommodation;
  final List<String> meals;

  @override
  List<Object?> get props => [day, title, activities, accommodation, meals];
}

class FamTripEntity extends Equatable {
  const FamTripEntity({
    required this.id,
    required this.title,
    required this.destinationId,
    required this.description,
    required this.departureDate,
    required this.returnDate,
    required this.capacity,
    required this.enrolledCount,
    required this.status,
    required this.itinerary,
    required this.requiredFollowerCount,
    required this.requiredNiches,
    required this.perks,
    required this.organizerName,
    this.coverImageUrl,
    this.destination,
  });

  final String id;
  final String title;
  final String destinationId;
  final TourismDestinationEntity? destination;
  final String description;
  final String? coverImageUrl;
  final DateTime departureDate;
  final DateTime returnDate;
  final int capacity;
  final int enrolledCount;
  final FamTripStatus status;
  final List<FamTripDayEntity> itinerary;
  final int requiredFollowerCount;
  final List<String> requiredNiches;
  final List<String> perks;
  final String organizerName;

  int get durationDays =>
      returnDate.difference(departureDate).inDays + 1;

  int get spotsRemaining => (capacity - enrolledCount).clamp(0, capacity);

  double get fillRate =>
      capacity > 0 ? (enrolledCount / capacity).clamp(0.0, 1.0) : 0.0;

  bool get isOpen =>
      status == FamTripStatus.upcoming && spotsRemaining > 0;

  int get daysUntilDeparture =>
      departureDate.difference(DateTime.now()).inDays.clamp(0, 99999);

  @override
  List<Object?> get props => [
        id,
        title,
        destinationId,
        destination,
        description,
        coverImageUrl,
        departureDate,
        returnDate,
        capacity,
        enrolledCount,
        status,
        itinerary,
        requiredFollowerCount,
        requiredNiches,
        perks,
        organizerName,
      ];
}
