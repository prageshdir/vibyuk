import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_timeline_event_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/repositories/booking_engine_repository.dart';

class GetBookingTimelineUseCase
    extends UseCase<List<BookingTimelineEventEntity>, TimelineParams> {
  const GetBookingTimelineUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, List<BookingTimelineEventEntity>>> call(
          TimelineParams params) =>
      _repository.getTimeline(params.bookingId);
}

class TimelineParams extends Equatable {
  const TimelineParams({required this.bookingId});
  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}
