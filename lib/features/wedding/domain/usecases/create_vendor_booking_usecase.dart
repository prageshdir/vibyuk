import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_booking_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class CreateVendorBookingUseCase
    extends UseCase<WeddingBookingEntity, CreateVendorBookingParams> {
  const CreateVendorBookingUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, WeddingBookingEntity>> call(
    CreateVendorBookingParams params,
  ) {
    final data = <String, dynamic>{
      'vendor_id': params.vendorId,
      'agreed_price': params.agreedPrice,
      'event_date': params.eventDate.toIso8601String(),
      if (params.depositAmount != null) 'deposit_amount': params.depositAmount,
      if (params.notes != null) 'notes': params.notes,
    };
    return _repository.createVendorBooking(params.weddingId, data);
  }
}

class CreateVendorBookingParams extends Equatable {
  const CreateVendorBookingParams({
    required this.weddingId,
    required this.vendorId,
    required this.agreedPrice,
    required this.eventDate,
    this.depositAmount,
    this.notes,
  });

  final String weddingId;
  final String vendorId;
  final double agreedPrice;
  final DateTime eventDate;
  final double? depositAmount;
  final String? notes;

  @override
  List<Object?> get props => [
        weddingId,
        vendorId,
        agreedPrice,
        eventDate,
        depositAmount,
        notes,
      ];
}
