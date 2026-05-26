import 'package:equatable/equatable.dart';

class ReviewDimensions extends Equatable {
  final double professionalism;
  final double quality;
  final double timeliness;

  const ReviewDimensions({
    required this.professionalism,
    required this.quality,
    required this.timeliness,
  });

  double get weightedAverage =>
      (professionalism * 0.35 + quality * 0.40 + timeliness * 0.25)
          .clamp(1.0, 5.0);

  @override
  List<Object?> get props => [professionalism, quality, timeliness];
}

class ReviewEntity extends Equatable {
  final String id;
  final String creatorId;
  final String bookingId;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerAvatarUrl;
  final double rating;
  final ReviewDimensions? dimensions;
  final String? comment;
  final String? creatorResponse;
  final bool isVerifiedBooking;
  final DateTime createdAt;
  final DateTime? creatorRespondedAt;

  const ReviewEntity({
    required this.id,
    required this.creatorId,
    required this.bookingId,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerAvatarUrl,
    required this.rating,
    this.dimensions,
    this.comment,
    this.creatorResponse,
    required this.isVerifiedBooking,
    required this.createdAt,
    this.creatorRespondedAt,
  });

  double get effectiveRating =>
      dimensions?.weightedAverage ?? rating;

  @override
  List<Object?> get props => [
        id,
        creatorId,
        bookingId,
        reviewerId,
        reviewerName,
        reviewerAvatarUrl,
        rating,
        dimensions,
        comment,
        creatorResponse,
        isVerifiedBooking,
        createdAt,
        creatorRespondedAt,
      ];
}

class ReviewValidation {
  static const int minCommentLength = 50;

  static String? validateComment(String? value) {
    if (value == null || value.trim().length < minCommentLength) {
      return 'Review must be at least $minCommentLength characters';
    }
    return null;
  }
}
