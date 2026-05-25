part of 'availability_bloc.dart';

sealed class AvailabilityEvent extends Equatable {
  const AvailabilityEvent();
}

class LoadAvailabilityEvent extends AvailabilityEvent {
  const LoadAvailabilityEvent();
  @override
  List<Object?> get props => [];
}

class UpdateDayAvailabilityEvent extends AvailabilityEvent {
  const UpdateDayAvailabilityEvent({required this.date, required this.status});
  final DateTime date;
  final DayAvailability status;
  @override
  List<Object?> get props => [date, status];
}

class UpdateWeeklySlotsEvent extends AvailabilityEvent {
  const UpdateWeeklySlotsEvent({required this.slots});
  final List<TimeSlotEntity> slots;
  @override
  List<Object?> get props => [slots];
}

class BlockDatesEvent extends AvailabilityEvent {
  const BlockDatesEvent({required this.dates});
  final List<DateTime> dates;
  @override
  List<Object?> get props => [dates];
}
