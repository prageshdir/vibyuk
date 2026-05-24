import 'package:vibyuk/features/creator/domain/entities/review_entity.dart';

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.creatorId,
    required this.bookingId,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerAvatarUrl,
    required this.rating,
    this.comment,
    required this.isVerifiedBooking,
    required this.createdAt,
  });

  final String id;
  final String creatorId;
  final String bookingId;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerAvatarUrl;
  final double rating;
  final String? comment;
  final bool isVerifiedBooking;
  final String createdAt;

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'] as String,
        creatorId: json['creator_id'] as String,
        bookingId: json['booking_id'] as String,
        reviewerId: json['reviewer_id'] as String,
        reviewerName: json['reviewer_name'] as String,
        reviewerAvatarUrl: json['reviewer_avatar_url'] as String?,
        rating: (json['rating'] as num).toDouble(),
        comment: json['comment'] as String?,
        isVerifiedBooking: json['is_verified_booking'] as bool? ?? true,
        createdAt: json['created_at'] as String,
      );

  ReviewEntity toEntity() => ReviewEntity(
        id: id,
        creatorId: creatorId,
        bookingId: bookingId,
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        reviewerAvatarUrl: reviewerAvatarUrl,
        rating: rating,
        comment: comment,
        isVerifiedBooking: isVerifiedBooking,
        createdAt: DateTime.parse(createdAt),
      );
}
