import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/data/datasources/booking_remote_data_source.dart';
import 'package:vibyuk/features/business/data/dtos/update_booking_status_dto.dart';
import 'package:vibyuk/features/business/data/models/booking_model.dart';
import 'package:vibyuk/features/business/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl extends BaseRepository implements BookingRepository {
  BookingRepositoryImpl({required BookingRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final BookingRemoteDataSource _remote;

  PaginatedResult<BookingEntity> _parsePaginated(Map<String, dynamic> data) {
    final items = (data['items'] as List? ?? data['data'] as List? ?? [])
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
    return PaginatedResult<BookingEntity>(
      items: items,
      currentPage: data['current_page'] as int? ?? 1,
      totalPages: data['total_pages'] as int? ?? 1,
      totalItems: data['total_items'] as int? ?? items.length,
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<BookingEntity>>> getBookings({
    BookingStatus? status,
    required int page,
    int pageSize = 20,
  }) =>
      safeCall(() async {
        final data = await _remote.getBookings(
            status: status, page: page, pageSize: pageSize);
        return _parsePaginated(data);
      });

  @override
  Future<Either<Failure, BookingEntity>> getBookingDetail(String bookingId) =>
      safeCall(() async {
        final data = await _remote.getBookingDetail(bookingId);
        return BookingModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, BookingEntity>> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  }) =>
      safeCall(() async {
        final dto = UpdateBookingStatusDto.fromStatus(status);
        final data = await _remote.updateBookingStatus(bookingId, dto);
        return BookingModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, Unit>> cancelBooking({
    required String bookingId,
    String? reason,
  }) =>
      safeCall(() async {
        await _remote.cancelBooking(bookingId, reason: reason);
        return unit;
      });
}
