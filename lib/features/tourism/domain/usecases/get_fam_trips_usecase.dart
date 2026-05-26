import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/tourism/domain/entities/fam_trip_entity.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';

class GetFamTripsUseCase
    implements UseCase<PaginatedResponse<FamTripEntity>, GetFamTripsParams> {
  const GetFamTripsUseCase(this._repository);

  final TourismRepository _repository;

  @override
  Future<Either<Failure, PaginatedResponse<FamTripEntity>>> call(
      GetFamTripsParams params) {
    return _repository.getFamTrips(
      page: params.page,
      perPage: params.perPage,
      destinationId: params.destinationId,
      status: params.status,
    );
  }
}

class GetFamTripsParams extends Equatable {
  const GetFamTripsParams({
    this.page = 1,
    this.perPage = 20,
    this.destinationId,
    this.status,
  });

  final int page;
  final int perPage;
  final String? destinationId;
  final FamTripStatus? status;

  @override
  List<Object?> get props => [page, perPage, destinationId, status];
}
