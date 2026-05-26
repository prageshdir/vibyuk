import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/availability_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class GetAvailabilityUseCase extends UseCase<AvailabilityEntity, NoParams> {
  final CreatorRepository _repository;
  const GetAvailabilityUseCase(this._repository);

  @override
  Future<Either<Failure, AvailabilityEntity>> call(NoParams params) =>
      _repository.getAvailability();
}
