import 'package:equatable/equatable.dart';

class CreatorEarningsEntity extends Equatable {
  final String creatorId;
  final double totalEarnings;
  final double pendingPayout;
  final double availableBalance;
  final double lifetimeEarnings;
  final List<EarningsPeriodEntity> earningsHistory;
  final List<PayoutEntity> recentPayouts;

  const CreatorEarningsEntity({
    required this.creatorId,
    required this.totalEarnings,
    required this.pendingPayout,
    required this.availableBalance,
    required this.lifetimeEarnings,
    required this.earningsHistory,
    required this.recentPayouts,
  });

  @override
  List<Object?> get props => [
        creatorId,
        totalEarnings,
        pendingPayout,
        availableBalance,
        lifetimeEarnings,
        earningsHistory,
        recentPayouts,
      ];
}

class EarningsPeriodEntity extends Equatable {
  final DateTime periodStart;
  final DateTime periodEnd;
  final double amount;
  final int bookingCount;
  final String currency;

  const EarningsPeriodEntity({
    required this.periodStart,
    required this.periodEnd,
    required this.amount,
    required this.bookingCount,
    required this.currency,
  });

  @override
  List<Object?> get props => [periodStart, periodEnd, amount, bookingCount, currency];
}

enum PayoutStatus { pending, processing, completed, failed }

class PayoutEntity extends Equatable {
  final String id;
  final double amount;
  final String currency;
  final PayoutStatus status;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final String? bankLast4;

  const PayoutEntity({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.requestedAt,
    this.completedAt,
    this.bankLast4,
  });

  @override
  List<Object?> get props => [id, amount, currency, status, requestedAt, completedAt, bankLast4];
}
