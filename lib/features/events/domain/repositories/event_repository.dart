import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/events/domain/entities/event_analytics_entity.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/entities/event_form_data.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_entity.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_purchase_entity.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_type_entity.dart';

abstract interface class EventRepository {
  Future<Either<Failure, PaginatedResponse<EventEntity>>> getEvents({
    int page = 1,
    int perPage = 20,
    EventCategory? category,
    String? query,
    bool myEventsOnly = false,
  });

  Future<Either<Failure, EventEntity>> getEventDetail(String eventId);

  Future<Either<Failure, EventEntity>> createEvent(EventFormData formData);

  Future<Either<Failure, EventEntity>> updateEvent(
    String eventId,
    EventFormData formData,
  );

  Future<Either<Failure, Unit>> deleteEvent(String eventId);

  Future<Either<Failure, EventEntity>> publishEvent(String eventId);

  Future<Either<Failure, EventEntity>> cancelEvent(
    String eventId,
    String reason,
  );

  Future<Either<Failure, TicketTypeEntity>> createTicketType(
    String eventId,
    TicketTypeFormData data,
  );

  Future<Either<Failure, TicketTypeEntity>> updateTicketType(
    String eventId,
    String typeId,
    TicketTypeFormData data,
  );

  Future<Either<Failure, Unit>> deleteTicketType(
    String eventId,
    String typeId,
  );

  Future<Either<Failure, TicketPurchaseEntity>> purchaseTickets({
    required String eventId,
    required List<TicketOrderLine> lines,
    required String paymentMethodId,
  });

  Future<Either<Failure, PaginatedResponse<TicketEntity>>> getMyTickets({
    int page = 1,
    int perPage = 20,
    TicketStatus? statusFilter,
  });

  Future<Either<Failure, TicketEntity>> getTicketDetail(String ticketId);

  Future<Either<Failure, TicketVerificationResult>> verifyTicket({
    required String eventId,
    required String qrData,
  });

  Future<Either<Failure, TicketEntity>> checkInTicket(String ticketId);

  Future<Either<Failure, Unit>> requestRefund({
    required String ticketId,
    required String reason,
  });

  Future<Either<Failure, EventAnalyticsEntity>> getEventAnalytics(
    String eventId,
  );

  Future<Either<Failure, String>> uploadEventCover({
    required String eventId,
    required String filePath,
  });
}

class TicketVerificationResult extends Equatable {
  final bool isValid;
  final String? ticketId;
  final String? ownerName;
  final String? ticketTypeName;
  final TicketStatus? ticketStatus;
  final String? errorMessage;

  const TicketVerificationResult({
    required this.isValid,
    this.ticketId,
    this.ownerName,
    this.ticketTypeName,
    this.ticketStatus,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isValid, ticketId, ownerName,
    ticketTypeName, ticketStatus, errorMessage];
}
