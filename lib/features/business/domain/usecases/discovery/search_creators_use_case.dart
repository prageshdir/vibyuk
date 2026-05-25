import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/creator_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/entities/search_filters_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/discovery_repository.dart';

class SearchCreatorsUseCase
    implements UseCase<PaginatedResult<CreatorEntity>, SearchCreatorsParams> {
  SearchCreatorsUseCase(this._repository);
  final DiscoveryRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<CreatorEntity>>> call(
      SearchCreatorsParams params) {
    return _repository.searchCreators(
      query: params.query,
      filters: params.filters,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class SearchCreatorsParams extends Equatable {
  const SearchCreatorsParams({
    required this.query,
    this.filters = const SearchFiltersEntity.empty(),
    this.page = 1,
    this.pageSize = 20,
  });

  final String query;
  final SearchFiltersEntity filters;
  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [query, filters, page, pageSize];
}
