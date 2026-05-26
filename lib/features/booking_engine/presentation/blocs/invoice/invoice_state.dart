part of 'invoice_bloc.dart';

sealed class InvoiceState extends Equatable {
  const InvoiceState();
}

class InvoiceInitialState extends InvoiceState {
  const InvoiceInitialState();
  @override
  List<Object?> get props => [];
}

class InvoiceLoadingState extends InvoiceState {
  const InvoiceLoadingState();
  @override
  List<Object?> get props => [];
}

class InvoiceLoadedState extends InvoiceState {
  const InvoiceLoadedState({required this.invoice});
  final BookingInvoiceEntity invoice;
  @override
  List<Object?> get props => [invoice];
}

class InvoiceErrorState extends InvoiceState {
  const InvoiceErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
