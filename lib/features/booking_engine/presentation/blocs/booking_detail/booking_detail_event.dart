part of 'booking_detail_bloc.dart';

sealed class BookingDetailEvent extends Equatable {
  const BookingDetailEvent();
}

class LoadBookingDetailEvent extends BookingDetailEvent {
  const LoadBookingDetailEvent({required this.bookingId});
  final String bookingId;
  @override
  List<Object?> get props => [bookingId];
}

class ConfirmBookingDetailEvent extends BookingDetailEvent {
  const ConfirmBookingDetailEvent({required this.bookingId});
  final String bookingId;
  @override
  List<Object?> get props => [bookingId];
}

class CancelBookingDetailEvent extends BookingDetailEvent {
  const CancelBookingDetailEvent(
      {required this.bookingId, required this.reason});
  final String bookingId;
  final String reason;
  @override
  List<Object?> get props => [bookingId, reason];
}
