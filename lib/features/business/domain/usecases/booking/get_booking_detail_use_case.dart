import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/booking_repository.dart';

class GetBookingDetailUseCase implements UseCase<BookingEntity, GetBookingDetailParams> {
  GetBookingDetailUseCase(this._repository);
  final BookingRepository _repository;

  @override
  Future<Either<Failure, BookingEntity>> call(GetBookingDetailParams params) {
    return _repository.getBookingDetail(params.bookingId);
  }
}

class GetBookingDetailParams extends Equatable {
  const GetBookingDetailParams({required this.bookingId});
  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}
