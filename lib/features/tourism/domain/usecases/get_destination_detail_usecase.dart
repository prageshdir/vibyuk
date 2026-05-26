import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';

class GetDestinationDetailUseCase
    implements UseCase<TourismDestinationEntity, DestinationIdParams> {
  const GetDestinationDetailUseCase(this._repository);

  final TourismRepository _repository;

  @override
  Future<Either<Failure, TourismDestinationEntity>> call(DestinationIdParams params) {
    return _repository.getDestinationDetail(params.id);
  }
}

class DestinationIdParams extends Equatable {
  const DestinationIdParams(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
