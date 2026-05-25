import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_entity.dart';
import 'package:vibyuk/features/events/domain/repositories/event_repository.dart';

class GetTicketDetailUseCase implements UseCase<TicketEntity, TicketIdParams> {
  const GetTicketDetailUseCase(this._repository);
  final EventRepository _repository;

  @override
  Future<Either<Failure, TicketEntity>> call(TicketIdParams params) =>
      _repository.getTicketDetail(params.ticketId);
}

class TicketIdParams extends Equatable {
  final String ticketId;
  const TicketIdParams(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}
