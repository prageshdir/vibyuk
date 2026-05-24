import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/payment_entity.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/get_payments_use_case.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends BaseBloc<PaymentEvent, PaymentState> {
  PaymentBloc({required GetPaymentsUseCase getPayments})
      : _getPayments = getPayments,
        super(const PaymentInitialState()) {
    on<LoadPaymentsEvent>(_onLoad);
    on<LoadMorePaymentsEvent>(_onLoadMore);
  }

  final GetPaymentsUseCase _getPayments;

  Future<void> _onLoad(LoadPaymentsEvent event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoadingState());
    final result = await _getPayments(const GetPaymentsParams());
    result.fold(
      (f) => emit(PaymentErrorState(failure: f)),
      (page) => emit(PaymentsLoadedState(
        payments: page.items,
        hasMore: page.hasNextPage,
        currentPage: page.currentPage,
      )),
    );
  }

  Future<void> _onLoadMore(
      LoadMorePaymentsEvent event, Emitter<PaymentState> emit) async {
    if (state is! PaymentsLoadedState) return;
    final loaded = state as PaymentsLoadedState;
    if (!loaded.hasMore || loaded.isLoadingMore) return;

    emit(loaded.copyWith(isLoadingMore: true));
    final result = await _getPayments(
        GetPaymentsParams(page: loaded.currentPage + 1));
    result.fold(
      (f) => emit(PaymentErrorState(failure: f)),
      (page) => emit(loaded.copyWith(
        payments: [...loaded.payments, ...page.items],
        hasMore: page.hasNextPage,
        currentPage: page.currentPage,
        isLoadingMore: false,
      )),
    );
  }
}
