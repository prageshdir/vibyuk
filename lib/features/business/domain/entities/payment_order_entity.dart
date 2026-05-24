import 'package:equatable/equatable.dart';

enum PaymentGateway { razorpay, cashfree }

class PaymentOrderEntity extends Equatable {
  const PaymentOrderEntity({
    required this.orderId,
    required this.gateway,
    required this.amount,
    required this.currency,
    required this.keyId,
    this.cfOrderToken,
    this.razorpayOrderId,
    required this.bookingId,
    required this.paymentId,
  });

  final String orderId;
  final PaymentGateway gateway;
  final double amount;
  final String currency;
  final String keyId;
  final String? cfOrderToken;
  final String? razorpayOrderId;
  final String bookingId;
  final String paymentId;

  @override
  List<Object?> get props => [
        orderId, gateway, amount, currency, keyId,
        cfOrderToken, razorpayOrderId, bookingId, paymentId,
      ];
}
