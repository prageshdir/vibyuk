import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/repositories/booking_repository.dart';

class CancelBookingUseCase implements UseCase<Unit, CancelBookingParams> {
  CancelBookingUseCase(this._repository);
  final BookingRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(CancelBookingParams params) {
    return _repository.cancelBooking(
      bookingId: params.bookingId,
      reason: params.reason,
    );
  }
}

class CancelBookingParams extends Equatable {
  const CancelBookingParams({required this.bookingId, this.reason});
  final String bookingId;
  final String? reason;

  @override
  List<Object?> get props => [bookingId, reason];
}
