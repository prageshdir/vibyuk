import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';

class GetFeaturedDestinationsUseCase
    implements NoParamUseCase<List<TourismDestinationEntity>> {
  const GetFeaturedDestinationsUseCase(this._repository);

  final TourismRepository _repository;

  @override
  Future<Either<Failure, List<TourismDestinationEntity>>> call() {
    return _repository.getFeaturedDestinations();
  }
}
