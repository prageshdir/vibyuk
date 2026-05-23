import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/core/pagination/pagination_event.dart';
import 'package:vibyuk/core/pagination/pagination_state.dart';

typedef PageFetcher<T> = Future<Either<Failure, PaginatedResponse<T>>> Function(int page);

abstract class PaginationBloc<T>
    extends BaseBloc<PaginationEvent, PaginationState<T>> {
  PaginationBloc() : super(const PaginationInitial()) {
    on<FetchFirstPage<T>>(_onFetchFirstPage);
    on<FetchNextPage<T>>(_onFetchNextPage);
    on<RefreshPage<T>>(_onRefreshPage);
  }

  PageFetcher<T> get fetcher;

  Future<void> _onFetchFirstPage(
    FetchFirstPage<T> event,
    Emitter<PaginationState<T>> emit,
  ) async {
    emit(const PaginationLoading());
    final result = await fetcher(1);
    result.fold(
      (failure) => emit(PaginationError(failure: failure)),
      (response) => response.isEmpty
          ? emit(const PaginationEmpty())
          : emit(PaginationLoaded(
              response: response,
              hasReachedEnd: response.isLastPage,
            )),
    );
  }

  Future<void> _onFetchNextPage(
    FetchNextPage<T> event,
    Emitter<PaginationState<T>> emit,
  ) async {
    final current = state;
    if (current is! PaginationLoaded<T>) return;
    if (current.isFetchingMore || current.hasReachedEnd) return;

    emit(current.copyWith(isFetchingMore: true));

    final nextPage = current.response.currentPage + 1;
    final result = await fetcher(nextPage);

    result.fold(
      (failure) => emit(PaginationError(
        failure: failure,
        previousItems: current.items,
      )),
      (response) => emit(PaginationLoaded(
        response: current.response.appendPage(response),
        isFetchingMore: false,
        hasReachedEnd: response.isLastPage,
      )),
    );
  }

  Future<void> _onRefreshPage(
    RefreshPage<T> event,
    Emitter<PaginationState<T>> emit,
  ) async {
    // Keep showing existing data while refreshing
    final current = state;
    if (current is PaginationLoaded<T>) {
      emit(current.copyWith(isFetchingMore: false));
    } else {
      emit(const PaginationLoading());
    }

    final result = await fetcher(1);
    result.fold(
      (failure) => emit(PaginationError(
        failure: failure,
        previousItems: current is PaginationLoaded<T> ? current.items : [],
      )),
      (response) => response.isEmpty
          ? emit(const PaginationEmpty())
          : emit(PaginationLoaded(
              response: response,
              hasReachedEnd: response.isLastPage,
            )),
    );
  }
}
