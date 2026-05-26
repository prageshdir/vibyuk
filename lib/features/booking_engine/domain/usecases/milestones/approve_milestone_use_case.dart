import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_milestone_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/repositories/booking_engine_repository.dart';

class ApproveMilestoneUseCase
    extends UseCase<BookingMilestoneEntity, MilestoneActionParams> {
  const ApproveMilestoneUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, BookingMilestoneEntity>> call(
          MilestoneActionParams params) =>
      _repository.approveMilestone(
          bookingId: params.bookingId, milestoneId: params.milestoneId);
}

class RejectMilestoneUseCase
    extends UseCase<BookingMilestoneEntity, RejectMilestoneParams> {
  const RejectMilestoneUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, BookingMilestoneEntity>> call(
          RejectMilestoneParams params) =>
      _repository.rejectMilestone(
        bookingId: params.bookingId,
        milestoneId: params.milestoneId,
        reason: params.reason,
      );
}

class MilestoneActionParams extends Equatable {
  const MilestoneActionParams(
      {required this.bookingId, required this.milestoneId});
  final String bookingId;
  final String milestoneId;

  @override
  List<Object?> get props => [bookingId, milestoneId];
}

class RejectMilestoneParams extends Equatable {
  const RejectMilestoneParams({
    required this.bookingId,
    required this.milestoneId,
    required this.reason,
  });
  final String bookingId;
  final String milestoneId;
  final String reason;

  @override
  List<Object?> get props => [bookingId, milestoneId, reason];
}
