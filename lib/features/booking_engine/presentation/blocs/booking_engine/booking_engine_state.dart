part of 'booking_engine_bloc.dart';

sealed class BookingEngineState extends Equatable {
  const BookingEngineState();
}

class BookingEngineInitialState extends BookingEngineState {
  const BookingEngineInitialState();
  @override
  List<Object?> get props => [];
}

class BookingEngineLoadingState extends BookingEngineState {
  const BookingEngineLoadingState();
  @override
  List<Object?> get props => [];
}

class BookingEngineLoadedState extends BookingEngineState {
  const BookingEngineLoadedState({
    required this.bookings,
    required this.hasMore,
    required this.currentPage,
    this.statusFilter,
    this.isLoadingMore = false,
  });

  final List<BookingEntity> bookings;
  final bool hasMore;
  final int currentPage;
  final BookingStatus? statusFilter;
  final bool isLoadingMore;

  BookingEngineLoadedState copyWith({
    List<BookingEntity>? bookings,
    bool? hasMore,
    int? currentPage,
    BookingStatus? statusFilter,
    bool clearFilter = false,
    bool? isLoadingMore,
  }) =>
      BookingEngineLoadedState(
        bookings: bookings ?? this.bookings,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        statusFilter:
            clearFilter ? null : (statusFilter ?? this.statusFilter),
        isLoadingMore: isLoadingMore ?? false,
      );

  @override
  List<Object?> get props =>
      [bookings, hasMore, currentPage, statusFilter, isLoadingMore];
}

class BookingEngineErrorState extends BookingEngineState {
  const BookingEngineErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
