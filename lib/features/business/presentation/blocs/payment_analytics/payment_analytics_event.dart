part of 'payment_analytics_bloc.dart';

sealed class PaymentAnalyticsEvent extends Equatable {
  const PaymentAnalyticsEvent();
}

class LoadPaymentAnalyticsEvent extends PaymentAnalyticsEvent {
  const LoadPaymentAnalyticsEvent({this.period});
  final String? period;
  @override
  List<Object?> get props => [period];
}

class ChangePeriodPaymentAnalyticsEvent extends PaymentAnalyticsEvent {
  const ChangePeriodPaymentAnalyticsEvent(this.period);
  final String period;
  @override
  List<Object?> get props => [period];
}
