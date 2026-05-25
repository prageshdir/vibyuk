import 'package:equatable/equatable.dart';

class PaymentAnalyticsEntity extends Equatable {
  const PaymentAnalyticsEntity({
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
  final List<PaymentTrendPoint> monthlyTrend;
  final Map<String, int> gatewayBreakdown;
  final String period;

  String get totalAmountDisplay => '₹${totalAmount.toStringAsFixed(0)}';
  String get successRateDisplay => '${(successRate * 100).toStringAsFixed(1)}%';
  String get avgTransactionDisplay => '₹${avgTransactionAmount.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
        totalPayments, successfulPayments, failedPayments, refundedPayments,
        totalAmount, totalRefunded, escrowHeldAmount, escrowReleasedAmount,
        successRate, avgTransactionAmount, monthlyTrend, gatewayBreakdown, period,
      ];
}

class PaymentTrendPoint extends Equatable {
  const PaymentTrendPoint({
    required this.label,
    required this.amount,
    required this.count,
  });
  final String label;
  final double amount;
  final int count;

  @override
  List<Object?> get props => [label, amount, count];
}
