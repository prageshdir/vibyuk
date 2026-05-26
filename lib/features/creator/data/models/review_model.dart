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
    this.professionalismRating,
    this.qualityRating,
    this.timelinessRating,
    this.comment,
    this.creatorResponse,
    required this.isVerifiedBooking,
    required this.createdAt,
    this.creatorRespondedAt,
  });

  final String id;
  final String creatorId;
  final String bookingId;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerAvatarUrl;
  final double rating;
  final double? professionalismRating;
  final double? qualityRating;
  final double? timelinessRating;
  final String? comment;
  final String? creatorResponse;
  final bool isVerifiedBooking;
  final String createdAt;
  final String? creatorRespondedAt;

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'] as String,
        creatorId: json['creator_id'] as String,
        bookingId: json['booking_id'] as String,
        reviewerId: json['reviewer_id'] as String,
        reviewerName: json['reviewer_name'] as String,
        reviewerAvatarUrl: json['reviewer_avatar_url'] as String?,
        rating: (json['rating'] as num).toDouble(),
        professionalismRating:
            (json['professionalism_rating'] as num?)?.toDouble(),
        qualityRating: (json['quality_rating'] as num?)?.toDouble(),
        timelinessRating: (json['timeliness_rating'] as num?)?.toDouble(),
        comment: json['comment'] as String?,
        creatorResponse: json['creator_response'] as String?,
        isVerifiedBooking: json['is_verified_booking'] as bool? ?? true,
        createdAt: json['created_at'] as String,
        creatorRespondedAt: json['creator_responded_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'creator_id': creatorId,
        'booking_id': bookingId,
        'reviewer_id': reviewerId,
        'reviewer_name': reviewerName,
        'reviewer_avatar_url': reviewerAvatarUrl,
        'rating': rating,
        'professionalism_rating': professionalismRating,
        'quality_rating': qualityRating,
        'timeliness_rating': timelinessRating,
        'comment': comment,
        'creator_response': creatorResponse,
        'is_verified_booking': isVerifiedBooking,
        'created_at': createdAt,
        'creator_responded_at': creatorRespondedAt,
      };

  ReviewEntity toEntity() {
    ReviewDimensions? dimensions;
    if (professionalismRating != null &&
        qualityRating != null &&
        timelinessRating != null) {
      dimensions = ReviewDimensions(
        professionalism: professionalismRating!,
        quality: qualityRating!,
        timeliness: timelinessRating!,
      );
    }
    return ReviewEntity(
      id: id,
      creatorId: creatorId,
      bookingId: bookingId,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      reviewerAvatarUrl: reviewerAvatarUrl,
      rating: rating,
      dimensions: dimensions,
      comment: comment,
      creatorResponse: creatorResponse,
      isVerifiedBooking: isVerifiedBooking,
      createdAt: DateTime.parse(createdAt),
      creatorRespondedAt: creatorRespondedAt != null
          ? DateTime.tryParse(creatorRespondedAt!)
          : null,
    );
  }
}
