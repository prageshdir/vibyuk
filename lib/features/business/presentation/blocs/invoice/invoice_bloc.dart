import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/invoice_entity.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/get_invoice_use_case.dart';

part 'invoice_event.dart';
part 'invoice_state.dart';

class InvoiceBloc extends BaseBloc<InvoiceEvent, InvoiceState> {
  InvoiceBloc({
    required GetInvoiceUseCase getInvoice,
    required GetInvoicePdfUrlUseCase getInvoicePdfUrl,
  })  : _getInvoice = getInvoice,
        _getInvoicePdfUrl = getInvoicePdfUrl,
        super(const InvoiceInitialState()) {
    on<LoadInvoiceEvent>(_onLoad);
    on<LoadInvoicePdfUrlEvent>(_onLoadPdf);
  }

  final GetInvoiceUseCase _getInvoice;
  final GetInvoicePdfUrlUseCase _getInvoicePdfUrl;

  Future<void> _onLoad(LoadInvoiceEvent event, Emitter<InvoiceState> emit) async {
    emit(const InvoiceLoadingState());
    final result = await _getInvoice(event.bookingId);
    result.fold(
      (f) => emit(InvoiceErrorState(failure: f)),
      (invoice) => emit(InvoiceLoadedState(invoice: invoice)),
    );
  }

  Future<void> _onLoadPdf(LoadInvoicePdfUrlEvent event, Emitter<InvoiceState> emit) async {
    if (state is! InvoiceLoadedState) return;
    final loaded = state as InvoiceLoadedState;
    emit(loaded.copyWith(isLoadingPdf: true));
    final result = await _getInvoicePdfUrl(event.invoiceId);
    result.fold(
      (f) => emit(loaded.copyWith(isLoadingPdf: false)),
      (url) => emit(loaded.copyWith(pdfUrl: url, isLoadingPdf: false)),
    );
  }
}
