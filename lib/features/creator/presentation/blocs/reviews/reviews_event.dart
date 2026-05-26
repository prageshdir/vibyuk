part of 'reviews_bloc.dart';

sealed class ReviewsEvent extends Equatable {
  const ReviewsEvent();
}

class LoadReviewsEvent extends ReviewsEvent {
  const LoadReviewsEvent();
  @override
  List<Object?> get props => [];
}

class LoadMoreReviewsEvent extends ReviewsEvent {
  const LoadMoreReviewsEvent();
  @override
  List<Object?> get props => [];
}

class RespondToReviewEvent extends ReviewsEvent {
  const RespondToReviewEvent({
    required this.reviewId,
    required this.response,
  });
  final String reviewId;
  final String response;
  @override
  List<Object?> get props => [reviewId, response];
}
