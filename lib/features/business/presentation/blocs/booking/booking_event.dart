part of 'booking_bloc.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();
}

class LoadBookingsEvent extends BookingEvent {
  const LoadBookingsEvent({this.status});
  final BookingStatus? status;
  @override
  List<Object?> get props => [status];
}

class LoadMoreBookingsEvent extends BookingEvent {
  const LoadMoreBookingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadBookingDetailEvent extends BookingEvent {
  const LoadBookingDetailEvent({required this.bookingId});
  final String bookingId;
  @override
  List<Object?> get props => [bookingId];
}

class UpdateBookingStatusEvent extends BookingEvent {
  const UpdateBookingStatusEvent({
    required this.bookingId,
    required this.status,
  });
  final String bookingId;
  final BookingStatus status;
  @override
  List<Object?> get props => [bookingId, status];
}

class CancelBookingEvent extends BookingEvent {
  const CancelBookingEvent({required this.bookingId, this.reason});
  final String bookingId;
  final String? reason;
  @override
  List<Object?> get props => [bookingId, reason];
}

class FilterBookingsByStatusEvent extends BookingEvent {
  const FilterBookingsByStatusEvent({this.status});
  final BookingStatus? status;
  @override
  List<Object?> get props => [status];
}
