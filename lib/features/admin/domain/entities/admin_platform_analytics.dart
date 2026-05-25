import 'package:equatable/equatable.dart';

enum AdminAnalyticsPeriod { today, last7Days, last30Days, last90Days, lastYear }

class AdminTimeSeriesPoint extends Equatable {
  final String label;
  final double value;
  final DateTime date;

  const AdminTimeSeriesPoint({
    required this.label,
    required this.value,
    required this.date,
  });

  @override
  List<Object?> get props => [label, value, date];
}

class AdminCategoryBreakdown extends Equatable {
  final String label;
  final double value;
  final double percentage;
  final double? previousValue;

  const AdminCategoryBreakdown({
    required this.label,
    required this.value,
    required this.percentage,
    this.previousValue,
  });

  double get growthRate => previousValue != null && previousValue! > 0
      ? ((value - previousValue!) / previousValue!) * 100
      : 0;

  @override
  List<Object?> get props => [label, value, percentage, previousValue];
}

class AdminPlatformKpi extends Equatable {
  final String label;
  final double value;
  final double? previousValue;
  final String? unit;
  final bool isPositiveTrend;

  const AdminPlatformKpi({
    required this.label,
    required this.value,
    this.previousValue,
    this.unit,
    this.isPositiveTrend = true,
  });

  double get changePercent => previousValue != null && previousValue! > 0
      ? ((value - previousValue!) / previousValue!) * 100
      : 0;

  bool get isGrowing => value > (previousValue ?? 0);

  @override
  List<Object?> get props => [label, value, previousValue, unit, isPositiveTrend];
}

class AdminPlatformAnalytics extends Equatable {
  final String id;
  final AdminAnalyticsPeriod period;

  // User metrics
  final int totalUsers;
  final int newUsers;
  final int activeUsers;
  final int totalCreators;
  final int newCreators;
  final double creatorToClientRatio;

  // Booking metrics
  final int totalBookings;
  final int completedBookings;
  final int cancelledBookings;
  final double bookingCompletionRate;
  final double averageBookingValue;
  final double totalRevenue;
  final double platformFeeRevenue;

  // Support metrics
  final int openDisputes;
  final int resolvedDisputes;
  final double disputeResolutionRate;
  final double averageResolutionTimeDays;
  final int pendingVerifications;
  final int openReports;

  // Time series
  final List<AdminTimeSeriesPoint> revenueTimeline;
  final List<AdminTimeSeriesPoint> userGrowthTimeline;
  final List<AdminTimeSeriesPoint> bookingsTimeline;
  final List<AdminTimeSeriesPoint> disputesTimeline;

  // Breakdowns
  final List<AdminCategoryBreakdown> revenueByCategory;
  final List<AdminCategoryBreakdown> usersByRegion;
  final List<AdminCategoryBreakdown> bookingsByCreatorCategory;

  // KPIs for dashboard
  final List<AdminPlatformKpi> kpis;

  final DateTime generatedAt;

  const AdminPlatformAnalytics({
    required this.id,
    required this.period,
    required this.totalUsers,
    required this.newUsers,
    required this.activeUsers,
    required this.totalCreators,
    required this.newCreators,
    required this.creatorToClientRatio,
    required this.totalBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.bookingCompletionRate,
    required this.averageBookingValue,
    required this.totalRevenue,
    required this.platformFeeRevenue,
    required this.openDisputes,
    required this.resolvedDisputes,
    required this.disputeResolutionRate,
    required this.averageResolutionTimeDays,
    required this.pendingVerifications,
    required this.openReports,
    required this.revenueTimeline,
    required this.userGrowthTimeline,
    required this.bookingsTimeline,
    required this.disputesTimeline,
    required this.revenueByCategory,
    required this.usersByRegion,
    required this.bookingsByCreatorCategory,
    required this.kpis,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        id, period, totalUsers, newUsers, activeUsers, totalCreators, newCreators,
        creatorToClientRatio, totalBookings, completedBookings, cancelledBookings,
        bookingCompletionRate, averageBookingValue, totalRevenue, platformFeeRevenue,
        openDisputes, resolvedDisputes, disputeResolutionRate,
        averageResolutionTimeDays, pendingVerifications, openReports,
        revenueTimeline, userGrowthTimeline, bookingsTimeline, disputesTimeline,
        revenueByCategory, usersByRegion, bookingsByCreatorCategory, kpis, generatedAt,
      ];
}
