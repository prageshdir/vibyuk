import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/events/data/datasources/event_local_datasource.dart';
import 'package:vibyuk/features/events/data/datasources/event_remote_datasource.dart';
import 'package:vibyuk/features/events/domain/entities/event_analytics_entity.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/entities/event_form_data.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_entity.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_purchase_entity.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_type_entity.dart';
import 'package:vibyuk/features/events/domain/repositories/event_repository.dart';

class EventRepositoryImpl extends BaseRepository implements EventRepository {
  const EventRepositoryImpl({
    required EventLocalDataSource local,
    required EventRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final EventLocalDataSource _local;
  final EventRemoteDataSource _remote;

  // ── Events ───────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResponse<EventEntity>>> getEvents({
    int page = 1,
    int perPage = 20,
    EventCategory? category,
    String? query,
    bool myEventsOnly = false,
  }) {
    return safeCall(() async {
      final localPage = await _local.getEvents(
        page: page,
        perPage: perPage,
        category: category,
        query: query,
        myEventsOnly: myEventsOnly,
      );

      if (page == 1) {
        _syncEventsFromRemote(
          page: page,
          perPage: perPage,
          category: category,
          query: query,
          myEventsOnly: myEventsOnly,
        );
      }

      AppLogger.debug(
          'EventRepository.getEvents: serving ${localPage.items.length} cached events (page $page)');
      return localPage;
    }, context: 'EventRepository.getEvents');
  }

  Future<void> _syncEventsFromRemote({
    required int page,
    required int perPage,
    EventCategory? category,
    String? query,
    required bool myEventsOnly,
  }) async {
    try {
      final remote = await _remote.getEvents(
        page: page,
        perPage: perPage,
        category: category,
        query: query,
        myEventsOnly: myEventsOnly,
      );
      for (final event in remote.items) {
        await _local.cacheEvent(event, isMine: myEventsOnly);
      }
      AppLogger.debug(
          'EventRepository._syncEventsFromRemote: cached ${remote.items.length} events');
    } catch (_) {
      // Silent fail — local cache is the source of truth for the UI
    }
  }

  @override
  Future<Either<Failure, EventEntity>> getEventDetail(String eventId) {
    return safeCall(() async {
      final cached = await _local.getEventDetail(eventId);
      if (cached != null) {
        AppLogger.debug(
            'EventRepository.getEventDetail: serving from cache id=$eventId');
        return cached;
      }
      final remote = await _remote.getEventDetail(eventId);
      await _local.cacheEvent(remote);
      AppLogger.debug(
          'EventRepository.getEventDetail: fetched from remote id=$eventId');
      return remote;
    }, context: 'EventRepository.getEventDetail');
  }

  @override
  Future<Either<Failure, EventEntity>> createEvent(EventFormData formData) {
    return safeCall(() async {
      final event = await _remote.createEvent(formData);
      await _local.cacheEvent(event, isMine: true);
      AppLogger.debug('EventRepository.createEvent: created id=${event.id}');
      return event;
    }, context: 'EventRepository.createEvent');
  }

  @override
  Future<Either<Failure, EventEntity>> updateEvent(
    String eventId,
    EventFormData formData,
  ) {
    return safeCall(() async {
      final event = await _remote.updateEvent(eventId, formData);
      await _local.cacheEvent(event, isMine: true);
      AppLogger.debug('EventRepository.updateEvent: updated id=$eventId');
      return event;
    }, context: 'EventRepository.updateEvent');
  }

  @override
  Future<Either<Failure, Unit>> deleteEvent(String eventId) {
    return safeCall(() async {
      await _remote.deleteEvent(eventId);
      AppLogger.debug('EventRepository.deleteEvent: deleted id=$eventId');
      return unit;
    }, context: 'EventRepository.deleteEvent');
  }

  @override
  Future<Either<Failure, EventEntity>> publishEvent(String eventId) {
    return safeCall(() async {
      final event = await _remote.publishEvent(eventId);
      await _local.cacheEvent(event, isMine: true);
      AppLogger.debug('EventRepository.publishEvent: published id=$eventId');
      return event;
    }, context: 'EventRepository.publishEvent');
  }

  @override
  Future<Either<Failure, EventEntity>> cancelEvent(
    String eventId,
    String reason,
  ) {
    return safeCall(() async {
      final event = await _remote.cancelEvent(eventId, reason);
      await _local.cacheEvent(event, isMine: true);
      AppLogger.debug('EventRepository.cancelEvent: cancelled id=$eventId');
      return event;
    }, context: 'EventRepository.cancelEvent');
  }

  // ── Ticket Types ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, TicketTypeEntity>> createTicketType(
    String eventId,
    TicketTypeFormData data,
  ) {
    return safeCall(() async {
      final ticketType = await _remote.createTicketType(eventId, data);
      AppLogger.debug(
          'EventRepository.createTicketType: created id=${ticketType.id} event=$eventId');
      return ticketType;
    }, context: 'EventRepository.createTicketType');
  }

  @override
  Future<Either<Failure, TicketTypeEntity>> updateTicketType(
    String eventId,
    String typeId,
    TicketTypeFormData data,
  ) {
    return safeCall(() async {
      final ticketType = await _remote.updateTicketType(eventId, typeId, data);
      AppLogger.debug(
          'EventRepository.updateTicketType: updated id=$typeId event=$eventId');
      return ticketType;
    }, context: 'EventRepository.updateTicketType');
  }

  @override
  Future<Either<Failure, Unit>> deleteTicketType(
    String eventId,
    String typeId,
  ) {
    return safeCall(() async {
      await _remote.deleteTicketType(eventId, typeId);
      AppLogger.debug(
          'EventRepository.deleteTicketType: deleted id=$typeId event=$eventId');
      return unit;
    }, context: 'EventRepository.deleteTicketType');
  }

  // ── Ticket Purchase ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, TicketPurchaseEntity>> purchaseTickets({
    required String eventId,
    required List<TicketOrderLine> lines,
    required String paymentMethodId,
  }) {
    return safeCall(() async {
      final purchase = await _remote.purchaseTickets(
        eventId: eventId,
        lines: lines,
        paymentMethodId: paymentMethodId,
      );
      // Cache all issued tickets locally
      for (final ticket in purchase.tickets) {
        await _local.cacheTicket(ticket);
      }
      AppLogger.debug(
          'EventRepository.purchaseTickets: purchased ${purchase.tickets.length} tickets for event=$eventId');
      return purchase;
    }, context: 'EventRepository.purchaseTickets');
  }

  // ── My Tickets ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResponse<TicketEntity>>> getMyTickets({
    int page = 1,
    int perPage = 20,
    TicketStatus? statusFilter,
  }) {
    return safeCall(() async {
      final localPage = await _local.getMyTickets(
        page: page,
        perPage: perPage,
        statusFilter: statusFilter,
      );

      if (page == 1) {
        _syncTicketsFromRemote(
          page: page,
          perPage: perPage,
          statusFilter: statusFilter,
        );
      }

      AppLogger.debug(
          'EventRepository.getMyTickets: serving ${localPage.items.length} cached tickets (page $page)');
      return localPage;
    }, context: 'EventRepository.getMyTickets');
  }

  Future<void> _syncTicketsFromRemote({
    required int page,
    required int perPage,
    TicketStatus? statusFilter,
  }) async {
    try {
      final remote = await _remote.getMyTickets(
        page: page,
        perPage: perPage,
        statusFilter: statusFilter,
      );
      for (final ticket in remote.items) {
        await _local.cacheTicket(ticket);
      }
      AppLogger.debug(
          'EventRepository._syncTicketsFromRemote: cached ${remote.items.length} tickets');
    } catch (_) {
      // Silent fail — local cache is the source of truth for the UI
    }
  }

  @override
  Future<Either<Failure, TicketEntity>> getTicketDetail(String ticketId) {
    return safeCall(() async {
      final cached = await _local.getTicketDetail(ticketId);
      if (cached != null) {
        AppLogger.debug(
            'EventRepository.getTicketDetail: serving from cache id=$ticketId');
        return cached;
      }
      final remote = await _remote.getTicketDetail(ticketId);
      await _local.cacheTicket(remote);
      AppLogger.debug(
          'EventRepository.getTicketDetail: fetched from remote id=$ticketId');
      return remote;
    }, context: 'EventRepository.getTicketDetail');
  }

  // ── Ticket Operations ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, TicketVerificationResult>> verifyTicket({
    required String eventId,
    required String qrData,
  }) {
    return safeCall(() async {
      final result = await _remote.verifyTicket(
        eventId: eventId,
        qrData: qrData,
      );
      AppLogger.debug(
          'EventRepository.verifyTicket: valid=${result.isValid} event=$eventId');
      return result;
    }, context: 'EventRepository.verifyTicket');
  }

  @override
  Future<Either<Failure, TicketEntity>> checkInTicket(String ticketId) {
    return safeCall(() async {
      final updatedTicket = await _remote.checkInTicket(ticketId);
      await _local.cacheTicket(updatedTicket);
      AppLogger.debug(
          'EventRepository.checkInTicket: checked in id=$ticketId');
      return updatedTicket;
    }, context: 'EventRepository.checkInTicket');
  }

  @override
  Future<Either<Failure, Unit>> requestRefund({
    required String ticketId,
    required String reason,
  }) {
    return safeCall(() async {
      await _remote.requestRefund(ticketId: ticketId, reason: reason);
      AppLogger.debug(
          'EventRepository.requestRefund: requested for id=$ticketId');
      return unit;
    }, context: 'EventRepository.requestRefund');
  }

  // ── Analytics ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, EventAnalyticsEntity>> getEventAnalytics(
    String eventId,
  ) {
    return safeCall(() async {
      final cached = await _local.getCachedAnalytics(eventId);
      if (cached != null) {
        AppLogger.debug(
            'EventRepository.getEventAnalytics: serving from cache event=$eventId');
        return cached;
      }
      final remote = await _remote.getEventAnalytics(eventId);
      await _local.cacheAnalytics(eventId, remote);
      AppLogger.debug(
          'EventRepository.getEventAnalytics: fetched from remote event=$eventId');
      return remote;
    }, context: 'EventRepository.getEventAnalytics');
  }

  // ── Cover Image ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, String>> uploadEventCover({
    required String eventId,
    required String filePath,
  }) {
    return safeCall(() async {
      final url = await _remote.uploadEventCover(
        eventId: eventId,
        filePath: filePath,
      );
      AppLogger.debug(
          'EventRepository.uploadEventCover: uploaded for event=$eventId -> $url');
      return url;
    }, context: 'EventRepository.uploadEventCover');
  }
}
