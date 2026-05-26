import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/creator_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/discovery_repository.dart';

class GetFeaturedCreatorsUseCase implements NoParamUseCase<List<CreatorEntity>> {
  GetFeaturedCreatorsUseCase(this._repository);
  final DiscoveryRepository _repository;

  @override
  Future<Either<Failure, List<CreatorEntity>>> call() {
    return _repository.getFeaturedCreators();
  }
}
