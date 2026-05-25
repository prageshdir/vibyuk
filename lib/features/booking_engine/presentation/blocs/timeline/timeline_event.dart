part of 'timeline_bloc.dart';

sealed class TimelineEvent extends Equatable {
  const TimelineEvent();
}

class LoadTimelineEvent extends TimelineEvent {
  const LoadTimelineEvent({required this.bookingId});
  final String bookingId;
  @override
  List<Object?> get props => [bookingId];
}
