import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/repositories/event_repository.dart';
import 'package:vibyuk/features/events/domain/usecases/get_event_detail_usecase.dart';

class PublishEventUseCase implements UseCase<EventEntity, EventIdParams> {
  const PublishEventUseCase(this._repository);
  final EventRepository _repository;

  @override
  Future<Either<Failure, EventEntity>> call(EventIdParams params) =>
      _repository.publishEvent(params.eventId);
}
