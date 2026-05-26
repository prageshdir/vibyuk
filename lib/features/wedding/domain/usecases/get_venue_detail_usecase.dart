import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_venue_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class GetVenueDetailUseCase
    extends UseCase<WeddingVenueEntity, VenueIdParams> {
  const GetVenueDetailUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, WeddingVenueEntity>> call(VenueIdParams params) =>
      _repository.getVenueDetail(params.venueId);
}

class VenueIdParams extends Equatable {
  const VenueIdParams(this.venueId);
  final String venueId;

  @override
  List<Object?> get props => [venueId];
}
