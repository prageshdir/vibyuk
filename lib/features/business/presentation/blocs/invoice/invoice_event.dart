part of 'invoice_bloc.dart';

sealed class InvoiceEvent extends Equatable {
  const InvoiceEvent();
}

class LoadInvoiceEvent extends InvoiceEvent {
  const LoadInvoiceEvent(this.bookingId);
  final String bookingId;
  @override
  List<Object?> get props => [bookingId];
}

class LoadInvoicePdfUrlEvent extends InvoiceEvent {
  const LoadInvoicePdfUrlEvent(this.invoiceId);
  final String invoiceId;
  @override
  List<Object?> get props => [invoiceId];
}
