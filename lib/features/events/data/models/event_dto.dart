import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/events/data/models/ticket_type_dto.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';

part 'event_dto.freezed.dart';
part 'event_dto.g.dart';

@freezed
class EventDto with _$EventDto {
  const EventDto._();

  const factory EventDto({
    required String id,
    required String title,
    @Default('') String description,
    @JsonKey(name: 'organizer_id') required String organizerId,
    @JsonKey(name: 'organizer_name') @Default('') String organizerName,
    @JsonKey(name: 'organizer_avatar_url') String? organizerAvatarUrl,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'end_date') required DateTime endDate,
    @JsonKey(name: 'venue_name') @Default('') String venueName,
    @JsonKey(name: 'venue_address') String? venueAddress,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'is_online') @Default(false) bool isOnline,
    @JsonKey(name: 'stream_url') String? streamUrl,
    @Default('draft') String status,
    @Default('other') String category,
    @JsonKey(name: 'ticket_types') @Default([]) List<TicketTypeDto> ticketTypes,
    @JsonKey(name: 'total_capacity') @Default(0) int totalCapacity,
    @JsonKey(name: 'sold_tickets') @Default(0) int soldTickets,
    @Default('INR') String currency,
    @Default([]) List<String> tags,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _EventDto;

  factory EventDto.fromJson(Map<String, dynamic> json) =>
      _$EventDtoFromJson(json);

  EventEntity toEntity() => EventEntity(
    id: id, title: title, description: description,
    organizerId: organizerId, organizerName: organizerName,
    organizerAvatarUrl: organizerAvatarUrl, coverImageUrl: coverImageUrl,
    startDate: startDate, endDate: endDate,
    venueName: venueName, venueAddress: venueAddress,
    latitude: latitude, longitude: longitude,
    isOnline: isOnline, streamUrl: streamUrl,
    status: EventStatus.values.firstWhere((s) => s.name == status,
        orElse: () => EventStatus.draft),
    category: EventCategory.values.firstWhere((c) => c.name == category,
        orElse: () => EventCategory.other),
    ticketTypes: ticketTypes.map((t) => t.toEntity()).toList(),
    totalCapacity: totalCapacity, soldTickets: soldTickets,
    currency: currency, tags: tags, isFeatured: isFeatured,
    createdAt: createdAt, updatedAt: updatedAt,
  );
}
