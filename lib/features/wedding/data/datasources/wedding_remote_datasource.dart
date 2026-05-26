import 'package:dio/dio.dart';
import 'package:vibyuk/core/api/api_endpoints.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/wedding/data/models/wedding_analytics_dto.dart';
import 'package:vibyuk/features/wedding/data/models/wedding_booking_dto.dart';
import 'package:vibyuk/features/wedding/data/models/wedding_budget_dto.dart';
import 'package:vibyuk/features/wedding/data/models/wedding_dto.dart';
import 'package:vibyuk/features/wedding/data/models/wedding_package_dto.dart';
import 'package:vibyuk/features/wedding/data/models/wedding_timeline_dto.dart';
import 'package:vibyuk/features/wedding/data/models/wedding_vendor_dto.dart';
import 'package:vibyuk/features/wedding/data/models/wedding_venue_dto.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_analytics_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_booking_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_budget_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_package_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_timeline_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_vendor_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_venue_entity.dart';

abstract interface class WeddingRemoteDataSource {
  // ── Wedding project ──────────────────────────────────────────────────────────
  Future<WeddingEntity> getWedding(String weddingId);
  Future<WeddingEntity> createWedding(Map<String, dynamic> data);
  Future<WeddingEntity> updateWedding(String weddingId, Map<String, dynamic> data);

  // ── Vendors ──────────────────────────────────────────────────────────────────
  Future<PaginatedResponse<WeddingVendorEntity>> getVendors({
    int page,
    int perPage,
    String? category,
    String? query,
  });
  Future<WeddingVendorEntity> getVendorDetail(String vendorId);

  // ── Venues ───────────────────────────────────────────────────────────────────
  Future<PaginatedResponse<WeddingVenueEntity>> getVenues({
    int page,
    int perPage,
    String? query,
  });
  Future<WeddingVenueEntity> getVenueDetail(String venueId);

  // ── Packages ─────────────────────────────────────────────────────────────────
  Future<PaginatedResponse<WeddingPackageEntity>> getPackages({
    int page,
    int perPage,
  });
  Future<WeddingPackageEntity> buildCustomPackage(
    String weddingId,
    Map<String, dynamic> packageData,
  );

  // ── Bookings ─────────────────────────────────────────────────────────────────
  Future<WeddingBookingEntity> createVendorBooking(
    String weddingId,
    Map<String, dynamic> bookingData,
  );
  Future<WeddingBookingEntity> updateVendorBooking(
    String weddingId,
    String bookingId,
    Map<String, dynamic> bookingData,
  );
  Future<PaginatedResponse<WeddingBookingEntity>> getVendorBookings(
    String weddingId, {
    int page,
    int perPage,
  });

  // ── Budget ───────────────────────────────────────────────────────────────────
  Future<WeddingBudgetEntity> getBudget(String weddingId);
  Future<WeddingBudgetEntity> addBudgetItem(
    String weddingId,
    Map<String, dynamic> itemData,
  );
  Future<WeddingBudgetEntity> updateBudgetItem(
    String weddingId,
    String itemId,
    Map<String, dynamic> itemData,
  );
  Future<void> deleteBudgetItem(String weddingId, String itemId);

  // ── Timeline ─────────────────────────────────────────────────────────────────
  Future<WeddingTimelineEntity> getTimeline(String weddingId);
  Future<WeddingTimelineEntity> updateTimelineTask(
    String weddingId,
    String taskId,
    Map<String, dynamic> taskData,
  );
  Future<WeddingTimelineEntity> addTimelineTask(
    String weddingId,
    Map<String, dynamic> taskData,
  );

  // ── Analytics ────────────────────────────────────────────────────────────────
  Future<WeddingAnalyticsEntity> getAnalytics(String weddingId);
}

class WeddingRemoteDataSourceImpl implements WeddingRemoteDataSource {
  const WeddingRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  // ── Wedding project ──────────────────────────────────────────────────────────

  @override
  Future<WeddingEntity> getWedding(String weddingId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.weddingById(weddingId),
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug('WeddingRemoteDataSource.getWedding: $weddingId');
    return WeddingDto.fromJson(data).toEntity();
  }

  @override
  Future<WeddingEntity> createWedding(Map<String, dynamic> data) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.weddings,
      data: data,
    );
    final payload = response.data ?? {};
    final resData = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug('WeddingRemoteDataSource.createWedding');
    return WeddingDto.fromJson(resData).toEntity();
  }

  @override
  Future<WeddingEntity> updateWedding(
    String weddingId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.weddingById(weddingId),
      data: data,
    );
    final payload = response.data ?? {};
    final resData = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug('WeddingRemoteDataSource.updateWedding: $weddingId');
    return WeddingDto.fromJson(resData).toEntity();
  }

  // ── Vendors ──────────────────────────────────────────────────────────────────

  @override
  Future<PaginatedResponse<WeddingVendorEntity>> getVendors({
    int page = 1,
    int perPage = 20,
    String? category,
    String? query,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.weddingVendors,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (category != null) 'category': category,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );
    final payload = response.data ?? {};
    final items = (payload['data'] as List<dynamic>? ?? [])
        .map((e) =>
            WeddingVendorDto.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
    final meta = payload['meta'] as Map<String, dynamic>? ?? {};
    AppLogger.debug(
        'WeddingRemoteDataSource.getVendors: fetched ${items.length} vendors (page $page)');
    return PaginatedResponse.fromApiResponse<WeddingVendorEntity>(
      items: items,
      meta: meta,
    );
  }

  @override
  Future<WeddingVendorEntity> getVendorDetail(String vendorId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.weddingVendorById(vendorId),
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug('WeddingRemoteDataSource.getVendorDetail: $vendorId');
    return WeddingVendorDto.fromJson(data).toEntity();
  }

  // ── Venues ───────────────────────────────────────────────────────────────────

  @override
  Future<PaginatedResponse<WeddingVenueEntity>> getVenues({
    int page = 1,
    int perPage = 20,
    String? query,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.weddingVenues,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );
    final payload = response.data ?? {};
    final items = (payload['data'] as List<dynamic>? ?? [])
        .map((e) =>
            WeddingVenueDto.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
    final meta = payload['meta'] as Map<String, dynamic>? ?? {};
    AppLogger.debug(
        'WeddingRemoteDataSource.getVenues: fetched ${items.length} venues (page $page)');
    return PaginatedResponse.fromApiResponse<WeddingVenueEntity>(
      items: items,
      meta: meta,
    );
  }

  @override
  Future<WeddingVenueEntity> getVenueDetail(String venueId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.weddingVenueById(venueId),
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug('WeddingRemoteDataSource.getVenueDetail: $venueId');
    return WeddingVenueDto.fromJson(data).toEntity();
  }

  // ── Packages ─────────────────────────────────────────────────────────────────

  @override
  Future<PaginatedResponse<WeddingPackageEntity>> getPackages({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.weddingPackages,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
    final payload = response.data ?? {};
    final items = (payload['data'] as List<dynamic>? ?? [])
        .map((e) =>
            WeddingPackageDto.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
    final meta = payload['meta'] as Map<String, dynamic>? ?? {};
    AppLogger.debug(
        'WeddingRemoteDataSource.getPackages: fetched ${items.length} packages (page $page)');
    return PaginatedResponse.fromApiResponse<WeddingPackageEntity>(
      items: items,
      meta: meta,
    );
  }

  @override
  Future<WeddingPackageEntity> buildCustomPackage(
    String weddingId,
    Map<String, dynamic> packageData,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.buildWeddingPackage(weddingId),
      data: packageData,
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug(
        'WeddingRemoteDataSource.buildCustomPackage: wedding=$weddingId');
    return WeddingPackageDto.fromJson(data).toEntity();
  }

  // ── Bookings ─────────────────────────────────────────────────────────────────

  @override
  Future<WeddingBookingEntity> createVendorBooking(
    String weddingId,
    Map<String, dynamic> bookingData,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.weddingBookings(weddingId),
      data: bookingData,
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug(
        'WeddingRemoteDataSource.createVendorBooking: wedding=$weddingId');
    return WeddingBookingDto.fromJson(data).toEntity();
  }

  @override
  Future<WeddingBookingEntity> updateVendorBooking(
    String weddingId,
    String bookingId,
    Map<String, dynamic> bookingData,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.weddingBookingById(weddingId, bookingId),
      data: bookingData,
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug(
        'WeddingRemoteDataSource.updateVendorBooking: wedding=$weddingId booking=$bookingId');
    return WeddingBookingDto.fromJson(data).toEntity();
  }

  @override
  Future<PaginatedResponse<WeddingBookingEntity>> getVendorBookings(
    String weddingId, {
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.weddingBookings(weddingId),
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
    final payload = response.data ?? {};
    final items = (payload['data'] as List<dynamic>? ?? [])
        .map((e) =>
            WeddingBookingDto.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
    final meta = payload['meta'] as Map<String, dynamic>? ?? {};
    AppLogger.debug(
        'WeddingRemoteDataSource.getVendorBookings: fetched ${items.length} bookings (page $page)');
    return PaginatedResponse.fromApiResponse<WeddingBookingEntity>(
      items: items,
      meta: meta,
    );
  }

  // ── Budget ───────────────────────────────────────────────────────────────────

  @override
  Future<WeddingBudgetEntity> getBudget(String weddingId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.weddingBudget(weddingId),
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug('WeddingRemoteDataSource.getBudget: wedding=$weddingId');
    return WeddingBudgetDto.fromJson(data).toEntity();
  }

  @override
  Future<WeddingBudgetEntity> addBudgetItem(
    String weddingId,
    Map<String, dynamic> itemData,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.weddingBudget(weddingId),
      data: itemData,
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug(
        'WeddingRemoteDataSource.addBudgetItem: wedding=$weddingId');
    return WeddingBudgetDto.fromJson(data).toEntity();
  }

  @override
  Future<WeddingBudgetEntity> updateBudgetItem(
    String weddingId,
    String itemId,
    Map<String, dynamic> itemData,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.weddingBudgetItem(weddingId, itemId),
      data: itemData,
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug(
        'WeddingRemoteDataSource.updateBudgetItem: wedding=$weddingId item=$itemId');
    return WeddingBudgetDto.fromJson(data).toEntity();
  }

  @override
  Future<void> deleteBudgetItem(String weddingId, String itemId) async {
    await _dio.delete<void>(ApiEndpoints.weddingBudgetItem(weddingId, itemId));
    AppLogger.debug(
        'WeddingRemoteDataSource.deleteBudgetItem: wedding=$weddingId item=$itemId');
  }

  // ── Timeline ─────────────────────────────────────────────────────────────────

  @override
  Future<WeddingTimelineEntity> getTimeline(String weddingId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.weddingTimeline(weddingId),
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug('WeddingRemoteDataSource.getTimeline: wedding=$weddingId');
    return WeddingTimelineDto.fromJson(data).toEntity();
  }

  @override
  Future<WeddingTimelineEntity> updateTimelineTask(
    String weddingId,
    String taskId,
    Map<String, dynamic> taskData,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.weddingTimelineTask(weddingId, taskId),
      data: taskData,
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug(
        'WeddingRemoteDataSource.updateTimelineTask: wedding=$weddingId task=$taskId');
    return WeddingTimelineDto.fromJson(data).toEntity();
  }

  @override
  Future<WeddingTimelineEntity> addTimelineTask(
    String weddingId,
    Map<String, dynamic> taskData,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.weddingTimeline(weddingId),
      data: taskData,
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug(
        'WeddingRemoteDataSource.addTimelineTask: wedding=$weddingId');
    return WeddingTimelineDto.fromJson(data).toEntity();
  }

  // ── Analytics ────────────────────────────────────────────────────────────────

  @override
  Future<WeddingAnalyticsEntity> getAnalytics(String weddingId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.weddingAnalytics(weddingId),
    );
    final payload = response.data ?? {};
    final data = payload['data'] as Map<String, dynamic>? ?? payload;
    AppLogger.debug(
        'WeddingRemoteDataSource.getAnalytics: wedding=$weddingId');
    return WeddingAnalyticsDto.fromJson(data).toEntity();
  }
}
