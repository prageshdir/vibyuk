import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_dispute_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/repositories/booking_engine_repository.dart';

class GetDisputeUseCase
    extends UseCase<BookingDisputeEntity?, GetDisputeParams> {
  const GetDisputeUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, BookingDisputeEntity?>> call(
          GetDisputeParams params) =>
      _repository.getDispute(params.bookingId);
}

class OpenDisputeUseCase
    extends UseCase<BookingDisputeEntity, OpenDisputeParams> {
  const OpenDisputeUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, BookingDisputeEntity>> call(
          OpenDisputeParams params) =>
      _repository.openDispute(
        bookingId: params.bookingId,
        reason: params.reason,
        description: params.description,
      );
}

class RespondToDisputeUseCase
    extends UseCase<BookingDisputeEntity, RespondToDisputeParams> {
  const RespondToDisputeUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, BookingDisputeEntity>> call(
          RespondToDisputeParams params) =>
      _repository.respondToDispute(
        disputeId: params.disputeId,
        response: params.response,
      );
}

class GetDisputeParams extends Equatable {
  const GetDisputeParams({required this.bookingId});
  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

class OpenDisputeParams extends Equatable {
  const OpenDisputeParams({
    required this.bookingId,
    required this.reason,
    required this.description,
  });
  final String bookingId;
  final DisputeReason reason;
  final String description;

  @override
  List<Object?> get props => [bookingId, reason, description];
}

class RespondToDisputeParams extends Equatable {
  const RespondToDisputeParams(
      {required this.disputeId, required this.response});
  final String disputeId;
  final String response;

  @override
  List<Object?> get props => [disputeId, response];
}
