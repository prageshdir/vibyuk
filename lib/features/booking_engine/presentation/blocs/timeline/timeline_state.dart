part of 'timeline_bloc.dart';

sealed class TimelineState extends Equatable {
  const TimelineState();
}

class TimelineInitialState extends TimelineState {
  const TimelineInitialState();
  @override
  List<Object?> get props => [];
}

class TimelineLoadingState extends TimelineState {
  const TimelineLoadingState();
  @override
  List<Object?> get props => [];
}

class TimelineLoadedState extends TimelineState {
  const TimelineLoadedState({required this.events});
  final List<BookingTimelineEventEntity> events;
  @override
  List<Object?> get props => [events];
}

class TimelineErrorState extends TimelineState {
  const TimelineErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
