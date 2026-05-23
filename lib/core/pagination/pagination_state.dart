import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';

sealed class PaginationState<T> extends Equatable {
  const PaginationState();
}

final class PaginationInitial<T> extends PaginationState<T> {
  const PaginationInitial();

  @override
  List<Object?> get props => [];
}

final class PaginationLoading<T> extends PaginationState<T> {
  const PaginationLoading();

  @override
  List<Object?> get props => [];
}

final class PaginationLoaded<T> extends PaginationState<T> {
  final PaginatedResponse<T> response;
  final bool isFetchingMore;
  final bool hasReachedEnd;

  const PaginationLoaded({
    required this.response,
    this.isFetchingMore = false,
    this.hasReachedEnd = false,
  });

  PaginationLoaded<T> copyWith({
    PaginatedResponse<T>? response,
    bool? isFetchingMore,
    bool? hasReachedEnd,
  }) {
    return PaginationLoaded<T>(
      response: response ?? this.response,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }

  List<T> get items => response.items;
  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [response, isFetchingMore, hasReachedEnd];
}

final class PaginationError<T> extends PaginationState<T> {
  final Failure failure;
  final List<T> previousItems;

  const PaginationError({
    required this.failure,
    this.previousItems = const [],
  });

  bool get hasPreviousData => previousItems.isNotEmpty;

  @override
  List<Object?> get props => [failure, previousItems];
}

final class PaginationEmpty<T> extends PaginationState<T> {
  const PaginationEmpty();

  @override
  List<Object?> get props => [];
}
