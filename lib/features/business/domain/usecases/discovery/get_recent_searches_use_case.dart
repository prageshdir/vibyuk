import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/repositories/discovery_repository.dart';

class GetRecentSearchesUseCase implements NoParamUseCase<List<String>> {
  GetRecentSearchesUseCase(this._repository);
  final DiscoveryRepository _repository;

  @override
  Future<Either<Failure, List<String>>> call() {
    return _repository.getRecentSearches();
  }
}
