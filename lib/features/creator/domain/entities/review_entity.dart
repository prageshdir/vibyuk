import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String creatorId;
  final String bookingId;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerAvatarUrl;
  final double rating;
  final String? comment;
  final bool isVerifiedBooking;
  final DateTime createdAt;

  const ReviewEntity({
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

  @override
  List<Object?> get props => [
        id,
        creatorId,
        bookingId,
        reviewerId,
        reviewerName,
        reviewerAvatarUrl,
        rating,
        comment,
        isVerifiedBooking,
        createdAt,
      ];
}
