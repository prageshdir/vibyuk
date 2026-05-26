import 'package:equatable/equatable.dart';

enum DisputeStatus { open, underReview, resolved, escalated, closed }

enum DisputeReason {
  deliveryNotMet,
  qualityIssue,
  paymentIssue,
  noShow,
  scopeChange,
  other,
}

class BookingDisputeEntity extends Equatable {
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

  const BookingDisputeEntity({
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

  bool get isOpen => status == DisputeStatus.open;
  bool get isResolved =>
      status == DisputeStatus.resolved || status == DisputeStatus.closed;
  bool get needsResponse => isOpen && response == null;

  @override
  List<Object?> get props => [
        id, bookingId, openedByUserId, openedByName, reason, description,
        status, resolutionNotes, respondedByUserId, respondedByName, response,
        respondedAt, resolvedAt, createdAt,
      ];
}
