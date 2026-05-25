part of 'invoice_bloc.dart';

sealed class InvoiceEvent extends Equatable {
  const InvoiceEvent();
}

class LoadInvoiceEvent extends InvoiceEvent {
  const LoadInvoiceEvent({required this.bookingId});
  final String bookingId;
  @override
  List<Object?> get props => [bookingId];
}
