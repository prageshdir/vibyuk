import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_booking_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class UpdateVendorBookingUseCase
    extends UseCase<WeddingBookingEntity, UpdateVendorBookingParams> {
  const UpdateVendorBookingUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, WeddingBookingEntity>> call(
    UpdateVendorBookingParams params,
  ) {
    final data = <String, dynamic>{
      if (params.status != null) 'status': params.status,
      if (params.depositPaid != null) 'deposit_paid': params.depositPaid,
      if (params.notes != null) 'notes': params.notes,
    };
    return _repository.updateVendorBooking(
      params.weddingId,
      params.bookingId,
      data,
    );
  }
}

class UpdateVendorBookingParams extends Equatable {
  const UpdateVendorBookingParams({
    required this.weddingId,
    required this.bookingId,
    this.status,
    this.depositPaid,
    this.notes,
  });

  final String weddingId;
  final String bookingId;
  final String? status;
  final bool? depositPaid;
  final String? notes;

  @override
  List<Object?> get props => [weddingId, bookingId, status, depositPaid, notes];
}
