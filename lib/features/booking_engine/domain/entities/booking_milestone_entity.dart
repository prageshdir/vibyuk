import 'package:equatable/equatable.dart';

enum MilestoneStatus {
  pending,
  inProgress,
  submitted,
  approved,
  rejected,
  released,
}

class BookingMilestoneEntity extends Equatable {
  final String id;
  final String bookingId;
  final int order;
  final String title;
  final String? description;
  final double amount;
  final String currency;
  final MilestoneStatus status;
  final DateTime dueDate;
  final String? deliverableUrl;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final DateTime? releasedAt;

  const BookingMilestoneEntity({
    required this.id,
    required this.bookingId,
    required this.order,
    required this.title,
    this.description,
    required this.amount,
    required this.currency,
    required this.status,
    required this.dueDate,
    this.deliverableUrl,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
    this.releasedAt,
  });

  bool get isPending => status == MilestoneStatus.pending;
  bool get isSubmitted => status == MilestoneStatus.submitted;
  bool get isApproved => status == MilestoneStatus.approved;
  bool get isReleased => status == MilestoneStatus.released;
  bool get needsAction =>
      status == MilestoneStatus.submitted || status == MilestoneStatus.rejected;
  bool get isOverdue =>
      status == MilestoneStatus.pending && DateTime.now().isAfter(dueDate);

  @override
  List<Object?> get props => [
        id, bookingId, order, title, description, amount, currency, status,
        dueDate, deliverableUrl, rejectionReason, submittedAt, reviewedAt,
        releasedAt,
      ];
}
