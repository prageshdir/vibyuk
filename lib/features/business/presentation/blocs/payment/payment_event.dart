part of 'payment_bloc.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();
}

class LoadPaymentsEvent extends PaymentEvent {
  const LoadPaymentsEvent();
  @override
  List<Object?> get props => [];
}

class LoadMorePaymentsEvent extends PaymentEvent {
  const LoadMorePaymentsEvent();
  @override
  List<Object?> get props => [];
}
