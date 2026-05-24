import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/creator/domain/entities/review_entity.dart';
import 'package:vibyuk/features/creator/domain/usecases/reviews/get_reviews_use_case.dart';

part 'reviews_event.dart';
part 'reviews_state.dart';

class ReviewsBloc extends BaseBloc<ReviewsEvent, ReviewsState> {
  ReviewsBloc({required GetReviewsUseCase getReviews})
      : _getReviews = getReviews,
        super(const ReviewsInitialState()) {
    on<LoadReviewsEvent>(_onLoad);
    on<LoadMoreReviewsEvent>(_onLoadMore);
  }

  final GetReviewsUseCase _getReviews;
  int _currentPage = 1;
  static const int _pageSize = 20;

  Future<void> _onLoad(
      LoadReviewsEvent event, Emitter<ReviewsState> emit) async {
    emit(const ReviewsLoadingState());
    _currentPage = 1;
    final result = await _getReviews(
        GetReviewsParams(page: _currentPage, pageSize: _pageSize));
    result.fold(
      (f) => emit(ReviewsErrorState(failure: f)),
      (r) => emit(ReviewsLoadedState(
        reviews: r.items,
        hasMore: r.hasNextPage,
        currentPage: _currentPage,
      )),
    );
  }

  Future<void> _onLoadMore(
      LoadMoreReviewsEvent event, Emitter<ReviewsState> emit) async {
    if (state is! ReviewsLoadedState) return;
    final current = state as ReviewsLoadedState;
    if (!current.hasMore || current.isLoadingMore) return;
    emit(current.copyWith(isLoadingMore: true));
    final result = await _getReviews(
        GetReviewsParams(page: _currentPage + 1, pageSize: _pageSize));
    result.fold(
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (r) {
        _currentPage++;
        emit(current.copyWith(
          reviews: [...current.reviews, ...r.items],
          hasMore: r.hasNextPage,
          currentPage: _currentPage,
          isLoadingMore: false,
        ));
      },
    );
  }
}
