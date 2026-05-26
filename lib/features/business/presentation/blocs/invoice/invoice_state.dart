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
  const InvoiceLoadedState({
    required this.invoice,
    this.pdfUrl,
    this.isLoadingPdf = false,
  });

  final InvoiceEntity invoice;
  final String? pdfUrl;
  final bool isLoadingPdf;

  InvoiceLoadedState copyWith({
    InvoiceEntity? invoice,
    String? pdfUrl,
    bool? isLoadingPdf,
  }) =>
      InvoiceLoadedState(
        invoice: invoice ?? this.invoice,
        pdfUrl: pdfUrl ?? this.pdfUrl,
        isLoadingPdf: isLoadingPdf ?? this.isLoadingPdf,
      );

  @override
  List<Object?> get props => [invoice, pdfUrl, isLoadingPdf];
}

class InvoiceErrorState extends InvoiceState {
  const InvoiceErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
