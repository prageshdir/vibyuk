import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/repositories/discovery_repository.dart';

class SaveRecentSearchUseCase implements UseCase<Unit, SaveRecentSearchParams> {
  SaveRecentSearchUseCase(this._repository);
  final DiscoveryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SaveRecentSearchParams params) {
    return _repository.saveRecentSearch(params.query);
  }
}

class SaveRecentSearchParams extends Equatable {
  const SaveRecentSearchParams({required this.query});
  final String query;

  @override
  List<Object?> get props => [query];
}
