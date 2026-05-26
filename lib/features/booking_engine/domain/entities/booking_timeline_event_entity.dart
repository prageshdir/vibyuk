import 'package:equatable/equatable.dart';

enum TimelineEventType {
  bookingCreated,
  bookingConfirmed,
  contractSent,
  contractSigned,
  milestoneStarted,
  milestoneSubmitted,
  milestoneApproved,
  milestoneRejected,
  paymentReleased,
  rescheduleRequested,
  rescheduled,
  disputeOpened,
  disputeResolved,
  bookingCompleted,
  bookingCancelled,
  messageReceived,
}

class BookingTimelineEventEntity extends Equatable {
  final String id;
  final String bookingId;
  final TimelineEventType type;
  final String title;
  final String? description;
  final String? actorId;
  final String? actorName;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const BookingTimelineEventEntity({
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

  @override
  List<Object?> get props => [
        id, bookingId, type, title, description, actorId, actorName,
        metadata, createdAt,
      ];
}
