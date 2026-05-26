import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/events/data/models/event_analytics_dto.dart';
import 'package:vibyuk/features/events/data/models/event_dto.dart';
import 'package:vibyuk/features/events/data/models/ticket_dto.dart';
import 'package:vibyuk/features/events/data/models/ticket_purchase_dto.dart';
import 'package:vibyuk/features/events/data/models/ticket_type_dto.dart';
import 'package:vibyuk/features/events/domain/entities/event_analytics_entity.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/entities/event_form_data.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_entity.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_purchase_entity.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_type_entity.dart';
import 'package:vibyuk/features/events/domain/repositories/event_repository.dart';

abstract interface class EventRemoteDataSource {
  Future<PaginatedResponse<EventEntity>> getEvents({
    int page,
    int perPage,
    EventCategory? category,
    String? query,
    bool myEventsOnly,
  });

  Future<EventEntity> getEventDetail(String id);

  Future<EventEntity> createEvent(EventFormData formData);

  Future<EventEntity> updateEvent(String eventId, EventFormData formData);

  Future<void> deleteEvent(String eventId);

  Future<EventEntity> publishEvent(String eventId);

  Future<EventEntity> cancelEvent(String eventId, String reason);

  Future<TicketTypeEntity> createTicketType(
    String eventId,
    TicketTypeFormData data,
  );

  Future<TicketTypeEntity> updateTicketType(
    String eventId,
    String typeId,
    TicketTypeFormData data,
  );

  Future<void> deleteTicketType(String eventId, String typeId);

  Future<TicketPurchaseEntity> purchaseTickets({
    required String eventId,
    required List<TicketOrderLine> lines,
    required String paymentMethodId,
  });

  Future<PaginatedResponse<TicketEntity>> getMyTickets({
    int page,
    int perPage,
    TicketStatus? statusFilter,
  });

  Future<TicketEntity> getTicketDetail(String ticketId);

  Future<TicketVerificationResult> verifyTicket({
    required String eventId,
    required String qrData,
  });

  Future<TicketEntity> checkInTicket(String ticketId);

  Future<void> requestRefund({
    required String ticketId,
    required String reason,
  });

  Future<EventAnalyticsEntity> getEventAnalytics(String eventId);

  Future<String> uploadEventCover({
    required String eventId,
    required String filePath,
  });
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  const EventRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  // ── Events ──────────────────────────────────────────────────────────────────

  @override
  Future<PaginatedResponse<EventEntity>> getEvents({
    int page = 1,
    int perPage = 20,
    EventCategory? category,
    String? query,
    bool myEventsOnly = false,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.events,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (category != null) 'category': category.name,
        if (query != null && query.isNotEmpty) 'q': query,
        if (myEventsOnly) 'mine': true,
      },
    );

    final payload = response.data ?? {};
    final items = (payload['data'] as List<dynamic>? ?? [])
        .map((e) =>
            EventDto.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
    final meta = payload['meta'] as Map<String, dynamic>? ?? {};

    AppLogger.debug(
        'EventRemoteDataSource.getEvents: fetched ${items.length} events (page $page)');

    return PaginatedResponse.fromApiResponse<EventEntity>(
      items: items,
      meta: meta,
    );
  }

  @override
  Future<EventEntity> getEventDetail(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.eventById(id),
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug('EventRemoteDataSource.getEventDetail: $id');
    return EventDto.fromJson(data).toEntity();
  }

  @override
  Future<EventEntity> createEvent(EventFormData formData) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.events,
      data: _formDataToJson(formData),
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug('EventRemoteDataSource.createEvent');
    return EventDto.fromJson(data).toEntity();
  }

  @override
  Future<EventEntity> updateEvent(
    String eventId,
    EventFormData formData,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.eventById(eventId),
      data: _formDataToJson(formData),
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug('EventRemoteDataSource.updateEvent: $eventId');
    return EventDto.fromJson(data).toEntity();
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _dio.delete<void>(ApiEndpoints.eventById(eventId));
    AppLogger.debug('EventRemoteDataSource.deleteEvent: $eventId');
  }

  @override
  Future<EventEntity> publishEvent(String eventId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.publishEvent(eventId),
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug('EventRemoteDataSource.publishEvent: $eventId');
    return EventDto.fromJson(data).toEntity();
  }

  @override
  Future<EventEntity> cancelEvent(String eventId, String reason) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.cancelEvent(eventId),
      data: {'reason': reason},
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug('EventRemoteDataSource.cancelEvent: $eventId');
    return EventDto.fromJson(data).toEntity();
  }

  // ── Ticket Types ─────────────────────────────────────────────────────────────

  @override
  Future<TicketTypeEntity> createTicketType(
    String eventId,
    TicketTypeFormData data,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.eventTicketTypes(eventId),
      data: _ticketTypeFormDataToJson(data),
    );
    final payload = response.data ?? {};
    final resData = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug(
        'EventRemoteDataSource.createTicketType: event=$eventId');
    return TicketTypeDto.fromJson(resData).toEntity();
  }

  @override
  Future<TicketTypeEntity> updateTicketType(
    String eventId,
    String typeId,
    TicketTypeFormData data,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.eventTicketType(eventId, typeId),
      data: _ticketTypeFormDataToJson(data),
    );
    final payload = response.data ?? {};
    final resData = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug(
        'EventRemoteDataSource.updateTicketType: event=$eventId type=$typeId');
    return TicketTypeDto.fromJson(resData).toEntity();
  }

  @override
  Future<void> deleteTicketType(String eventId, String typeId) async {
    await _dio.delete<void>(ApiEndpoints.eventTicketType(eventId, typeId));
    AppLogger.debug(
        'EventRemoteDataSource.deleteTicketType: event=$eventId type=$typeId');
  }

  // ── Ticket Purchase ──────────────────────────────────────────────────────────

  @override
  Future<TicketPurchaseEntity> purchaseTickets({
    required String eventId,
    required List<TicketOrderLine> lines,
    required String paymentMethodId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.purchaseTickets(eventId),
      data: {
        'payment_method_id': paymentMethodId,
        'lines': lines
            .map((l) => {
                  'ticket_type_id': l.ticketTypeId,
                  'quantity': l.quantity,
                })
            .toList(),
      },
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug(
        'EventRemoteDataSource.purchaseTickets: event=$eventId');
    return TicketPurchaseDto.fromJson(data).toEntity();
  }

  // ── My Tickets ───────────────────────────────────────────────────────────────

  @override
  Future<PaginatedResponse<TicketEntity>> getMyTickets({
    int page = 1,
    int perPage = 20,
    TicketStatus? statusFilter,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.myTickets,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (statusFilter != null) 'status': statusFilter.name,
      },
    );

    final payload = response.data ?? {};
    final items = (payload['data'] as List<dynamic>? ?? [])
        .map((e) =>
            TicketDto.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
    final meta = payload['meta'] as Map<String, dynamic>? ?? {};

    AppLogger.debug(
        'EventRemoteDataSource.getMyTickets: fetched ${items.length} tickets (page $page)');

    return PaginatedResponse.fromApiResponse<TicketEntity>(
      items: items,
      meta: meta,
    );
  }

  @override
  Future<TicketEntity> getTicketDetail(String ticketId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.ticketById(ticketId),
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug('EventRemoteDataSource.getTicketDetail: $ticketId');
    return TicketDto.fromJson(data).toEntity();
  }

  @override
  Future<TicketVerificationResult> verifyTicket({
    required String eventId,
    required String qrData,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.verifyTicket(eventId),
      data: {'qr_data': qrData},
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug(
        'EventRemoteDataSource.verifyTicket: event=$eventId');
    return _parseVerifyResponse(data);
  }

  @override
  Future<TicketEntity> checkInTicket(String ticketId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.checkInTicket(ticketId),
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug('EventRemoteDataSource.checkInTicket: $ticketId');
    return TicketDto.fromJson(data).toEntity();
  }

  @override
  Future<void> requestRefund({
    required String ticketId,
    required String reason,
  }) async {
    await _dio.post<void>(
      ApiEndpoints.requestRefund(ticketId),
      data: {'reason': reason},
    );
    AppLogger.debug('EventRemoteDataSource.requestRefund: $ticketId');
  }

  // ── Analytics ────────────────────────────────────────────────────────────────

  @override
  Future<EventAnalyticsEntity> getEventAnalytics(String eventId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.eventAnalytics(eventId),
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug(
        'EventRemoteDataSource.getEventAnalytics: $eventId');
    return EventAnalyticsDto.fromJson(data).toEntity();
  }

  // ── Cover image ──────────────────────────────────────────────────────────────

  @override
  Future<String> uploadEventCover({
    required String eventId,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.uploadEventCover(eventId),
      data: formData,
    );
    final payload = response.data ?? {};
    final url = (payload['data'] as Map<String, dynamic>?)?['url'] as String? ??
        (payload['url'] as String? ?? '');
    AppLogger.debug(
        'EventRemoteDataSource.uploadEventCover: $eventId -> $url');
    return url;
  }

  // ── Serialization helpers ────────────────────────────────────────────────────

  Map<String, dynamic> _formDataToJson(EventFormData data) => {
        'title': data.title,
        'description': data.description,
        'category': data.category.name,
        'start_date': data.startDate?.toIso8601String(),
        'end_date': data.endDate?.toIso8601String(),
        'venue_name': data.venueName,
        'venue_address': data.venueAddress,
        'is_online': data.isOnline,
        'stream_url': data.streamUrl,
        'ticket_types': data.ticketTypes
            .map((t) => {
                  'id': t.id,
                  'name': t.name,
                  'tier': t.tier.name,
                  'price': t.price,
                  'quantity': t.quantity,
                  'max_per_order': t.maxPerOrder,
                  'perks': t.perks,
                  'sale_end_date': t.saleEndDate?.toIso8601String(),
                })
            .toList(),
      };

  Map<String, dynamic> _ticketTypeFormDataToJson(TicketTypeFormData data) => {
        if (data.id != null) 'id': data.id,
        'name': data.name,
        'tier': data.tier.name,
        'price': data.price,
        'quantity': data.quantity,
        'max_per_order': data.maxPerOrder,
        'perks': data.perks,
        if (data.saleEndDate != null)
          'sale_end_date': data.saleEndDate!.toIso8601String(),
      };

  TicketVerificationResult _parseVerifyResponse(Map<String, dynamic> data) {
    return TicketVerificationResult(
      isValid: data['is_valid'] as bool? ?? false,
      ticketId: data['ticket_id'] as String?,
      ownerName: data['owner_name'] as String?,
      ticketTypeName: data['ticket_type_name'] as String?,
      ticketStatus: data['ticket_status'] != null
          ? TicketStatus.values.firstWhere(
              (s) => s.name == data['ticket_status'],
              orElse: () => TicketStatus.active,
            )
          : null,
      errorMessage: data['error_message'] as String?,
    );
  }
}
