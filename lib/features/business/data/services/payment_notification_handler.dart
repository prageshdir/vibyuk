import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

enum PaymentNotificationType {
  paymentSuccess,
  paymentFailed,
  escrowHeld,
  escrowReleased,
  refundApproved,
  refundFailed,
  payoutProcessed,
  payoutFailed,
  invoiceReady,
}

class PaymentNotificationPayload {
  const PaymentNotificationPayload({
    required this.type,
    this.paymentId,
    this.bookingId,
    this.escrowId,
    this.amount,
  });

  final PaymentNotificationType type;
  final String? paymentId;
  final String? bookingId;
  final String? escrowId;
  final double? amount;
}

class PaymentNotificationHandler {
  PaymentNotificationHandler._();

  static void handleMessage(
    RemoteMessage message, {
    void Function(PaymentNotificationPayload)? onPaymentEvent,
  }) {
    final data = message.data;
    final typeStr = data['payment_event'] as String?;
    if (typeStr == null) return;

    final type = _typeFromString(typeStr);
    if (type == null) return;

    final payload = PaymentNotificationPayload(
      type: type,
      paymentId: data['payment_id'] as String?,
      bookingId: data['booking_id'] as String?,
      escrowId: data['escrow_id'] as String?,
      amount: data['amount'] != null
          ? double.tryParse(data['amount'].toString())
          : null,
    );

    if (kDebugMode) {
      debugPrint('[PaymentNotification] type=$typeStr payload=$data');
    }

    onPaymentEvent?.call(payload);
  }

  static PaymentNotificationType? _typeFromString(String s) => switch (s) {
        'payment_success' => PaymentNotificationType.paymentSuccess,
        'payment_failed' => PaymentNotificationType.paymentFailed,
        'escrow_held' => PaymentNotificationType.escrowHeld,
        'escrow_released' => PaymentNotificationType.escrowReleased,
        'refund_approved' => PaymentNotificationType.refundApproved,
        'refund_failed' => PaymentNotificationType.refundFailed,
        'payout_processed' => PaymentNotificationType.payoutProcessed,
        'payout_failed' => PaymentNotificationType.payoutFailed,
        'invoice_ready' => PaymentNotificationType.invoiceReady,
        _ => null,
      };
}
