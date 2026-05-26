import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/entities/event_form_data.dart';
import 'package:vibyuk/features/events/domain/repositories/event_repository.dart';

class CreateEventUseCase implements UseCase<EventEntity, CreateEventParams> {
  const CreateEventUseCase(this._repository);
  final EventRepository _repository;

  @override
  Future<Either<Failure, EventEntity>> call(CreateEventParams params) =>
      _repository.createEvent(params.formData);
}

class CreateEventParams extends Equatable {
  final EventFormData formData;
  const CreateEventParams(this.formData);

  @override
  List<Object?> get props => [formData];
}
