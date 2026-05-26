import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';

abstract interface class BookingRepository {
  Future<Either<Failure, PaginatedResult<BookingEntity>>> getBookings({
    BookingStatus? status,
    required int page,
    int pageSize = 20,
  });

  Future<Either<Failure, BookingEntity>> getBookingDetail(String bookingId);

  Future<Either<Failure, BookingEntity>> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  });

  Future<Either<Failure, Unit>> cancelBooking({
    required String bookingId,
    String? reason,
  });
}
