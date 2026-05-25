import 'package:vibyuk/features/business/domain/entities/payment_analytics_entity.dart';

class PaymentTrendPointModel {
  const PaymentTrendPointModel({
    required this.label,
    required this.amount,
    required this.count,
  });
  final String label;
  final double amount;
  final int count;

  factory PaymentTrendPointModel.fromJson(Map<String, dynamic> j) =>
      PaymentTrendPointModel(
        label: j['label'] as String,
        amount: (j['amount'] as num).toDouble(),
        count: j['count'] as int? ?? 0,
      );

  PaymentTrendPoint toEntity() =>
      PaymentTrendPoint(label: label, amount: amount, count: count);
}

class PaymentAnalyticsModel {
  const PaymentAnalyticsModel({
    required this.totalPayments,
    required this.successfulPayments,
    required this.failedPayments,
    required this.refundedPayments,
    required this.totalAmount,
    required this.totalRefunded,
    required this.escrowHeldAmount,
    required this.escrowReleasedAmount,
    required this.successRate,
    required this.avgTransactionAmount,
    required this.monthlyTrend,
    required this.gatewayBreakdown,
    required this.period,
  });

  final int totalPayments;
  final int successfulPayments;
  final int failedPayments;
  final int refundedPayments;
  final double totalAmount;
  final double totalRefunded;
  final double escrowHeldAmount;
  final double escrowReleasedAmount;
  final double successRate;
  final double avgTransactionAmount;
  final List<PaymentTrendPointModel> monthlyTrend;
  final Map<String, int> gatewayBreakdown;
  final String period;

  factory PaymentAnalyticsModel.fromJson(Map<String, dynamic> j) =>
      PaymentAnalyticsModel(
        totalPayments: j['total_payments'] as int? ?? 0,
        successfulPayments: j['successful_payments'] as int? ?? 0,
        failedPayments: j['failed_payments'] as int? ?? 0,
        refundedPayments: j['refunded_payments'] as int? ?? 0,
        totalAmount: (j['total_amount'] as num? ?? 0).toDouble(),
        totalRefunded: (j['total_refunded'] as num? ?? 0).toDouble(),
        escrowHeldAmount: (j['escrow_held_amount'] as num? ?? 0).toDouble(),
        escrowReleasedAmount:
            (j['escrow_released_amount'] as num? ?? 0).toDouble(),
        successRate: (j['success_rate'] as num? ?? 0).toDouble(),
        avgTransactionAmount:
            (j['avg_transaction_amount'] as num? ?? 0).toDouble(),
        monthlyTrend: (j['monthly_trend'] as List? ?? [])
            .map((e) =>
                PaymentTrendPointModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        gatewayBreakdown: (j['gateway_breakdown'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toInt())),
        period: j['period'] as String? ?? '30d',
      );

  PaymentAnalyticsEntity toEntity() => PaymentAnalyticsEntity(
        totalPayments: totalPayments,
        successfulPayments: successfulPayments,
        failedPayments: failedPayments,
        refundedPayments: refundedPayments,
        totalAmount: totalAmount,
        totalRefunded: totalRefunded,
        escrowHeldAmount: escrowHeldAmount,
        escrowReleasedAmount: escrowReleasedAmount,
        successRate: successRate,
        avgTransactionAmount: avgTransactionAmount,
        monthlyTrend: monthlyTrend.map((e) => e.toEntity()).toList(),
        gatewayBreakdown: gatewayBreakdown,
        period: period,
      );
}
