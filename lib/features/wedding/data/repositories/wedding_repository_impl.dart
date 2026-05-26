import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/wedding/data/datasources/wedding_local_datasource.dart';
import 'package:vibyuk/features/wedding/data/datasources/wedding_remote_datasource.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_analytics_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_booking_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_budget_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_package_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_timeline_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_vendor_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_venue_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class WeddingRepositoryImpl extends BaseRepository
    implements WeddingRepository {
  const WeddingRepositoryImpl({
    required WeddingLocalDataSource local,
    required WeddingRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final WeddingLocalDataSource _local;
  final WeddingRemoteDataSource _remote;

  // ── Wedding project ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, WeddingEntity>> getWedding(String weddingId) {
    return safeCall(() async {
      final cached = await _local.getWedding(weddingId);
      if (cached != null) {
        AppLogger.debug(
            'WeddingRepository.getWedding: serving from cache id=$weddingId');
        return cached;
      }
      final remote = await _remote.getWedding(weddingId);
      await _local.cacheWedding(remote);
      AppLogger.debug(
          'WeddingRepository.getWedding: fetched from remote id=$weddingId');
      return remote;
    }, context: 'WeddingRepository.getWedding');
  }

  @override
  Future<Either<Failure, WeddingEntity>> createWedding(
    Map<String, dynamic> data,
  ) {
    return safeCall(() async {
      final wedding = await _remote.createWedding(data);
      await _local.cacheWedding(wedding);
      AppLogger.debug(
          'WeddingRepository.createWedding: created id=${wedding.id}');
      return wedding;
    }, context: 'WeddingRepository.createWedding');
  }

  @override
  Future<Either<Failure, WeddingEntity>> updateWedding(
    String weddingId,
    Map<String, dynamic> data,
  ) {
    return safeCall(() async {
      final wedding = await _remote.updateWedding(weddingId, data);
      await _local.cacheWedding(wedding);
      AppLogger.debug(
          'WeddingRepository.updateWedding: updated id=$weddingId');
      return wedding;
    }, context: 'WeddingRepository.updateWedding');
  }

  // ── Vendors ──────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResponse<WeddingVendorEntity>>> getVendors({
    int page = 1,
    int perPage = 20,
    String? category,
    String? query,
  }) {
    return safeCall(() async {
      final cached = await _local.getVendors(category: category);

      if (page == 1) {
        _syncVendorsFromRemote(
          page: page,
          perPage: perPage,
          category: category,
          query: query,
        );
      }

      final totalItems = cached.length;
      final totalPages = totalItems == 0 ? 1 : (totalItems / perPage).ceil();
      final items = cached.skip((page - 1) * perPage).take(perPage).toList();

      AppLogger.debug(
          'WeddingRepository.getVendors: serving ${items.length} cached vendors (page $page)');
      return PaginatedResponse<WeddingVendorEntity>(
        items: items,
        currentPage: page,
        totalPages: totalPages,
        totalItems: totalItems,
        perPage: perPage,
      );
    }, context: 'WeddingRepository.getVendors');
  }

  Future<void> _syncVendorsFromRemote({
    required int page,
    required int perPage,
    String? category,
    String? query,
  }) async {
    try {
      final remote = await _remote.getVendors(
        page: page,
        perPage: perPage,
        category: category,
        query: query,
      );
      for (final vendor in remote.items) {
        await _local.cacheVendor(vendor);
      }
      AppLogger.debug(
          'WeddingRepository._syncVendorsFromRemote: cached ${remote.items.length} vendors');
    } catch (_) {
      // Silent fail — local cache is the source of truth for the UI
    }
  }

  @override
  Future<Either<Failure, WeddingVendorEntity>> getVendorDetail(
    String vendorId,
  ) {
    return safeCall(() async {
      final cached = await _local.getVendor(vendorId);
      if (cached != null) {
        AppLogger.debug(
            'WeddingRepository.getVendorDetail: serving from cache id=$vendorId');
        return cached;
      }
      final remote = await _remote.getVendorDetail(vendorId);
      await _local.cacheVendor(remote);
      AppLogger.debug(
          'WeddingRepository.getVendorDetail: fetched from remote id=$vendorId');
      return remote;
    }, context: 'WeddingRepository.getVendorDetail');
  }

  // ── Venues ───────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResponse<WeddingVenueEntity>>> getVenues({
    int page = 1,
    int perPage = 20,
    String? query,
  }) {
    return safeCall(() async {
      if (page == 1) {
        _syncVenuesFromRemote(page: page, perPage: perPage, query: query);
      }
      final remote = await _remote.getVenues(
        page: page,
        perPage: perPage,
        query: query,
      );
      AppLogger.debug(
          'WeddingRepository.getVenues: fetched ${remote.items.length} venues (page $page)');
      return remote;
    }, context: 'WeddingRepository.getVenues');
  }

  Future<void> _syncVenuesFromRemote({
    required int page,
    required int perPage,
    String? query,
  }) async {
    try {
      final remote =
          await _remote.getVenues(page: page, perPage: perPage, query: query);
      AppLogger.debug(
          'WeddingRepository._syncVenuesFromRemote: synced ${remote.items.length} venues');
    } catch (_) {
      // Silent fail
    }
  }

  @override
  Future<Either<Failure, WeddingVenueEntity>> getVenueDetail(String venueId) {
    return safeCall(() async {
      final remote = await _remote.getVenueDetail(venueId);
      AppLogger.debug(
          'WeddingRepository.getVenueDetail: fetched from remote id=$venueId');
      return remote;
    }, context: 'WeddingRepository.getVenueDetail');
  }

  // ── Packages ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResponse<WeddingPackageEntity>>> getPackages({
    int page = 1,
    int perPage = 20,
  }) {
    return safeCall(() async {
      if (page == 1) {
        _syncPackagesFromRemote(page: page, perPage: perPage);
      }
      final remote = await _remote.getPackages(page: page, perPage: perPage);
      AppLogger.debug(
          'WeddingRepository.getPackages: fetched ${remote.items.length} packages (page $page)');
      return remote;
    }, context: 'WeddingRepository.getPackages');
  }

  Future<void> _syncPackagesFromRemote({
    required int page,
    required int perPage,
  }) async {
    try {
      final remote = await _remote.getPackages(page: page, perPage: perPage);
      AppLogger.debug(
          'WeddingRepository._syncPackagesFromRemote: synced ${remote.items.length} packages');
    } catch (_) {
      // Silent fail
    }
  }

  @override
  Future<Either<Failure, WeddingPackageEntity>> buildCustomPackage(
    String weddingId,
    Map<String, dynamic> packageData,
  ) {
    return safeCall(() async {
      final pkg = await _remote.buildCustomPackage(weddingId, packageData);
      AppLogger.debug(
          'WeddingRepository.buildCustomPackage: built for wedding=$weddingId');
      return pkg;
    }, context: 'WeddingRepository.buildCustomPackage');
  }

  // ── Bookings ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, WeddingBookingEntity>> createVendorBooking(
    String weddingId,
    Map<String, dynamic> bookingData,
  ) {
    return safeCall(() async {
      final booking = await _remote.createVendorBooking(weddingId, bookingData);
      AppLogger.debug(
          'WeddingRepository.createVendorBooking: created id=${booking.id} wedding=$weddingId');
      return booking;
    }, context: 'WeddingRepository.createVendorBooking');
  }

  @override
  Future<Either<Failure, WeddingBookingEntity>> updateVendorBooking(
    String weddingId,
    String bookingId,
    Map<String, dynamic> bookingData,
  ) {
    return safeCall(() async {
      final booking =
          await _remote.updateVendorBooking(weddingId, bookingId, bookingData);
      AppLogger.debug(
          'WeddingRepository.updateVendorBooking: updated id=$bookingId wedding=$weddingId');
      return booking;
    }, context: 'WeddingRepository.updateVendorBooking');
  }

  @override
  Future<Either<Failure, PaginatedResponse<WeddingBookingEntity>>>
      getVendorBookings(
    String weddingId, {
    int page = 1,
    int perPage = 20,
  }) {
    return safeCall(() async {
      final remote = await _remote.getVendorBookings(
        weddingId,
        page: page,
        perPage: perPage,
      );
      AppLogger.debug(
          'WeddingRepository.getVendorBookings: fetched ${remote.items.length} bookings (page $page)');
      return remote;
    }, context: 'WeddingRepository.getVendorBookings');
  }

  // ── Budget ───────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, WeddingBudgetEntity>> getBudget(String weddingId) {
    return safeCall(() async {
      final cached = await _local.getCachedBudget(weddingId);
      if (cached != null) {
        AppLogger.debug(
            'WeddingRepository.getBudget: serving from cache wedding=$weddingId');
        return cached;
      }
      final remote = await _remote.getBudget(weddingId);
      await _local.cacheBudget(remote);
      AppLogger.debug(
          'WeddingRepository.getBudget: fetched from remote wedding=$weddingId');
      return remote;
    }, context: 'WeddingRepository.getBudget');
  }

  @override
  Future<Either<Failure, WeddingBudgetEntity>> addBudgetItem(
    String weddingId,
    Map<String, dynamic> itemData,
  ) {
    return safeCall(() async {
      final budget = await _remote.addBudgetItem(weddingId, itemData);
      await _local.cacheBudget(budget);
      AppLogger.debug(
          'WeddingRepository.addBudgetItem: added item wedding=$weddingId');
      return budget;
    }, context: 'WeddingRepository.addBudgetItem');
  }

  @override
  Future<Either<Failure, WeddingBudgetEntity>> updateBudgetItem(
    String weddingId,
    String itemId,
    Map<String, dynamic> itemData,
  ) {
    return safeCall(() async {
      final budget = await _remote.updateBudgetItem(weddingId, itemId, itemData);
      await _local.cacheBudget(budget);
      AppLogger.debug(
          'WeddingRepository.updateBudgetItem: updated item=$itemId wedding=$weddingId');
      return budget;
    }, context: 'WeddingRepository.updateBudgetItem');
  }

  @override
  Future<Either<Failure, Unit>> deleteBudgetItem(
    String weddingId,
    String itemId,
  ) {
    return safeCall(() async {
      await _remote.deleteBudgetItem(weddingId, itemId);
      AppLogger.debug(
          'WeddingRepository.deleteBudgetItem: deleted item=$itemId wedding=$weddingId');
      return unit;
    }, context: 'WeddingRepository.deleteBudgetItem');
  }

  // ── Timeline ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, WeddingTimelineEntity>> getTimeline(String weddingId) {
    return safeCall(() async {
      final cached = await _local.getCachedTimeline(weddingId);
      if (cached != null) {
        AppLogger.debug(
            'WeddingRepository.getTimeline: serving from cache wedding=$weddingId');
        return cached;
      }
      final remote = await _remote.getTimeline(weddingId);
      await _local.cacheTimeline(remote);
      AppLogger.debug(
          'WeddingRepository.getTimeline: fetched from remote wedding=$weddingId');
      return remote;
    }, context: 'WeddingRepository.getTimeline');
  }

  @override
  Future<Either<Failure, WeddingTimelineEntity>> updateTimelineTask(
    String weddingId,
    String taskId,
    Map<String, dynamic> taskData,
  ) {
    return safeCall(() async {
      final timeline =
          await _remote.updateTimelineTask(weddingId, taskId, taskData);
      await _local.cacheTimeline(timeline);
      AppLogger.debug(
          'WeddingRepository.updateTimelineTask: updated task=$taskId wedding=$weddingId');
      return timeline;
    }, context: 'WeddingRepository.updateTimelineTask');
  }

  @override
  Future<Either<Failure, WeddingTimelineEntity>> addTimelineTask(
    String weddingId,
    Map<String, dynamic> taskData,
  ) {
    return safeCall(() async {
      final timeline = await _remote.addTimelineTask(weddingId, taskData);
      await _local.cacheTimeline(timeline);
      AppLogger.debug(
          'WeddingRepository.addTimelineTask: added task wedding=$weddingId');
      return timeline;
    }, context: 'WeddingRepository.addTimelineTask');
  }

  // ── Analytics ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, WeddingAnalyticsEntity>> getAnalytics(
    String weddingId,
  ) {
    return safeCall(() async {
      final cached = await _local.getCachedAnalytics(weddingId);
      if (cached != null) {
        AppLogger.debug(
            'WeddingRepository.getAnalytics: serving from cache wedding=$weddingId');
        return cached;
      }
      final remote = await _remote.getAnalytics(weddingId);
      await _local.cacheAnalytics(weddingId, remote);
      AppLogger.debug(
          'WeddingRepository.getAnalytics: fetched from remote wedding=$weddingId');
      return remote;
    }, context: 'WeddingRepository.getAnalytics');
  }
}
