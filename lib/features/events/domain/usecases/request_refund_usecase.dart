import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/events/domain/repositories/event_repository.dart';

class RequestRefundUseCase implements UseCase<Unit, RequestRefundParams> {
  const RequestRefundUseCase(this._repository);
  final EventRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(RequestRefundParams params) =>
      _repository.requestRefund(
        ticketId: params.ticketId,
        reason: params.reason,
      );
}

class RequestRefundParams extends Equatable {
  final String ticketId;
  final String reason;

  const RequestRefundParams({required this.ticketId, required this.reason});

  @override
  List<Object?> get props => [ticketId, reason];
}
