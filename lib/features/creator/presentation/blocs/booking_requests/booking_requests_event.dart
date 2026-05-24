part of 'booking_requests_bloc.dart';

sealed class BookingRequestsEvent extends Equatable {
  const BookingRequestsEvent();
}

class LoadBookingRequestsEvent extends BookingRequestsEvent {
  const LoadBookingRequestsEvent({this.statusFilter});
  final BookingRequestStatus? statusFilter;
  @override
  List<Object?> get props => [statusFilter];
}

class LoadMoreBookingRequestsEvent extends BookingRequestsEvent {
  const LoadMoreBookingRequestsEvent();
  @override
  List<Object?> get props => [];
}

class FilterBookingRequestsEvent extends BookingRequestsEvent {
  const FilterBookingRequestsEvent({this.statusFilter});
  final BookingRequestStatus? statusFilter;
  @override
  List<Object?> get props => [statusFilter];
}

class LoadBookingRequestDetailEvent extends BookingRequestsEvent {
  const LoadBookingRequestDetailEvent({required this.requestId});
  final String requestId;
  @override
  List<Object?> get props => [requestId];
}

class RespondToBookingRequestEvent extends BookingRequestsEvent {
  const RespondToBookingRequestEvent({
    required this.requestId,
    required this.accept,
    this.counterOfferPrice,
    this.counterOfferMessage,
  });
  final String requestId;
  final bool accept;
  final double? counterOfferPrice;
  final String? counterOfferMessage;
  @override
  List<Object?> get props =>
      [requestId, accept, counterOfferPrice, counterOfferMessage];
}
