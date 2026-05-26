import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/data/datasources/discovery_local_data_source.dart';
import 'package:vibyuk/features/business/data/datasources/discovery_remote_data_source.dart';
import 'package:vibyuk/features/business/data/dtos/search_filters_dto.dart';
import 'package:vibyuk/features/business/data/models/creator_model.dart';
import 'package:vibyuk/features/business/domain/entities/creator_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/entities/search_filters_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/discovery_repository.dart';

class DiscoveryRepositoryImpl extends BaseRepository implements DiscoveryRepository {
  DiscoveryRepositoryImpl({
    required DiscoveryRemoteDataSource remoteDataSource,
    required DiscoveryLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final DiscoveryRemoteDataSource _remote;
  final DiscoveryLocalDataSource _local;

  PaginatedResult<CreatorEntity> _parsePaginated(Map<String, dynamic> data) {
    final items = (data['items'] as List? ?? data['data'] as List? ?? [])
        .map((e) => CreatorModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
    return PaginatedResult<CreatorEntity>(
      items: items,
      currentPage: data['current_page'] as int? ?? data['page'] as int? ?? 1,
      totalPages: data['total_pages'] as int? ?? 1,
      totalItems: data['total_items'] as int? ?? items.length,
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<CreatorEntity>>> searchCreators({
    required String query,
    required SearchFiltersEntity filters,
    required int page,
    int pageSize = 20,
  }) =>
      safeCall(() async {
        final params = {
          'q': query,
          'page': page,
          'page_size': pageSize,
          ...SearchFiltersDto(filters).toQueryParams(),
        };
        final data = await _remote.searchCreators(params);
        return _parsePaginated(data);
      });

  @override
  Future<Either<Failure, CreatorEntity>> getCreatorDetail(String creatorId) =>
      safeCall(() async {
        final data = await _remote.getCreatorDetail(creatorId);
        return CreatorModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, Unit>> saveCreator(String creatorId) =>
      safeCall(() async {
        await _remote.saveCreator(creatorId);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> unsaveCreator(String creatorId) =>
      safeCall(() async {
        await _remote.unsaveCreator(creatorId);
        return unit;
      });

  @override
  Future<Either<Failure, PaginatedResult<CreatorEntity>>> getSavedCreators({
    required int page,
    int pageSize = 20,
  }) =>
      safeCall(() async {
        final data = await _remote.getSavedCreators(page, pageSize);
        return _parsePaginated(data);
      });

  @override
  Future<Either<Failure, List<CreatorEntity>>> getFeaturedCreators() =>
      safeCall(() async {
        final list = await _remote.getFeaturedCreators();
        return list
            .map((e) =>
                CreatorModel.fromJson(e as Map<String, dynamic>).toEntity())
            .toList();
      });

  @override
  Future<Either<Failure, List<String>>> getRecentSearches() =>
      safeCall(() => _local.getRecentSearches());

  @override
  Future<Either<Failure, Unit>> saveRecentSearch(String query) =>
      safeCall(() async {
        await _local.saveRecentSearch(query);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> clearRecentSearches() =>
      safeCall(() async {
        await _local.clearRecentSearches();
        return unit;
      });
}
