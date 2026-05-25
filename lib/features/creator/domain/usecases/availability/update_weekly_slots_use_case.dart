import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/availability_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class UpdateWeeklySlotsUseCase
    extends UseCase<AvailabilityEntity, UpdateWeeklySlotsParams> {
  final CreatorRepository _repository;
  const UpdateWeeklySlotsUseCase(this._repository);

  @override
  Future<Either<Failure, AvailabilityEntity>> call(
          UpdateWeeklySlotsParams params) =>
      _repository.updateWeeklySlots(slots: params.slots);
}

class UpdateWeeklySlotsParams extends Equatable {
  final List<TimeSlotEntity> slots;
  const UpdateWeeklySlotsParams({required this.slots});

  @override
  List<Object?> get props => [slots];
}
