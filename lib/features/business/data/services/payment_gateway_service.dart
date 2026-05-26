import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vibyuk/features/business/domain/entities/payment_order_entity.dart';

class PaymentResult {
  const PaymentResult({
    required this.success,
    this.gatewayPaymentId,
    this.signature,
    this.errorCode,
    this.errorMessage,
  });

  final bool success;
  final String? gatewayPaymentId;
  final String? signature;
  final int? errorCode;
  final String? errorMessage;

  factory PaymentResult.success({
    required String gatewayPaymentId,
    required String signature,
  }) =>
      PaymentResult(
        success: true,
        gatewayPaymentId: gatewayPaymentId,
        signature: signature,
      );

  factory PaymentResult.failure({int? code, String? message}) =>
      PaymentResult(
        success: false,
        errorCode: code,
        errorMessage: message,
      );

  factory PaymentResult.cancelled() =>
      const PaymentResult(success: false, errorMessage: 'Payment cancelled');
}

class PaymentGatewayService {
  PaymentGatewayService();

  Razorpay? _razorpay;
  Completer<PaymentResult>? _completer;

  Future<PaymentResult> launchPayment(PaymentOrderEntity order) {
    return switch (order.gateway) {
      PaymentGateway.razorpay => _launchRazorpay(order),
      PaymentGateway.cashfree => _launchCashfree(order),
    };
  }

  Future<PaymentResult> _launchRazorpay(PaymentOrderEntity order) {
    _completer = Completer<PaymentResult>();

    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onRazorpaySuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _onRazorpayError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    final options = <String, dynamic>{
      'key': order.keyId,
      'amount': (order.amount * 100).toInt(), // Razorpay expects paise
      'currency': order.currency,
      'order_id': order.razorpayOrderId ?? order.orderId,
      'name': 'Vibyuk',
      'description': 'Booking payment',
      'prefill': <String, dynamic>{},
      'external': <String, dynamic>{
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      _completer!.complete(PaymentResult.failure(message: e.toString()));
    }

    return _completer!.future;
  }

  Future<PaymentResult> _launchCashfree(PaymentOrderEntity order) async {
    // Cashfree uses a token-based flow; the actual SDK call requires
    // platform-specific setup. This stub returns failure until the
    // cashfree_pg package is integrated and configured.
    if (kDebugMode) {
      debugPrint('[PaymentGateway] Cashfree: token=${order.cfOrderToken}');
    }
    return PaymentResult.failure(
      message: 'Cashfree native SDK not yet configured. '
          'Order token: ${order.cfOrderToken}',
    );
  }

  void _onRazorpaySuccess(PaymentSuccessResponse response) {
    _razorpay?.clear();
    _completer?.complete(PaymentResult.success(
      gatewayPaymentId: response.paymentId ?? '',
      signature: response.signature ?? '',
    ));
    _cleanup();
  }

  void _onRazorpayError(PaymentFailureResponse response) {
    _razorpay?.clear();
    _completer?.complete(PaymentResult.failure(
      code: response.code,
      message: response.message,
    ));
    _cleanup();
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    _razorpay?.clear();
    _completer?.complete(PaymentResult.failure(
      message: 'External wallet selected: ${response.walletName}',
    ));
    _cleanup();
  }

  void _cleanup() {
    _razorpay = null;
    _completer = null;
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
