part of 'payment_analytics_bloc.dart';

sealed class PaymentAnalyticsState extends Equatable {
  const PaymentAnalyticsState();
}

class PaymentAnalyticsInitialState extends PaymentAnalyticsState {
  const PaymentAnalyticsInitialState();
  @override
  List<Object?> get props => [];
}

class PaymentAnalyticsLoadingState extends PaymentAnalyticsState {
  const PaymentAnalyticsLoadingState();
  @override
  List<Object?> get props => [];
}

class PaymentAnalyticsLoadedState extends PaymentAnalyticsState {
  const PaymentAnalyticsLoadedState({required this.analytics});
  final PaymentAnalyticsEntity analytics;
  @override
  List<Object?> get props => [analytics];
}

class PaymentAnalyticsErrorState extends PaymentAnalyticsState {
  const PaymentAnalyticsErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
