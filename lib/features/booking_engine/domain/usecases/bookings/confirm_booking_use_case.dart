import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/repositories/booking_engine_repository.dart';

class ConfirmBookingUseCase
    extends UseCase<BookingEntity, ConfirmBookingParams> {
  const ConfirmBookingUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, BookingEntity>> call(ConfirmBookingParams params) =>
      _repository.confirmBooking(params.bookingId);
}

class ConfirmBookingParams extends Equatable {
  const ConfirmBookingParams({required this.bookingId});
  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}
