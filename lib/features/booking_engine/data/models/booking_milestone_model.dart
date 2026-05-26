import 'package:vibyuk/features/booking_engine/domain/entities/booking_milestone_entity.dart';

class BookingMilestoneModel {
  const BookingMilestoneModel({
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

  factory BookingMilestoneModel.fromJson(Map<String, dynamic> j) =>
      BookingMilestoneModel(
        id: j['id'] as String,
        bookingId: j['booking_id'] as String,
        order: j['order'] as int? ?? 0,
        title: j['title'] as String,
        description: j['description'] as String?,
        amount: (j['amount'] as num).toDouble(),
        currency: j['currency'] as String,
        status: MilestoneStatus.values.firstWhere(
            (s) => s.name == j['status'],
            orElse: () => MilestoneStatus.pending),
        dueDate: DateTime.parse(j['due_date'] as String),
        deliverableUrl: j['deliverable_url'] as String?,
        rejectionReason: j['rejection_reason'] as String?,
        submittedAt: j['submitted_at'] != null
            ? DateTime.parse(j['submitted_at'] as String)
            : null,
        reviewedAt: j['reviewed_at'] != null
            ? DateTime.parse(j['reviewed_at'] as String)
            : null,
        releasedAt: j['released_at'] != null
            ? DateTime.parse(j['released_at'] as String)
            : null,
      );

  BookingMilestoneEntity toEntity() => BookingMilestoneEntity(
        id: id,
        bookingId: bookingId,
        order: order,
        title: title,
        description: description,
        amount: amount,
        currency: currency,
        status: status,
        dueDate: dueDate,
        deliverableUrl: deliverableUrl,
        rejectionReason: rejectionReason,
        submittedAt: submittedAt,
        reviewedAt: reviewedAt,
        releasedAt: releasedAt,
      );
}
