import 'package:vibyuk/features/booking_engine/domain/entities/booking_reschedule_entity.dart';

class BookingRescheduleModel {
  const BookingRescheduleModel({
    required this.id,
    required this.bookingId,
    required this.requestedByUserId,
    required this.requestedByName,
    required this.originalDate,
    required this.proposedDate,
    this.reason,
    required this.status,
    this.declineReason,
    required this.expiresAt,
    this.respondedAt,
    required this.createdAt,
  });

  final String id;
  final String bookingId;
  final String requestedByUserId;
  final String requestedByName;
  final DateTime originalDate;
  final DateTime proposedDate;
  final String? reason;
  final RescheduleStatus status;
  final String? declineReason;
  final DateTime expiresAt;
  final DateTime? respondedAt;
  final DateTime createdAt;

  factory BookingRescheduleModel.fromJson(Map<String, dynamic> j) =>
      BookingRescheduleModel(
        id: j['id'] as String,
        bookingId: j['booking_id'] as String,
        requestedByUserId: j['requested_by_user_id'] as String,
        requestedByName: j['requested_by_name'] as String,
        originalDate: DateTime.parse(j['original_date'] as String),
        proposedDate: DateTime.parse(j['proposed_date'] as String),
        reason: j['reason'] as String?,
        status: RescheduleStatus.values.firstWhere(
            (s) => s.name == j['status'],
            orElse: () => RescheduleStatus.pending),
        declineReason: j['decline_reason'] as String?,
        expiresAt: DateTime.parse(j['expires_at'] as String),
        respondedAt: j['responded_at'] != null
            ? DateTime.parse(j['responded_at'] as String)
            : null,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  BookingRescheduleEntity toEntity() => BookingRescheduleEntity(
        id: id,
        bookingId: bookingId,
        requestedByUserId: requestedByUserId,
        requestedByName: requestedByName,
        originalDate: originalDate,
        proposedDate: proposedDate,
        reason: reason,
        status: status,
        declineReason: declineReason,
        expiresAt: expiresAt,
        respondedAt: respondedAt,
        createdAt: createdAt,
      );
}
