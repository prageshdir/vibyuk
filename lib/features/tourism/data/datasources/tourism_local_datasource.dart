import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:vibyuk/core/cache/cache_manager.dart';
import 'package:vibyuk/core/cache/drift/app_database.dart';
import 'package:vibyuk/core/error/exceptions.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/features/tourism/data/models/tourism_analytics_dto.dart';
import 'package:vibyuk/features/tourism/data/models/tourism_campaign_dto.dart';
import 'package:vibyuk/features/tourism/data/models/tourism_destination_dto.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_analytics_entity.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_campaign_entity.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_destination_entity.dart';

abstract interface class TourismLocalDataSource {
  Future<List<TourismDestinationEntity>> getDestinations({
    String? category,
    String? region,
    bool featuredOnly,
  });
  Future<TourismDestinationEntity?> getDestination(String id);
  Future<void> cacheDestination(TourismDestinationEntity entity);

  Future<List<TourismCampaignEntity>> getCampaigns({
    String? destinationId,
    String? status,
  });
  Future<TourismCampaignEntity?> getCampaign(String id);
  Future<void> cacheCampaign(TourismCampaignEntity entity);

  Future<TourismAnalyticsEntity?> getCachedAnalytics();
  Future<void> cacheAnalytics(TourismAnalyticsEntity analytics);
}

class TourismLocalDataSourceImpl implements TourismLocalDataSource {
  const TourismLocalDataSourceImpl({
    required TourismDao dao,
    required CacheManager cache,
  })  : _dao = dao,
        _cache = cache;

  final TourismDao _dao;
  final CacheManager _cache;

  static const String _analyticsKey = 'tourism_analytics';

  // ── Destinations ─────────────────────────────────────────────────────────────

  @override
  Future<List<TourismDestinationEntity>> getDestinations({
    String? category,
    String? region,
    bool featuredOnly = false,
  }) async {
    try {
      final rows = await _dao.getDestinations(
        category: category,
        region: region,
        featuredOnly: featuredOnly,
      );
      return rows
          .map(_rowToDestinationEntity)
          .whereType<TourismDestinationEntity>()
          .toList();
    } catch (e, st) {
      AppLogger.error('TourismLocalDataSource.getDestinations failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to read cached destinations: $e');
    }
  }

  @override
  Future<TourismDestinationEntity?> getDestination(String id) async {
    try {
      final row = await _dao.getDestination(id);
      if (row == null) return null;
      return _rowToDestinationEntity(row);
    } catch (e, st) {
      AppLogger.error('TourismLocalDataSource.getDestination failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to read cached destination: $e');
    }
  }

  @override
  Future<void> cacheDestination(TourismDestinationEntity entity) async {
    try {
      final json = jsonEncode(TourismDestinationDto.fromEntity(entity).toJson());
      await _dao.upsertDestination(TourismDestinationsCacheCompanion(
        id: Value(entity.id),
        dataJson: Value(json),
        category: Value(entity.category),
        region: Value(entity.region),
        isFeatured: Value(entity.isFeatured),
        cachedAt: Value(DateTime.now()),
      ));
    } catch (e, st) {
      AppLogger.error('TourismLocalDataSource.cacheDestination failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to cache destination: $e');
    }
  }

  // ── Campaigns ─────────────────────────────────────────────────────────────────

  @override
  Future<List<TourismCampaignEntity>> getCampaigns({
    String? destinationId,
    String? status,
  }) async {
    try {
      final rows = await _dao.getCampaigns(
        destinationId: destinationId,
        status: status,
      );
      return rows
          .map(_rowToCampaignEntity)
          .whereType<TourismCampaignEntity>()
          .toList();
    } catch (e, st) {
      AppLogger.error('TourismLocalDataSource.getCampaigns failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to read cached campaigns: $e');
    }
  }

  @override
  Future<TourismCampaignEntity?> getCampaign(String id) async {
    try {
      final row = await _dao.getCampaign(id);
      if (row == null) return null;
      return _rowToCampaignEntity(row);
    } catch (e, st) {
      AppLogger.error('TourismLocalDataSource.getCampaign failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to read cached campaign: $e');
    }
  }

  @override
  Future<void> cacheCampaign(TourismCampaignEntity entity) async {
    try {
      final json = jsonEncode(TourismCampaignDto.fromEntity(entity).toJson());
      await _dao.upsertCampaign(TourismCampaignsCacheCompanion(
        id: Value(entity.id),
        dataJson: Value(json),
        destinationId: Value(entity.destinationId),
        status: Value(entity.status.name),
        cachedAt: Value(DateTime.now()),
      ));
    } catch (e, st) {
      AppLogger.error('TourismLocalDataSource.cacheCampaign failed',
          error: e, stackTrace: st);
      throw CacheException(message: 'Failed to cache campaign: $e');
    }
  }

  // ── Analytics ─────────────────────────────────────────────────────────────────

  @override
  Future<TourismAnalyticsEntity?> getCachedAnalytics() {
    return _cache.get<TourismAnalyticsEntity>(
      _analyticsKey,
      deserializer: (raw) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return TourismAnalyticsDto.fromJson(json).toEntity();
      },
    );
  }

  @override
  Future<void> cacheAnalytics(TourismAnalyticsEntity analytics) {
    return _cache.set<TourismAnalyticsEntity>(
      _analyticsKey,
      analytics,
      ttl: const Duration(minutes: 5),
      serializer: (a) => jsonEncode(
        TourismAnalyticsDto(
          periodStart: a.periodStart.toIso8601String(),
          periodEnd: a.periodEnd.toIso8601String(),
          totalDestinations: a.totalDestinations,
          totalCampaigns: a.totalCampaigns,
          activeCampaigns: a.activeCampaigns,
          totalReach: a.totalReach,
          averageEngagementRate: a.averageEngagementRate,
          topDestinations: a.topDestinations
              .map((d) => DestinationStatDto(
                    destinationId: d.destinationId,
                    destinationName: d.destinationName,
                    reach: d.reach,
                    engagementRate: d.engagementRate,
                    contentCount: d.contentCount,
                    creatorCount: d.creatorCount,
                    heroImageUrl: d.heroImageUrl,
                  ))
              .toList(),
          totalCreators: a.totalCreators,
          completedFamTrips: a.completedFamTrips,
          contentPieces: a.contentPieces,
          reachByDay: a.reachByDay,
        ).toJson(),
      ),
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────────

  TourismDestinationEntity? _rowToDestinationEntity(
      CachedTourismDestination row) {
    try {
      final json = jsonDecode(row.dataJson) as Map<String, dynamic>;
      return TourismDestinationDto.fromJson(json).toEntity();
    } catch (e) {
      AppLogger.error(
          'TourismLocalDataSource: failed to deserialise destination ${row.id}',
          error: e);
      return null;
    }
  }

  TourismCampaignEntity? _rowToCampaignEntity(CachedTourismCampaign row) {
    try {
      final json = jsonDecode(row.dataJson) as Map<String, dynamic>;
      return TourismCampaignDto.fromJson(json).toEntity();
    } catch (e) {
      AppLogger.error(
          'TourismLocalDataSource: failed to deserialise campaign ${row.id}',
          error: e);
      return null;
    }
  }
}
