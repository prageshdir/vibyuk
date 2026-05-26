import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/business/domain/entities/creator_entity.dart';

enum BookingStatus { pending, confirmed, inProgress, completed, cancelled, disputed }

extension BookingStatusX on BookingStatus {
  String get label => switch (this) {
        BookingStatus.pending => 'Pending',
        BookingStatus.confirmed => 'Confirmed',
        BookingStatus.inProgress => 'In Progress',
        BookingStatus.completed => 'Completed',
        BookingStatus.cancelled => 'Cancelled',
        BookingStatus.disputed => 'Disputed',
      };

  bool get isTerminal =>
      this == BookingStatus.completed ||
      this == BookingStatus.cancelled ||
      this == BookingStatus.disputed;

  bool get isActive =>
      this == BookingStatus.confirmed || this == BookingStatus.inProgress;
}

class BookingEntity extends Equatable {
  const BookingEntity({
    required this.id,
    this.campaignId,
    required this.creatorId,
    required this.businessId,
    required this.status,
    required this.scheduledAt,
    this.completedAt,
    required this.price,
    this.currency = 'INR',
    this.notes,
    this.cancellationReason,
    this.creator,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? campaignId;
  final String creatorId;
  final String businessId;
  final BookingStatus status;
  final DateTime scheduledAt;
  final DateTime? completedAt;
  final double price;
  final String currency;
  final String? notes;
  final String? cancellationReason;
  final CreatorEntity? creator;
  final DateTime createdAt;
  final DateTime? updatedAt;

  String get priceDisplay => '₹${price.toStringAsFixed(2)}';

  BookingEntity copyWith({BookingStatus? status, DateTime? completedAt}) =>
      BookingEntity(
        id: id,
        campaignId: campaignId,
        creatorId: creatorId,
        businessId: businessId,
        status: status ?? this.status,
        scheduledAt: scheduledAt,
        completedAt: completedAt ?? this.completedAt,
        price: price,
        currency: currency,
        notes: notes,
        cancellationReason: cancellationReason,
        creator: creator,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  List<Object?> get props => [
        id, campaignId, creatorId, businessId, status, scheduledAt,
        completedAt, price, currency, notes, cancellationReason,
        creator, createdAt, updatedAt,
      ];
}
