import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';

class GetDestinationsUseCase
    implements UseCase<PaginatedResponse<TourismDestinationEntity>, GetDestinationsParams> {
  const GetDestinationsUseCase(this._repository);

  final TourismRepository _repository;

  @override
  Future<Either<Failure, PaginatedResponse<TourismDestinationEntity>>> call(
      GetDestinationsParams params) {
    return _repository.getDestinations(
      page: params.page,
      perPage: params.perPage,
      category: params.category,
      region: params.region,
      query: params.query,
      featuredOnly: params.featuredOnly,
    );
  }
}

class GetDestinationsParams extends Equatable {
  const GetDestinationsParams({
    this.page = 1,
    this.perPage = 20,
    this.category,
    this.region,
    this.query,
    this.featuredOnly = false,
  });

  final int page;
  final int perPage;
  final String? category;
  final String? region;
  final String? query;
  final bool featuredOnly;

  @override
  List<Object?> get props => [page, perPage, category, region, query, featuredOnly];
}
