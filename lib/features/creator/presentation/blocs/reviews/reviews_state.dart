part of 'reviews_bloc.dart';

sealed class ReviewsState extends Equatable {
  const ReviewsState();
}

class ReviewsInitialState extends ReviewsState {
  const ReviewsInitialState();
  @override
  List<Object?> get props => [];
}

class ReviewsLoadingState extends ReviewsState {
  const ReviewsLoadingState();
  @override
  List<Object?> get props => [];
}

class ReviewsLoadedState extends ReviewsState {
  const ReviewsLoadedState({
    required this.reviews,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
  });
  final List<ReviewEntity> reviews;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  ReviewsLoadedState copyWith({
    List<ReviewEntity>? reviews,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) =>
      ReviewsLoadedState(
        reviews: reviews ?? this.reviews,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        isLoadingMore: isLoadingMore ?? false,
      );

  @override
  List<Object?> get props => [reviews, hasMore, currentPage, isLoadingMore];
}

class ReviewsErrorState extends ReviewsState {
  const ReviewsErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
