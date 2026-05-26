import 'package:vibyuk/features/creator/domain/entities/creator_earnings_entity.dart';

class CreatorEarningsModel {
  const CreatorEarningsModel({
    required this.creatorId,
    required this.totalEarnings,
    required this.pendingPayout,
    required this.availableBalance,
    required this.lifetimeEarnings,
    this.earningsHistory = const [],
    this.recentPayouts = const [],
  });

  final String creatorId;
  final double totalEarnings;
  final double pendingPayout;
  final double availableBalance;
  final double lifetimeEarnings;
  final List<EarningsPeriodModel> earningsHistory;
  final List<PayoutModel> recentPayouts;

  factory CreatorEarningsModel.fromJson(Map<String, dynamic> json) =>
      CreatorEarningsModel(
        creatorId: json['creator_id'] as String,
        totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
        pendingPayout: (json['pending_payout'] as num?)?.toDouble() ?? 0.0,
        availableBalance: (json['available_balance'] as num?)?.toDouble() ?? 0.0,
        lifetimeEarnings: (json['lifetime_earnings'] as num?)?.toDouble() ?? 0.0,
        earningsHistory: (json['earnings_history'] as List?)
                ?.map((e) =>
                    EarningsPeriodModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        recentPayouts: (json['recent_payouts'] as List?)
                ?.map((e) => PayoutModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  CreatorEarningsEntity toEntity() => CreatorEarningsEntity(
        creatorId: creatorId,
        totalEarnings: totalEarnings,
        pendingPayout: pendingPayout,
        availableBalance: availableBalance,
        lifetimeEarnings: lifetimeEarnings,
        earningsHistory: earningsHistory.map((e) => e.toEntity()).toList(),
        recentPayouts: recentPayouts.map((e) => e.toEntity()).toList(),
      );
}

class EarningsPeriodModel {
  const EarningsPeriodModel({
    required this.periodStart,
    required this.periodEnd,
    required this.amount,
    required this.bookingCount,
    required this.currency,
  });

  final String periodStart;
  final String periodEnd;
  final double amount;
  final int bookingCount;
  final String currency;

  factory EarningsPeriodModel.fromJson(Map<String, dynamic> json) =>
      EarningsPeriodModel(
        periodStart: json['period_start'] as String,
        periodEnd: json['period_end'] as String,
        amount: (json['amount'] as num).toDouble(),
        bookingCount: json['booking_count'] as int? ?? 0,
        currency: json['currency'] as String? ?? 'GBP',
      );

  EarningsPeriodEntity toEntity() => EarningsPeriodEntity(
        periodStart: DateTime.parse(periodStart),
        periodEnd: DateTime.parse(periodEnd),
        amount: amount,
        bookingCount: bookingCount,
        currency: currency,
      );
}

class PayoutModel {
  const PayoutModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.requestedAt,
    this.completedAt,
    this.bankLast4,
  });

  final String id;
  final double amount;
  final String currency;
  final String status;
  final String requestedAt;
  final String? completedAt;
  final String? bankLast4;

  factory PayoutModel.fromJson(Map<String, dynamic> json) => PayoutModel(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'GBP',
        status: json['status'] as String? ?? 'pending',
        requestedAt: json['requested_at'] as String,
        completedAt: json['completed_at'] as String?,
        bankLast4: json['bank_last4'] as String?,
      );

  PayoutEntity toEntity() => PayoutEntity(
        id: id,
        amount: amount,
        currency: currency,
        status: PayoutStatus.values.firstWhere(
          (e) => e.name == status,
          orElse: () => PayoutStatus.pending,
        ),
        requestedAt: DateTime.parse(requestedAt),
        completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
        bankLast4: bankLast4,
      );
}
