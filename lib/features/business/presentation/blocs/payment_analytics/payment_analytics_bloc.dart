import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/payment_analytics_entity.dart';
import 'package:vibyuk/features/business/domain/usecases/payment/get_payment_analytics_use_case.dart';

part 'payment_analytics_event.dart';
part 'payment_analytics_state.dart';

class PaymentAnalyticsBloc
    extends BaseBloc<PaymentAnalyticsEvent, PaymentAnalyticsState> {
  PaymentAnalyticsBloc({required GetPaymentAnalyticsUseCase getAnalytics})
      : _getAnalytics = getAnalytics,
        super(const PaymentAnalyticsInitialState()) {
    on<LoadPaymentAnalyticsEvent>(_onLoad);
    on<ChangePeriodPaymentAnalyticsEvent>(_onChangePeriod);
  }

  final GetPaymentAnalyticsUseCase _getAnalytics;

  Future<void> _onLoad(
      LoadPaymentAnalyticsEvent event, Emitter<PaymentAnalyticsState> emit) async {
    emit(const PaymentAnalyticsLoadingState());
    final result = await _getAnalytics(
        GetPaymentAnalyticsParams(period: event.period ?? '30d'));
    result.fold(
      (f) => emit(PaymentAnalyticsErrorState(failure: f)),
      (analytics) => emit(PaymentAnalyticsLoadedState(analytics: analytics)),
    );
  }

  Future<void> _onChangePeriod(
      ChangePeriodPaymentAnalyticsEvent event, Emitter<PaymentAnalyticsState> emit) async {
    emit(const PaymentAnalyticsLoadingState());
    final result = await _getAnalytics(GetPaymentAnalyticsParams(period: event.period));
    result.fold(
      (f) => emit(PaymentAnalyticsErrorState(failure: f)),
      (analytics) => emit(PaymentAnalyticsLoadedState(analytics: analytics)),
    );
  }
}
