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

class FilterPaymentsByStatusEvent extends PaymentEvent {
  const FilterPaymentsByStatusEvent(this.status);
  final PaymentStatus? status;
  @override
  List<Object?> get props => [status];
}

class RefreshPaymentsEvent extends PaymentEvent {
  const RefreshPaymentsEvent();
  @override
  List<Object?> get props => [];
}

class InitiatePaymentEvent extends PaymentEvent {
  const InitiatePaymentEvent({
    required this.bookingId,
    required this.amount,
    required this.gateway,
  });
  final String bookingId;
  final double amount;
  final PaymentGateway gateway;
  @override
  List<Object?> get props => [bookingId, amount, gateway];
}

class VerifyPaymentEvent extends PaymentEvent {
  const VerifyPaymentEvent({
    required this.paymentId,
    required this.gatewayOrderId,
    required this.gatewayPaymentId,
    required this.signature,
    required this.gateway,
  });
  final String paymentId;
  final String gatewayOrderId;
  final String gatewayPaymentId;
  final String signature;
  final PaymentGateway gateway;
  @override
  List<Object?> get props => [
        paymentId,
        gatewayOrderId,
        gatewayPaymentId,
        signature,
        gateway,
      ];
}
