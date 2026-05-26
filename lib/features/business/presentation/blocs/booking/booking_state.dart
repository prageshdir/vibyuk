part of 'booking_bloc.dart';

sealed class BookingState extends Equatable {
  const BookingState();
}

class BookingInitialState extends BookingState {
  const BookingInitialState();
  @override
  List<Object?> get props => [];
}

class BookingLoadingState extends BookingState {
  const BookingLoadingState();
  @override
  List<Object?> get props => [];
}

class BookingsLoadedState extends BookingState {
  const BookingsLoadedState({
    required this.bookings,
    required this.hasMore,
    required this.currentPage,
    this.filterStatus,
    this.isLoadingMore = false,
  });

  final List<BookingEntity> bookings;
  final bool hasMore;
  final int currentPage;
  final BookingStatus? filterStatus;
  final bool isLoadingMore;

  BookingsLoadedState copyWith({
    List<BookingEntity>? bookings,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) =>
      BookingsLoadedState(
        bookings: bookings ?? this.bookings,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        filterStatus: filterStatus,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props =>
      [bookings, hasMore, currentPage, filterStatus, isLoadingMore];
}

class BookingDetailLoadedState extends BookingState {
  const BookingDetailLoadedState({required this.booking});
  final BookingEntity booking;
  @override
  List<Object?> get props => [booking];
}

class BookingStatusUpdatedState extends BookingState {
  const BookingStatusUpdatedState({required this.booking});
  final BookingEntity booking;
  @override
  List<Object?> get props => [booking];
}

class BookingCancelledState extends BookingState {
  const BookingCancelledState({required this.bookingId});
  final String bookingId;
  @override
  List<Object?> get props => [bookingId];
}

class BookingErrorState extends BookingState {
  const BookingErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
