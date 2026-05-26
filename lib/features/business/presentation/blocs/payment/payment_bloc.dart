import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/payment_entity.dart';
import 'package:vibyuk/features/business/domain/entities/payment_order_entity.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/get_payments_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/initiate_payment_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/verify_payment_use_case.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends BaseBloc<PaymentEvent, PaymentState> {
  PaymentBloc({
    required GetPaymentsUseCase getPayments,
    required InitiatePaymentUseCase initiatePayment,
    required VerifyPaymentUseCase verifyPayment,
  })  : _getPayments = getPayments,
        _initiatePayment = initiatePayment,
        _verifyPayment = verifyPayment,
        super(const PaymentInitialState()) {
    on<LoadPaymentsEvent>(_onLoad);
    on<LoadMorePaymentsEvent>(_onLoadMore);
    on<FilterPaymentsByStatusEvent>(_onFilter);
    on<RefreshPaymentsEvent>(_onRefresh);
    on<InitiatePaymentEvent>(_onInitiate);
    on<VerifyPaymentEvent>(_onVerify);
  }

  final GetPaymentsUseCase _getPayments;
  final InitiatePaymentUseCase _initiatePayment;
  final VerifyPaymentUseCase _verifyPayment;
  PaymentStatus? _statusFilter;

  Future<void> _onLoad(LoadPaymentsEvent event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoadingState());
    _statusFilter = null;
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

  Future<void> _onLoadMore(LoadMorePaymentsEvent event, Emitter<PaymentState> emit) async {
    if (state is! PaymentsLoadedState) return;
    final loaded = state as PaymentsLoadedState;
    if (!loaded.hasMore || loaded.isLoadingMore) return;
    emit(loaded.copyWith(isLoadingMore: true));
    final result = await _getPayments(
        GetPaymentsParams(page: loaded.currentPage + 1, status: _statusFilter));
    result.fold(
      (f) => emit(loaded.copyWith(isLoadingMore: false)),
      (page) => emit(loaded.copyWith(
        payments: [...loaded.payments, ...page.items],
        hasMore: page.hasNextPage,
        currentPage: page.currentPage,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onFilter(
      FilterPaymentsByStatusEvent event, Emitter<PaymentState> emit) async {
    _statusFilter = event.status;
    emit(const PaymentLoadingState());
    final result = await _getPayments(GetPaymentsParams(status: event.status));
    result.fold(
      (f) => emit(PaymentErrorState(failure: f)),
      (page) => emit(PaymentsLoadedState(
        payments: page.items,
        hasMore: page.hasNextPage,
        currentPage: page.currentPage,
        statusFilter: event.status,
      )),
    );
  }

  Future<void> _onRefresh(RefreshPaymentsEvent event, Emitter<PaymentState> emit) async {
    add(const LoadPaymentsEvent());
  }

  Future<void> _onInitiate(InitiatePaymentEvent event, Emitter<PaymentState> emit) async {
    emit(const PaymentInitiatingState());
    final result = await _initiatePayment(InitiatePaymentParams(
      bookingId: event.bookingId,
      amount: event.amount,
      gateway: event.gateway,
    ));
    result.fold(
      (f) => emit(PaymentErrorState(failure: f)),
      (order) => emit(PaymentOrderCreatedState(order: order)),
    );
  }

  Future<void> _onVerify(VerifyPaymentEvent event, Emitter<PaymentState> emit) async {
    emit(const PaymentInitiatingState());
    final result = await _verifyPayment(VerifyPaymentParams(
      paymentId: event.paymentId,
      gatewayOrderId: event.gatewayOrderId,
      gatewayPaymentId: event.gatewayPaymentId,
      signature: event.signature,
      gateway: event.gateway,
    ));
    result.fold(
      (f) => emit(PaymentErrorState(failure: f)),
      (payment) => emit(PaymentVerifiedState(payment: payment)),
    );
  }
}
