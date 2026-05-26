import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/repositories/event_repository.dart';

class GetEventDetailUseCase implements UseCase<EventEntity, EventIdParams> {
  const GetEventDetailUseCase(this._repository);
  final EventRepository _repository;

  @override
  Future<Either<Failure, EventEntity>> call(EventIdParams params) =>
      _repository.getEventDetail(params.eventId);
}

class EventIdParams extends Equatable {
  final String eventId;
  const EventIdParams(this.eventId);

  @override
  List<Object?> get props => [eventId];
}
