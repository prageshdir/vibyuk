import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/tourism/domain/entities/fam_trip_entity.dart';

part 'fam_trip_dto.freezed.dart';
part 'fam_trip_dto.g.dart';

@freezed
class FamTripDayDto with _$FamTripDayDto {
  const factory FamTripDayDto({
    required int day,
    required String title,
    @JsonKey(defaultValue: []) required List<String> activities,
    String? accommodation,
    @JsonKey(defaultValue: []) required List<String> meals,
  }) = _FamTripDayDto;

  factory FamTripDayDto.fromJson(Map<String, dynamic> json) =>
      _$FamTripDayDtoFromJson(json);
}

extension FamTripDayDtoX on FamTripDayDto {
  FamTripDayEntity toEntity() => FamTripDayEntity(
        day: day,
        title: title,
        activities: activities,
        accommodation: accommodation,
        meals: meals,
      );
}

@freezed
class FamTripDto with _$FamTripDto {
  const factory FamTripDto({
    required String id,
    required String title,
    @JsonKey(name: 'destination_id') required String destinationId,
    required String description,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(name: 'departure_date') required String departureDate,
    @JsonKey(name: 'return_date') required String returnDate,
    @Default(0) int capacity,
    @JsonKey(name: 'enrolled_count', defaultValue: 0) required int enrolledCount,
    required String status,
    @JsonKey(defaultValue: []) required List<FamTripDayDto> itinerary,
    @JsonKey(name: 'required_follower_count', defaultValue: 0) required int requiredFollowerCount,
    @JsonKey(name: 'required_niches', defaultValue: []) required List<String> requiredNiches,
    @JsonKey(defaultValue: []) required List<String> perks,
    @JsonKey(name: 'organizer_name', defaultValue: '') required String organizerName,
  }) = _FamTripDto;

  factory FamTripDto.fromJson(Map<String, dynamic> json) =>
      _$FamTripDtoFromJson(json);

  factory FamTripDto.fromEntity(FamTripEntity entity) => FamTripDto(
        id: entity.id,
        title: entity.title,
        destinationId: entity.destinationId,
        description: entity.description,
        coverImageUrl: entity.coverImageUrl,
        departureDate: entity.departureDate.toIso8601String(),
        returnDate: entity.returnDate.toIso8601String(),
        capacity: entity.capacity,
        enrolledCount: entity.enrolledCount,
        status: entity.status.name,
        itinerary: entity.itinerary
            .map((d) => FamTripDayDto(
                  day: d.day,
                  title: d.title,
                  activities: d.activities,
                  accommodation: d.accommodation,
                  meals: d.meals,
                ))
            .toList(),
        requiredFollowerCount: entity.requiredFollowerCount,
        requiredNiches: entity.requiredNiches,
        perks: entity.perks,
        organizerName: entity.organizerName,
      );
}

extension FamTripDtoX on FamTripDto {
  FamTripEntity toEntity() => FamTripEntity(
        id: id,
        title: title,
        destinationId: destinationId,
        description: description,
        coverImageUrl: coverImageUrl,
        departureDate: DateTime.parse(departureDate),
        returnDate: DateTime.parse(returnDate),
        capacity: capacity,
        enrolledCount: enrolledCount,
        status: FamTripStatus.values.byName(status),
        itinerary: itinerary.map((d) => d.toEntity()).toList(),
        requiredFollowerCount: requiredFollowerCount,
        requiredNiches: requiredNiches,
        perks: perks,
        organizerName: organizerName,
      );
}
