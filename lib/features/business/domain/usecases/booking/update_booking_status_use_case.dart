import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/booking_repository.dart';

class UpdateBookingStatusUseCase
    implements UseCase<BookingEntity, UpdateBookingStatusParams> {
  UpdateBookingStatusUseCase(this._repository);
  final BookingRepository _repository;

  @override
  Future<Either<Failure, BookingEntity>> call(UpdateBookingStatusParams params) {
    return _repository.updateBookingStatus(
      bookingId: params.bookingId,
      status: params.status,
    );
  }
}

class UpdateBookingStatusParams extends Equatable {
  const UpdateBookingStatusParams({
    required this.bookingId,
    required this.status,
  });
  final String bookingId;
  final BookingStatus status;

  @override
  List<Object?> get props => [bookingId, status];
}
