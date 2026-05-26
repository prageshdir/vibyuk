import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_milestone_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/repositories/booking_engine_repository.dart';

class SubmitMilestoneUseCase
    extends UseCase<BookingMilestoneEntity, SubmitMilestoneParams> {
  const SubmitMilestoneUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, BookingMilestoneEntity>> call(
          SubmitMilestoneParams params) =>
      _repository.submitMilestone(
        bookingId: params.bookingId,
        milestoneId: params.milestoneId,
        deliverableUrl: params.deliverableUrl,
        notes: params.notes,
      );
}

class SubmitMilestoneParams extends Equatable {
  const SubmitMilestoneParams({
    required this.bookingId,
    required this.milestoneId,
    required this.deliverableUrl,
    this.notes,
  });
  final String bookingId;
  final String milestoneId;
  final String deliverableUrl;
  final String? notes;

  @override
  List<Object?> get props => [bookingId, milestoneId, deliverableUrl, notes];
}
