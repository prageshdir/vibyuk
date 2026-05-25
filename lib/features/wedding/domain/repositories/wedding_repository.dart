import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_analytics_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_booking_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_budget_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_package_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_timeline_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_vendor_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_venue_entity.dart';

abstract interface class WeddingRepository {
  // ── Wedding project ──────────────────────────────────────────────────────────
  Future<Either<Failure, WeddingEntity>> getWedding(String weddingId);
  Future<Either<Failure, WeddingEntity>> createWedding(
      Map<String, dynamic> data);
  Future<Either<Failure, WeddingEntity>> updateWedding(
      String weddingId, Map<String, dynamic> data);

  // ── Vendors ──────────────────────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResponse<WeddingVendorEntity>>> getVendors({
    int page,
    int perPage,
    String? category,
    String? query,
  });
  Future<Either<Failure, WeddingVendorEntity>> getVendorDetail(String vendorId);

  // ── Venues ───────────────────────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResponse<WeddingVenueEntity>>> getVenues({
    int page,
    int perPage,
    String? query,
  });
  Future<Either<Failure, WeddingVenueEntity>> getVenueDetail(String venueId);

  // ── Packages ─────────────────────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResponse<WeddingPackageEntity>>> getPackages({
    int page,
    int perPage,
  });
  Future<Either<Failure, WeddingPackageEntity>> buildCustomPackage(
      String weddingId, Map<String, dynamic> packageData);

  // ── Bookings ─────────────────────────────────────────────────────────────────
  Future<Either<Failure, WeddingBookingEntity>> createVendorBooking(
      String weddingId, Map<String, dynamic> bookingData);
  Future<Either<Failure, WeddingBookingEntity>> updateVendorBooking(
      String weddingId, String bookingId, Map<String, dynamic> bookingData);
  Future<Either<Failure, PaginatedResponse<WeddingBookingEntity>>>
      getVendorBookings(String weddingId, {int page, int perPage});

  // ── Budget ───────────────────────────────────────────────────────────────────
  Future<Either<Failure, WeddingBudgetEntity>> getBudget(String weddingId);
  Future<Either<Failure, WeddingBudgetEntity>> addBudgetItem(
      String weddingId, Map<String, dynamic> itemData);
  Future<Either<Failure, WeddingBudgetEntity>> updateBudgetItem(
      String weddingId, String itemId, Map<String, dynamic> itemData);
  Future<Either<Failure, Unit>> deleteBudgetItem(
      String weddingId, String itemId);

  // ── Timeline ─────────────────────────────────────────────────────────────────
  Future<Either<Failure, WeddingTimelineEntity>> getTimeline(String weddingId);
  Future<Either<Failure, WeddingTimelineEntity>> updateTimelineTask(
      String weddingId, String taskId, Map<String, dynamic> taskData);
  Future<Either<Failure, WeddingTimelineEntity>> addTimelineTask(
      String weddingId, Map<String, dynamic> taskData);

  // ── Analytics ────────────────────────────────────────────────────────────────
  Future<Either<Failure, WeddingAnalyticsEntity>> getAnalytics(
      String weddingId);
}
