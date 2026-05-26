import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/availability_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class UpdateDayAvailabilityUseCase
    extends UseCase<AvailabilityEntity, UpdateDayAvailabilityParams> {
  final CreatorRepository _repository;
  const UpdateDayAvailabilityUseCase(this._repository);

  @override
  Future<Either<Failure, AvailabilityEntity>> call(
          UpdateDayAvailabilityParams params) =>
      _repository.updateDayAvailability(
          date: params.date, status: params.status);
}

class UpdateDayAvailabilityParams extends Equatable {
  final DateTime date;
  final DayAvailability status;
  const UpdateDayAvailabilityParams({required this.date, required this.status});

  @override
  List<Object?> get props => [date, status];
}
