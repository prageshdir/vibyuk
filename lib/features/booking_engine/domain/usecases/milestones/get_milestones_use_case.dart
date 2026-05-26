import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_milestone_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/repositories/booking_engine_repository.dart';

class GetMilestonesUseCase
    extends UseCase<List<BookingMilestoneEntity>, GetMilestonesParams> {
  const GetMilestonesUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, List<BookingMilestoneEntity>>> call(
          GetMilestonesParams params) =>
      _repository.getMilestones(params.bookingId);
}

class GetMilestonesParams extends Equatable {
  const GetMilestonesParams({required this.bookingId});
  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}
