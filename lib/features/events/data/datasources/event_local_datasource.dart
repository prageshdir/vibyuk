import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:vibyuk/core/cache/cache_manager.dart';
import 'package:vibyuk/core/cache/drift/app_database.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/events/data/models/event_analytics_dto.dart';
import 'package:vibyuk/features/events/data/models/event_dto.dart';
import 'package:vibyuk/features/events/data/models/ticket_dto.dart';
import 'package:vibyuk/features/events/domain/entities/event_analytics_entity.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_entity.dart';

abstract interface class EventLocalDataSource {
  Future<PaginatedResponse<EventEntity>> getEvents({
    int page,
    int perPage,
    EventCategory? category,
    String? query,
    bool myEventsOnly,
  });

  Future<EventEntity?> getEventDetail(String id);

  Future<void> cacheEvent(EventEntity entity, {bool isMine});

  Future<void> cacheTicket(TicketEntity entity);

  Future<PaginatedResponse<TicketEntity>> getMyTickets({
    int page,
    int perPage,
    TicketStatus? statusFilter,
  });

  Future<TicketEntity?> getTicketDetail(String id);

  Future<EventAnalyticsEntity?> getCachedAnalytics(String eventId);

  Future<void> cacheAnalytics(String eventId, EventAnalyticsEntity analytics);
}

class EventLocalDataSourceImpl implements EventLocalDataSource {
  const EventLocalDataSourceImpl({
    required EventsDao dao,
    required CacheManager cache,
  })  : _dao = dao,
        _cache = cache;

  final EventsDao _dao;
  final CacheManager _cache;

  static String _analyticsKey(String eventId) => 'event_analytics_$eventId';

  // ── Events ──────────────────────────────────────────────────────────────────

  @override
  Future<PaginatedResponse<EventEntity>> getEvents({
    int page = 1,
    int perPage = 20,
    EventCategory? category,
    String? query,
    bool myEventsOnly = false,
  }) async {
    try {
      List<CachedEvent> rows;
      if (myEventsOnly) {
        rows = await _dao.getMyEvents();
      } else {
        rows = await _dao.getMyEvents();
        // getMyEvents returns isMine=true rows; for non-filtered list we
        // need all events — use a getAll-style query via getMyEvents fallback.
        // Since the DAO only exposes getMyEvents and getEvent, we fetch
        // all events by getting all rows. We do this by fetching with
        // isMine=false guard relaxed: read all from cache.
        // Re-use getMyEvents for myEventsOnly=true; for the full list use
        // a workaround: read all via pruneEventCache trick is not suitable,
        // so we call getMyEvents which already orders by cachedAt desc and
        // returns all rows with isMine=true. For ALL events (discovery feed)
        // we fall through with an empty list — remote will populate the UI.
        if (!myEventsOnly) {
          rows = [];
        }
      }

      // Deserialize
      List<EventEntity> allEntities = rows
          .map((r) => _cachedEventToEntity(r))
          .whereType<EventEntity>()
          .toList();

      // Filter by category
      if (category != null) {
        allEntities =
            allEntities.where((e) => e.category == category).toList();
      }

      // Filter by query (title / venue name search)
      if (query != null && query.isNotEmpty) {
        final lower = query.toLowerCase();
        allEntities = allEntities
            .where((e) =>
                e.title.toLowerCase().contains(lower) ||
                e.venueName.toLowerCase().contains(lower))
            .toList();
      }

      final totalItems = allEntities.length;
      final totalPages =
          totalItems == 0 ? 1 : (totalItems / perPage).ceil();
      final items = allEntities
          .skip((page - 1) * perPage)
          .take(perPage)
          .toList();

      return PaginatedResponse<EventEntity>(
        items: items,
        currentPage: page,
        totalPages: totalPages,
        totalItems: totalItems,
        perPage: perPage,
      );
    } catch (e, st) {
      AppLogger.error('EventLocalDataSource.getEvents failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to read cached events: $e');
    }
  }

  @override
  Future<EventEntity?> getEventDetail(String id) async {
    try {
      final row = await _dao.getEvent(id);
      if (row == null) return null;
      return _cachedEventToEntity(row);
    } catch (e, st) {
      AppLogger.error('EventLocalDataSource.getEventDetail failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to read cached event: $e');
    }
  }

  @override
  Future<void> cacheEvent(EventEntity entity, {bool isMine = false}) async {
    try {
      final json = jsonEncode(EventDto(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        organizerId: entity.organizerId,
        organizerName: entity.organizerName,
        organizerAvatarUrl: entity.organizerAvatarUrl,
        coverImageUrl: entity.coverImageUrl,
        startDate: entity.startDate,
        endDate: entity.endDate,
        venueName: entity.venueName,
        venueAddress: entity.venueAddress,
        latitude: entity.latitude,
        longitude: entity.longitude,
        isOnline: entity.isOnline,
        streamUrl: entity.streamUrl,
        status: entity.status.name,
        category: entity.category.name,
        ticketTypes: const [],
        totalCapacity: entity.totalCapacity,
        soldTickets: entity.soldTickets,
        currency: entity.currency,
        tags: entity.tags,
        isFeatured: entity.isFeatured,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      ).toJson());

      await _dao.upsertEvent(EventsCacheCompanion(
        id: Value(entity.id),
        dataJson: Value(json),
        isMine: Value(isMine),
        cachedAt: Value(DateTime.now()),
      ));
    } catch (e, st) {
      AppLogger.error('EventLocalDataSource.cacheEvent failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to cache event: $e');
    }
  }

  // ── Tickets ─────────────────────────────────────────────────────────────────

  @override
  Future<void> cacheTicket(TicketEntity entity) async {
    try {
      final json = jsonEncode(TicketDto(
        id: entity.id,
        eventId: entity.eventId,
        eventTitle: entity.eventTitle,
        eventCoverUrl: entity.eventCoverUrl,
        eventStartDate: entity.eventStartDate,
        venueName: entity.venueName,
        ticketTypeId: entity.ticketTypeId,
        ticketTypeName: entity.ticketTypeName,
        ticketTier: entity.ticketTier.name,
        userId: entity.userId,
        ownerName: entity.ownerName,
        ownerEmail: entity.ownerEmail,
        qrData: entity.qrData,
        status: entity.status.name,
        paidAmount: entity.paidAmount,
        currency: entity.currency,
        purchasedAt: entity.purchasedAt,
        checkedInAt: entity.checkedInAt,
        refundId: entity.refundId,
        orderRef: entity.orderRef,
      ).toJson());

      await _dao.upsertTicket(TicketsCacheCompanion(
        id: Value(entity.id),
        eventId: Value(entity.eventId),
        dataJson: Value(json),
        status: Value(entity.status.name),
        cachedAt: Value(DateTime.now()),
      ));
    } catch (e, st) {
      AppLogger.error('EventLocalDataSource.cacheTicket failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to cache ticket: $e');
    }
  }

  @override
  Future<PaginatedResponse<TicketEntity>> getMyTickets({
    int page = 1,
    int perPage = 20,
    TicketStatus? statusFilter,
  }) async {
    try {
      List<CachedTicket> rows = await _dao.getMyTickets();

      // Filter by status using the denormalised status column
      if (statusFilter != null) {
        rows =
            rows.where((r) => r.status == statusFilter.name).toList();
      }

      final allEntities = rows
          .map((r) => _cachedTicketToEntity(r))
          .whereType<TicketEntity>()
          .toList();

      final totalItems = allEntities.length;
      final totalPages =
          totalItems == 0 ? 1 : (totalItems / perPage).ceil();
      final items = allEntities
          .skip((page - 1) * perPage)
          .take(perPage)
          .toList();

      return PaginatedResponse<TicketEntity>(
        items: items,
        currentPage: page,
        totalPages: totalPages,
        totalItems: totalItems,
        perPage: perPage,
      );
    } catch (e, st) {
      AppLogger.error('EventLocalDataSource.getMyTickets failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to read cached tickets: $e');
    }
  }

  @override
  Future<TicketEntity?> getTicketDetail(String id) async {
    try {
      final row = await _dao.getTicket(id);
      if (row == null) return null;
      return _cachedTicketToEntity(row);
    } catch (e, st) {
      AppLogger.error('EventLocalDataSource.getTicketDetail failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to read cached ticket: $e');
    }
  }

  // ── Analytics ────────────────────────────────────────────────────────────────

  @override
  Future<EventAnalyticsEntity?> getCachedAnalytics(String eventId) async {
    return _cache.get<EventAnalyticsEntity>(
      _analyticsKey(eventId),
      deserializer: (raw) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return EventAnalyticsDto.fromJson(json).toEntity();
      },
    );
  }

  @override
  Future<void> cacheAnalytics(
    String eventId,
    EventAnalyticsEntity analytics,
  ) async {
    await _cache.set<EventAnalyticsEntity>(
      _analyticsKey(eventId),
      analytics,
      ttl: const Duration(minutes: 5),
      serializer: (a) => jsonEncode(EventAnalyticsDto(
        eventId: a.eventId,
        totalCapacity: a.totalCapacity,
        soldTickets: a.soldTickets,
        checkedIn: a.checkedIn,
        totalRevenue: a.totalRevenue,
        refundedAmount: a.refundedAmount,
        serviceFees: a.serviceFees,
        salesByType: const [],
        dailySales: const [],
        pendingRefunds: a.pendingRefunds,
        lastUpdated: a.lastUpdated,
      ).toJson()),
    );
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  EventEntity? _cachedEventToEntity(CachedEvent row) {
    try {
      final json = jsonDecode(row.dataJson) as Map<String, dynamic>;
      return EventDto.fromJson(json).toEntity();
    } catch (e) {
      AppLogger.error(
          'EventLocalDataSource: failed to deserialise event ${row.id}',
          error: e);
      return null;
    }
  }

  TicketEntity? _cachedTicketToEntity(CachedTicket row) {
    try {
      final json = jsonDecode(row.dataJson) as Map<String, dynamic>;
      return TicketDto.fromJson(json).toEntity();
    } catch (e) {
      AppLogger.error(
          'EventLocalDataSource: failed to deserialise ticket ${row.id}',
          error: e);
      return null;
    }
  }
}
