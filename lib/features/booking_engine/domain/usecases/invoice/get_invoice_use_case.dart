import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_invoice_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/repositories/booking_engine_repository.dart';

class GetInvoiceUseCase
    extends UseCase<BookingInvoiceEntity, GetInvoiceParams> {
  const GetInvoiceUseCase(this._repository);
  final BookingEngineRepository _repository;

  @override
  Future<Either<Failure, BookingInvoiceEntity>> call(GetInvoiceParams params) =>
      _repository.getInvoice(params.bookingId);
}

class GetInvoiceParams extends Equatable {
  const GetInvoiceParams({required this.bookingId});
  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}
