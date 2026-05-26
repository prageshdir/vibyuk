import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_reschedule_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/repositories/booking_engine_repository.dart';

class RequestRescheduleUseCase
    extends UseCase<BookingRescheduleEntity, RequestRescheduleParams> {
  const RequestRescheduleUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, BookingRescheduleEntity>> call(
          RequestRescheduleParams params) =>
      _repository.requestReschedule(
        bookingId: params.bookingId,
        newDate: params.newDate,
        reason: params.reason,
      );
}

class RespondToRescheduleUseCase
    extends UseCase<BookingRescheduleEntity, RespondToRescheduleParams> {
  const RespondToRescheduleUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, BookingRescheduleEntity>> call(
          RespondToRescheduleParams params) =>
      _repository.respondToReschedule(
        rescheduleId: params.rescheduleId,
        accept: params.accept,
        declineReason: params.declineReason,
      );
}

class RequestRescheduleParams extends Equatable {
  const RequestRescheduleParams({
    required this.bookingId,
    required this.newDate,
    this.reason,
  });
  final String bookingId;
  final DateTime newDate;
  final String? reason;

  @override
  List<Object?> get props => [bookingId, newDate, reason];
}

class RespondToRescheduleParams extends Equatable {
  const RespondToRescheduleParams({
    required this.rescheduleId,
    required this.accept,
    this.declineReason,
  });
  final String rescheduleId;
  final bool accept;
  final String? declineReason;

  @override
  List<Object?> get props => [rescheduleId, accept, declineReason];
}
