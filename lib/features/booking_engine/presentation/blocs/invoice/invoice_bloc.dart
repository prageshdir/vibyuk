import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_invoice_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/invoice/get_invoice_use_case.dart';

part 'invoice_event.dart';
part 'invoice_state.dart';

class InvoiceBloc extends BaseBloc<InvoiceEvent, InvoiceState> {
  InvoiceBloc({required GetInvoiceUseCase getInvoice})
      : _getInvoice = getInvoice,
        super(const InvoiceInitialState()) {
    on<LoadInvoiceEvent>(_onLoad);
  }

  final GetInvoiceUseCase _getInvoice;

  Future<void> _onLoad(
      LoadInvoiceEvent event, Emitter<InvoiceState> emit) async {
    emit(const InvoiceLoadingState());
    final result =
        await _getInvoice(GetInvoiceParams(bookingId: event.bookingId));
    result.fold(
      (f) => emit(InvoiceErrorState(failure: f)),
      (inv) => emit(InvoiceLoadedState(invoice: inv)),
    );
  }
}
