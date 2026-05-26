import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/network/paginated_response.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_venue_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class GetVenuesUseCase
    extends UseCase<PaginatedResponse<WeddingVenueEntity>, GetVenuesParams> {
  const GetVenuesUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, PaginatedResponse<WeddingVenueEntity>>> call(
    GetVenuesParams params,
  ) =>
      _repository.getVenues(
        page: params.page,
        perPage: params.perPage,
        query: params.query,
      );
}

class GetVenuesParams extends Equatable {
  const GetVenuesParams({
    this.page = 1,
    this.perPage = 20,
    this.query,
  });

  final int page;
  final int perPage;
  final String? query;

  @override
  List<Object?> get props => [page, perPage, query];
}
