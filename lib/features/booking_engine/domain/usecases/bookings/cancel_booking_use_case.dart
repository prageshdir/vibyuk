import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/repositories/booking_engine_repository.dart';

class CancelBookingUseCase
    extends UseCase<BookingEntity, CancelBookingParams> {
  const CancelBookingUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, BookingEntity>> call(CancelBookingParams params) =>
      _repository.cancelBooking(params.bookingId, params.reason);
}

class CancelBookingParams extends Equatable {
  const CancelBookingParams({required this.bookingId, required this.reason});
  final String bookingId;
  final String reason;

  @override
  List<Object?> get props => [bookingId, reason];
}
