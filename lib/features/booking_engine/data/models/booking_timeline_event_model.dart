import 'package:vibyuk/features/booking_engine/domain/entities/booking_timeline_event_entity.dart';

class BookingTimelineEventModel {
  const BookingTimelineEventModel({
    required this.id,
    required this.bookingId,
    required this.type,
    required this.title,
    this.description,
    this.actorId,
    this.actorName,
    required this.metadata,
    required this.createdAt,
  });

  final String id;
  final String bookingId;
  final TimelineEventType type;
  final String title;
  final String? description;
  final String? actorId;
  final String? actorName;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  factory BookingTimelineEventModel.fromJson(Map<String, dynamic> j) =>
      BookingTimelineEventModel(
        id: j['id'] as String,
        bookingId: j['booking_id'] as String,
        type: TimelineEventType.values.firstWhere(
            (t) => t.name == j['type'],
            orElse: () => TimelineEventType.bookingCreated),
        title: j['title'] as String,
        description: j['description'] as String?,
        actorId: j['actor_id'] as String?,
        actorName: j['actor_name'] as String?,
        metadata: (j['metadata'] as Map<String, dynamic>?) ?? {},
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  BookingTimelineEventEntity toEntity() => BookingTimelineEventEntity(
        id: id,
        bookingId: bookingId,
        type: type,
        title: title,
        description: description,
        actorId: actorId,
        actorName: actorName,
        metadata: metadata,
        createdAt: createdAt,
      );
}
