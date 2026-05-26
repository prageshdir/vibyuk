import 'package:vibyuk/features/business/data/models/creator_model.dart';
import 'package:vibyuk/features/business/domain/entities/booking_entity.dart';

class BookingModel {
  const BookingModel({
    required this.id,
    this.campaignId,
    required this.creatorId,
    required this.businessId,
    required this.status,
    required this.scheduledAt,
    this.completedAt,
    required this.price,
    this.currency = 'GBP',
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
  final String status;
  final DateTime scheduledAt;
  final DateTime? completedAt;
  final double price;
  final String currency;
  final String? notes;
  final String? cancellationReason;
  final CreatorModel? creator;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json['id'] as String,
        campaignId: json['campaign_id'] as String?,
        creatorId: json['creator_id'] as String,
        businessId: json['business_id'] as String,
        status: json['status'] as String? ?? 'pending',
        scheduledAt: DateTime.parse(json['scheduled_at'] as String),
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        price: (json['price'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'GBP',
        notes: json['notes'] as String?,
        cancellationReason: json['cancellation_reason'] as String?,
        creator: json['creator'] != null
            ? CreatorModel.fromJson(json['creator'] as Map<String, dynamic>)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );

  BookingEntity toEntity() => BookingEntity(
        id: id,
        campaignId: campaignId,
        creatorId: creatorId,
        businessId: businessId,
        status: BookingStatus.values.firstWhere(
          (s) => s.name == status,
          orElse: () => BookingStatus.pending,
        ),
        scheduledAt: scheduledAt,
        completedAt: completedAt,
        price: price,
        currency: currency,
        notes: notes,
        cancellationReason: cancellationReason,
        creator: creator?.toEntity(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
