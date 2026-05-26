import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/events/domain/repositories/event_repository.dart';

class VerifyTicketUseCase
    implements UseCase<TicketVerificationResult, VerifyTicketParams> {
  const VerifyTicketUseCase(this._repository);
  final EventRepository _repository;

  @override
  Future<Either<Failure, TicketVerificationResult>> call(
    VerifyTicketParams params,
  ) => _repository.verifyTicket(
    eventId: params.eventId,
    qrData: params.qrData,
  );
}

class VerifyTicketParams extends Equatable {
  final String eventId;
  final String qrData;

  const VerifyTicketParams({required this.eventId, required this.qrData});

  @override
  List<Object?> get props => [eventId, qrData];
}
