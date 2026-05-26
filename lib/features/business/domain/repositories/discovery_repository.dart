import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/creator_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/entities/search_filters_entity.dart';

abstract interface class DiscoveryRepository {
  Future<Either<Failure, PaginatedResult<CreatorEntity>>> searchCreators({
    required String query,
    required SearchFiltersEntity filters,
    required int page,
    int pageSize = 20,
  });

  Future<Either<Failure, CreatorEntity>> getCreatorDetail(String creatorId);

  Future<Either<Failure, Unit>> saveCreator(String creatorId);

  Future<Either<Failure, Unit>> unsaveCreator(String creatorId);

  Future<Either<Failure, PaginatedResult<CreatorEntity>>> getSavedCreators({
    required int page,
    int pageSize = 20,
  });

  Future<Either<Failure, List<CreatorEntity>>> getFeaturedCreators();

  Future<Either<Failure, List<String>>> getRecentSearches();

  Future<Either<Failure, Unit>> saveRecentSearch(String query);

  Future<Either<Failure, Unit>> clearRecentSearches();
}
