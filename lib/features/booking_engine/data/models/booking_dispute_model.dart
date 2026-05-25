import 'package:vibyuk/features/booking_engine/domain/entities/booking_dispute_entity.dart';

class BookingDisputeModel {
  const BookingDisputeModel({
    required this.id,
    required this.bookingId,
    required this.openedByUserId,
    required this.openedByName,
    required this.reason,
    required this.description,
    required this.status,
    this.resolutionNotes,
    this.respondedByUserId,
    this.respondedByName,
    this.response,
    this.respondedAt,
    this.resolvedAt,
    required this.createdAt,
  });

  final String id;
  final String bookingId;
  final String openedByUserId;
  final String openedByName;
  final DisputeReason reason;
  final String description;
  final DisputeStatus status;
  final String? resolutionNotes;
  final String? respondedByUserId;
  final String? respondedByName;
  final String? response;
  final DateTime? respondedAt;
  final DateTime? resolvedAt;
  final DateTime createdAt;

  factory BookingDisputeModel.fromJson(Map<String, dynamic> j) =>
      BookingDisputeModel(
        id: j['id'] as String,
        bookingId: j['booking_id'] as String,
        openedByUserId: j['opened_by_user_id'] as String,
        openedByName: j['opened_by_name'] as String,
        reason: DisputeReason.values.firstWhere(
            (r) => r.name == j['reason'],
            orElse: () => DisputeReason.other),
        description: j['description'] as String,
        status: DisputeStatus.values.firstWhere(
            (s) => s.name == j['status'],
            orElse: () => DisputeStatus.open),
        resolutionNotes: j['resolution_notes'] as String?,
        respondedByUserId: j['responded_by_user_id'] as String?,
        respondedByName: j['responded_by_name'] as String?,
        response: j['response'] as String?,
        respondedAt: j['responded_at'] != null
            ? DateTime.parse(j['responded_at'] as String)
            : null,
        resolvedAt: j['resolved_at'] != null
            ? DateTime.parse(j['resolved_at'] as String)
            : null,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  BookingDisputeEntity toEntity() => BookingDisputeEntity(
        id: id,
        bookingId: bookingId,
        openedByUserId: openedByUserId,
        openedByName: openedByName,
        reason: reason,
        description: description,
        status: status,
        resolutionNotes: resolutionNotes,
        respondedByUserId: respondedByUserId,
        respondedByName: respondedByName,
        response: response,
        respondedAt: respondedAt,
        resolvedAt: resolvedAt,
        createdAt: createdAt,
      );
}
