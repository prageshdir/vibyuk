import 'package:vibyuk/features/business/domain/entities/payment_order_entity.dart';

class PaymentOrderModel {
  const PaymentOrderModel({
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
  final String gateway;
  final double amount;
  final String currency;
  final String keyId;
  final String? cfOrderToken;
  final String? razorpayOrderId;
  final String bookingId;
  final String paymentId;

  factory PaymentOrderModel.fromJson(Map<String, dynamic> j) =>
      PaymentOrderModel(
        orderId: j['order_id'] as String,
        gateway: j['gateway'] as String? ?? 'razorpay',
        amount: (j['amount'] as num).toDouble(),
        currency: j['currency'] as String? ?? 'INR',
        keyId: j['key_id'] as String,
        cfOrderToken: j['cf_order_token'] as String?,
        razorpayOrderId: j['razorpay_order_id'] as String?,
        bookingId: j['booking_id'] as String,
        paymentId: j['payment_id'] as String,
      );

  PaymentOrderEntity toEntity() => PaymentOrderEntity(
        orderId: orderId,
        gateway: gateway == 'cashfree'
            ? PaymentGateway.cashfree
            : PaymentGateway.razorpay,
        amount: amount,
        currency: currency,
        keyId: keyId,
        cfOrderToken: cfOrderToken,
        razorpayOrderId: razorpayOrderId,
        bookingId: bookingId,
        paymentId: paymentId,
      );
}
