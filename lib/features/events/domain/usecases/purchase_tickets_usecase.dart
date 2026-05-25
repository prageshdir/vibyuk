import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_purchase_entity.dart';
import 'package:vibyuk/features/events/domain/repositories/event_repository.dart';

class PurchaseTicketsUseCase
    implements UseCase<TicketPurchaseEntity, PurchaseTicketsParams> {
  const PurchaseTicketsUseCase(this._repository);
  final EventRepository _repository;

  @override
  Future<Either<Failure, TicketPurchaseEntity>> call(
    PurchaseTicketsParams params,
  ) => _repository.purchaseTickets(
    eventId: params.eventId,
    lines: params.lines,
    paymentMethodId: params.paymentMethodId,
  );
}

class PurchaseTicketsParams extends Equatable {
  final String eventId;
  final List<TicketOrderLine> lines;
  final String paymentMethodId;

  const PurchaseTicketsParams({
    required this.eventId,
    required this.lines,
    required this.paymentMethodId,
  });

  @override
  List<Object?> get props => [eventId, lines, paymentMethodId];
}
