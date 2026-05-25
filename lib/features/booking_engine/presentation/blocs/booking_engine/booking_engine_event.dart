part of 'booking_engine_bloc.dart';

sealed class BookingEngineEvent extends Equatable {
  const BookingEngineEvent();
}

class LoadBookingsEvent extends BookingEngineEvent {
  const LoadBookingsEvent({this.statusFilter});
  final BookingStatus? statusFilter;
  @override
  List<Object?> get props => [statusFilter];
}

class LoadMoreBookingsEvent extends BookingEngineEvent {
  const LoadMoreBookingsEvent();
  @override
  List<Object?> get props => [];
}

class FilterBookingsEvent extends BookingEngineEvent {
  const FilterBookingsEvent({this.statusFilter});
  final BookingStatus? statusFilter;
  @override
  List<Object?> get props => [statusFilter];
}

class RefreshBookingsEvent extends BookingEngineEvent {
  const RefreshBookingsEvent();
  @override
  List<Object?> get props => [];
}
