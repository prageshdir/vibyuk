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
