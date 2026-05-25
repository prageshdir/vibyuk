import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/invoice_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/payment_repository.dart';

class GetInvoiceUseCase implements UseCase<InvoiceEntity, String> {
  const GetInvoiceUseCase(this._repository);
  final PaymentRepository _repository;

  @override
  Future<Either<Failure, InvoiceEntity>> call(String bookingId) =>
      _repository.getInvoice(bookingId);
}

class GetInvoicePdfUrlUseCase implements UseCase<String, String> {
  const GetInvoicePdfUrlUseCase(this._repository);
  final PaymentRepository _repository;

  @override
  Future<Either<Failure, String>> call(String invoiceId) =>
      _repository.getInvoicePdfUrl(invoiceId);
}
