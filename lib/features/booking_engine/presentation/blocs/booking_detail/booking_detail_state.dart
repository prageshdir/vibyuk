part of 'booking_detail_bloc.dart';

sealed class BookingDetailState extends Equatable {
  const BookingDetailState();
}

class BookingDetailInitialState extends BookingDetailState {
  const BookingDetailInitialState();
  @override
  List<Object?> get props => [];
}

class BookingDetailLoadingState extends BookingDetailState {
  const BookingDetailLoadingState();
  @override
  List<Object?> get props => [];
}

class BookingDetailLoadedState extends BookingDetailState {
  const BookingDetailLoadedState({
    required this.booking,
    this.isActioning = false,
    this.actionError,
    this.actionSuccess = false,
  });

  final BookingEntity booking;
  final bool isActioning;
  final Failure? actionError;
  final bool actionSuccess;

  BookingDetailLoadedState copyWith({
    BookingEntity? booking,
    bool? isActioning,
    Failure? actionError,
    bool? actionSuccess,
  }) =>
      BookingDetailLoadedState(
        booking: booking ?? this.booking,
        isActioning: isActioning ?? false,
        actionError: actionError,
        actionSuccess: actionSuccess ?? false,
      );

  @override
  List<Object?> get props =>
      [booking, isActioning, actionError, actionSuccess];
}

class BookingDetailErrorState extends BookingDetailState {
  const BookingDetailErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
