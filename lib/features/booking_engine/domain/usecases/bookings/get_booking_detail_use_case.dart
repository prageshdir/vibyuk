import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/repositories/booking_engine_repository.dart';

class GetBookingDetailUseCase
    extends UseCase<BookingEntity, GetBookingDetailParams> {
  const GetBookingDetailUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, BookingEntity>> call(GetBookingDetailParams params) =>
      _repository.getBookingDetail(params.bookingId);
}

class GetBookingDetailParams extends Equatable {
  const GetBookingDetailParams({required this.bookingId});
  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}
