import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/tourism/domain/entities/fam_trip_entity.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';

class GetFamTripDetailUseCase
    implements UseCase<FamTripEntity, FamTripIdParams> {
  const GetFamTripDetailUseCase(this._repository);

  final TourismRepository _repository;

  @override
  Future<Either<Failure, FamTripEntity>> call(FamTripIdParams params) {
    return _repository.getFamTripDetail(params.id);
  }
}

class FamTripIdParams extends Equatable {
  const FamTripIdParams(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
