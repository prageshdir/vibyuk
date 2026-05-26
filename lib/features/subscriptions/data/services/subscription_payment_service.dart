import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';

class SubscriptionPaymentResult {
  const SubscriptionPaymentResult._({
    required this.success,
    this.paymentId,
    this.razorpayOrderId,
    this.signature,
    this.errorMessage,
  });

  final bool success;
  final String? paymentId;
  final String? razorpayOrderId;
  final String? signature;
  final String? errorMessage;

  factory SubscriptionPaymentResult.success({
    required String paymentId,
    required String razorpayOrderId,
    required String signature,
  }) =>
      SubscriptionPaymentResult._(
        success: true,
        paymentId: paymentId,
        razorpayOrderId: razorpayOrderId,
        signature: signature,
      );

  factory SubscriptionPaymentResult.failure(String message) =>
      SubscriptionPaymentResult._(success: false, errorMessage: message);

  factory SubscriptionPaymentResult.cancelled() =>
      const SubscriptionPaymentResult._(
        success: false,
        errorMessage: 'Payment cancelled',
      );
}

class SubscriptionPaymentService {
  Razorpay? _razorpay;
  Completer<SubscriptionPaymentResult>? _completer;

  Future<SubscriptionPaymentResult> launch(RazorpayOrderEntity order) {
    _completer = Completer<SubscriptionPaymentResult>();

    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    final options = <String, dynamic>{
      'key': order.keyId,
      'amount': (order.amount * 100).toInt(),
      'currency': order.currency,
      'order_id': order.razorpayOrderId,
      'name': 'VIBYUK',
      'description': '${order.plan.displayName} subscription',
      'theme': <String, dynamic>{'color': '#7B2FFF'},
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      _completer!.complete(SubscriptionPaymentResult.failure(e.toString()));
      _cleanup();
    }

    return _completer!.future;
  }

  void _onSuccess(PaymentSuccessResponse response) {
    _completer?.complete(
      SubscriptionPaymentResult.success(
        paymentId: response.paymentId ?? '',
        razorpayOrderId: response.orderId ?? '',
        signature: response.signature ?? '',
      ),
    );
    _cleanup();
  }

  void _onError(PaymentFailureResponse response) {
    final cancelled = response.code == Razorpay.PAYMENT_CANCELLED;
    _completer?.complete(
      cancelled
          ? SubscriptionPaymentResult.cancelled()
          : SubscriptionPaymentResult.failure(response.message ?? 'Payment failed'),
    );
    _cleanup();
  }

  void _onExternalWallet(ExternalWalletResponse _) {
    _completer?.complete(
      SubscriptionPaymentResult.failure('External wallet not supported for subscriptions'),
    );
    _cleanup();
  }

  void _cleanup() {
    _razorpay?.clear();
    _razorpay = null;
    _completer = null;
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
