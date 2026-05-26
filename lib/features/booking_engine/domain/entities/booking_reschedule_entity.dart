import 'package:equatable/equatable.dart';

enum RescheduleStatus { pending, accepted, declined, expired }

class BookingRescheduleEntity extends Equatable {
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

  const BookingRescheduleEntity({
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

  bool get isPending => status == RescheduleStatus.pending;
  bool get isExpired =>
      status == RescheduleStatus.pending && DateTime.now().isAfter(expiresAt);
  bool get isAccepted => status == RescheduleStatus.accepted;

  @override
  List<Object?> get props => [
        id, bookingId, requestedByUserId, requestedByName, originalDate,
        proposedDate, reason, status, declineReason, expiresAt,
        respondedAt, createdAt,
      ];
}
