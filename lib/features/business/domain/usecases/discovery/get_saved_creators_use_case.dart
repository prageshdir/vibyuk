import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/creator_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/repositories/discovery_repository.dart';

class GetSavedCreatorsUseCase
    implements UseCase<PaginatedResult<CreatorEntity>, GetSavedCreatorsParams> {
  GetSavedCreatorsUseCase(this._repository);
  final DiscoveryRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<CreatorEntity>>> call(
      GetSavedCreatorsParams params) {
    return _repository.getSavedCreators(page: params.page, pageSize: params.pageSize);
  }
}

class GetSavedCreatorsParams extends Equatable {
  const GetSavedCreatorsParams({this.page = 1, this.pageSize = 20});
  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [page, pageSize];
}
