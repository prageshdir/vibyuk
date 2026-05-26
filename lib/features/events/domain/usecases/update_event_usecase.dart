import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/entities/event_form_data.dart';
import 'package:vibyuk/features/events/domain/repositories/event_repository.dart';

class UpdateEventUseCase implements UseCase<EventEntity, UpdateEventParams> {
  const UpdateEventUseCase(this._repository);
  final EventRepository _repository;

  @override
  Future<Either<Failure, EventEntity>> call(UpdateEventParams params) =>
      _repository.updateEvent(params.eventId, params.formData);
}

class UpdateEventParams extends Equatable {
  final String eventId;
  final EventFormData formData;
  const UpdateEventParams({required this.eventId, required this.formData});

  @override
  List<Object?> get props => [eventId, formData];
}
