import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_timeline_event_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/timeline/get_booking_timeline_use_case.dart';

part 'timeline_event.dart';
part 'timeline_state.dart';

class TimelineBloc extends BaseBloc<TimelineEvent, TimelineState> {
  TimelineBloc({required GetBookingTimelineUseCase getTimeline})
      : _getTimeline = getTimeline,
        super(const TimelineInitialState()) {
    on<LoadTimelineEvent>(_onLoad);
  }

  final GetBookingTimelineUseCase _getTimeline;

  Future<void> _onLoad(
      LoadTimelineEvent event, Emitter<TimelineState> emit) async {
    emit(const TimelineLoadingState());
    final result =
        await _getTimeline(TimelineParams(bookingId: event.bookingId));
    result.fold(
      (f) => emit(TimelineErrorState(failure: f)),
      (events) => emit(TimelineLoadedState(events: events)),
    );
  }
}
