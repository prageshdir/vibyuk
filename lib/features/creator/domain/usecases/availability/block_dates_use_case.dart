import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/availability_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class BlockDatesUseCase extends UseCase<AvailabilityEntity, BlockDatesParams> {
  final CreatorRepository _repository;
  const BlockDatesUseCase(this._repository);

  @override
  Future<Either<Failure, AvailabilityEntity>> call(BlockDatesParams params) =>
      _repository.blockDates(dates: params.dates);
}

class BlockDatesParams extends Equatable {
  final List<DateTime> dates;
  const BlockDatesParams({required this.dates});

  @override
  List<Object?> get props => [dates];
}
