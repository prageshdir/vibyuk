import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:vibyuk/core/cache/cache_manager.dart';
import 'package:vibyuk/core/cache/drift/app_database.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/features/wedding/data/models/wedding_analytics_dto.dart';
import 'package:vibyuk/features/wedding/data/models/wedding_budget_dto.dart';
import 'package:vibyuk/features/wedding/data/models/wedding_dto.dart';
import 'package:vibyuk/features/wedding/data/models/wedding_timeline_dto.dart';
import 'package:vibyuk/features/wedding/data/models/wedding_vendor_dto.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_analytics_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_budget_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_timeline_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_vendor_entity.dart';

abstract interface class WeddingLocalDataSource {
  Future<WeddingEntity?> getWedding(String weddingId);
  Future<void> cacheWedding(WeddingEntity entity);

  Future<List<WeddingVendorEntity>> getVendors({String? category});
  Future<WeddingVendorEntity?> getVendor(String id);
  Future<void> cacheVendor(WeddingVendorEntity entity);

  Future<WeddingBudgetEntity?> getCachedBudget(String weddingId);
  Future<void> cacheBudget(WeddingBudgetEntity budget);

  Future<WeddingTimelineEntity?> getCachedTimeline(String weddingId);
  Future<void> cacheTimeline(WeddingTimelineEntity timeline);

  Future<WeddingAnalyticsEntity?> getCachedAnalytics(String weddingId);
  Future<void> cacheAnalytics(String weddingId, WeddingAnalyticsEntity analytics);
}

class WeddingLocalDataSourceImpl implements WeddingLocalDataSource {
  const WeddingLocalDataSourceImpl({
    required WeddingDao dao,
    required CacheManager cache,
  })  : _dao = dao,
        _cache = cache;

  final WeddingDao _dao;
  final CacheManager _cache;

  static String _analyticsKey(String weddingId) =>
      'wedding_analytics_$weddingId';
  static String _budgetKey(String weddingId) => 'wedding_budget_$weddingId';
  static String _timelineKey(String weddingId) =>
      'wedding_timeline_$weddingId';

  // ── Wedding ──────────────────────────────────────────────────────────────────

  @override
  Future<WeddingEntity?> getWedding(String weddingId) async {
    try {
      final row = await _dao.getWedding(weddingId);
      if (row == null) return null;
      return _rowToWeddingEntity(row);
    } catch (e, st) {
      AppLogger.error('WeddingLocalDataSource.getWedding failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to read cached wedding: $e');
    }
  }

  @override
  Future<void> cacheWedding(WeddingEntity entity) async {
    try {
      final json = jsonEncode(WeddingDto.fromEntity(entity).toJson());
      await _dao.upsertWedding(WeddingCacheCompanion(
        id: Value(entity.id),
        dataJson: Value(json),
        cachedAt: Value(DateTime.now()),
      ));
    } catch (e, st) {
      AppLogger.error('WeddingLocalDataSource.cacheWedding failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to cache wedding: $e');
    }
  }

  // ── Vendors ──────────────────────────────────────────────────────────────────

  @override
  Future<List<WeddingVendorEntity>> getVendors({String? category}) async {
    try {
      final rows = await _dao.getVendors(category: category);
      return rows
          .map(_rowToVendorEntity)
          .whereType<WeddingVendorEntity>()
          .toList();
    } catch (e, st) {
      AppLogger.error('WeddingLocalDataSource.getVendors failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to read cached vendors: $e');
    }
  }

  @override
  Future<WeddingVendorEntity?> getVendor(String id) async {
    try {
      final row = await _dao.getVendor(id);
      if (row == null) return null;
      return _rowToVendorEntity(row);
    } catch (e, st) {
      AppLogger.error('WeddingLocalDataSource.getVendor failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to read cached vendor: $e');
    }
  }

  @override
  Future<void> cacheVendor(WeddingVendorEntity entity) async {
    try {
      final json = jsonEncode(WeddingVendorDto.fromEntity(entity).toJson());
      await _dao.upsertVendor(WeddingVendorsCacheCompanion(
        id: Value(entity.id),
        dataJson: Value(json),
        category: Value(entity.category),
        cachedAt: Value(DateTime.now()),
      ));
    } catch (e, st) {
      AppLogger.error('WeddingLocalDataSource.cacheVendor failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to cache vendor: $e');
    }
  }

  // ── Budget ───────────────────────────────────────────────────────────────────

  @override
  Future<WeddingBudgetEntity?> getCachedBudget(String weddingId) async {
    return _cache.get<WeddingBudgetEntity>(
      _budgetKey(weddingId),
      deserializer: (raw) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return WeddingBudgetDto.fromJson(json).toEntity();
      },
    );
  }

  @override
  Future<void> cacheBudget(WeddingBudgetEntity budget) async {
    await _cache.set<WeddingBudgetEntity>(
      _budgetKey(budget.weddingId),
      budget,
      ttl: const Duration(minutes: 10),
      serializer: (b) =>
          jsonEncode(WeddingBudgetDto.fromEntity(b).toJson()),
    );
  }

  // ── Timeline ─────────────────────────────────────────────────────────────────

  @override
  Future<WeddingTimelineEntity?> getCachedTimeline(String weddingId) async {
    return _cache.get<WeddingTimelineEntity>(
      _timelineKey(weddingId),
      deserializer: (raw) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return WeddingTimelineDto.fromJson(json).toEntity();
      },
    );
  }

  @override
  Future<void> cacheTimeline(WeddingTimelineEntity timeline) async {
    await _cache.set<WeddingTimelineEntity>(
      _timelineKey(timeline.weddingId),
      timeline,
      ttl: const Duration(minutes: 10),
      serializer: (t) =>
          jsonEncode(WeddingTimelineDto.fromEntity(t).toJson()),
    );
  }

  // ── Analytics ────────────────────────────────────────────────────────────────

  @override
  Future<WeddingAnalyticsEntity?> getCachedAnalytics(
      String weddingId) async {
    return _cache.get<WeddingAnalyticsEntity>(
      _analyticsKey(weddingId),
      deserializer: (raw) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return WeddingAnalyticsDto.fromJson(json).toEntity();
      },
    );
  }

  @override
  Future<void> cacheAnalytics(
    String weddingId,
    WeddingAnalyticsEntity analytics,
  ) async {
    await _cache.set<WeddingAnalyticsEntity>(
      _analyticsKey(weddingId),
      analytics,
      ttl: const Duration(minutes: 5),
      serializer: (a) =>
          jsonEncode(WeddingAnalyticsDto.fromEntity(a).toJson()),
    );
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  WeddingEntity? _rowToWeddingEntity(CachedWedding row) {
    try {
      final json = jsonDecode(row.dataJson) as Map<String, dynamic>;
      return WeddingDto.fromJson(json).toEntity();
    } catch (e) {
      AppLogger.error(
          'WeddingLocalDataSource: failed to deserialise wedding ${row.id}',
          error: e);
      return null;
    }
  }

  WeddingVendorEntity? _rowToVendorEntity(CachedWeddingVendor row) {
    try {
      final json = jsonDecode(row.dataJson) as Map<String, dynamic>;
      return WeddingVendorDto.fromJson(json).toEntity();
    } catch (e) {
      AppLogger.error(
          'WeddingLocalDataSource: failed to deserialise vendor ${row.id}',
          error: e);
      return null;
    }
  }
}
