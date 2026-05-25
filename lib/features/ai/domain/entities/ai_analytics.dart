import 'package:equatable/equatable.dart';

enum AnalyticsPeriod { last7Days, last30Days, last90Days, last12Months }
enum MetricTrend { up, down, stable }

class AiMetricPoint extends Equatable {
  final String label;
  final double value;
  final DateTime date;

  const AiMetricPoint({
    required this.label,
    required this.value,
    required this.date,
  });

  @override
  List<Object?> get props => [label, value, date];
}

class AiTopCreator extends Equatable {
  final String creatorId;
  final String creatorName;
  final String? avatarUrl;
  final double revenue;
  final int bookings;
  final double rating;

  const AiTopCreator({
    required this.creatorId,
    required this.creatorName,
    this.avatarUrl,
    required this.revenue,
    required this.bookings,
    required this.rating,
  });

  @override
  List<Object?> get props => [creatorId, creatorName, avatarUrl, revenue, bookings, rating];
}

class AiCategoryRevenue extends Equatable {
  final String category;
  final double revenue;
  final double percentage;

  const AiCategoryRevenue({
    required this.category,
    required this.revenue,
    required this.percentage,
  });

  @override
  List<Object?> get props => [category, revenue, percentage];
}

class AiAnalytics extends Equatable {
  final String id;
  final AnalyticsPeriod period;
  final double totalRevenue;
  final double revenueGrowthRate;
  final MetricTrend revenueTrend;
  final int totalBookings;
  final double bookingsGrowthRate;
  final MetricTrend bookingsTrend;
  final double avgBookingValue;
  final double conversionRate;
  final List<AiTopCreator> topCreators;
  final List<AiCategoryRevenue> revenueByCategory;
  final List<AiMetricPoint> revenueTimeline;
  final List<AiMetricPoint> bookingsTimeline;
  final double projectedRevenue;
  final double clientRetentionRate;
  final DateTime generatedAt;

  const AiAnalytics({
    required this.id,
    required this.period,
    required this.totalRevenue,
    required this.revenueGrowthRate,
    required this.revenueTrend,
    required this.totalBookings,
    required this.bookingsGrowthRate,
    required this.bookingsTrend,
    required this.avgBookingValue,
    required this.conversionRate,
    required this.topCreators,
    required this.revenueByCategory,
    required this.revenueTimeline,
    required this.bookingsTimeline,
    required this.projectedRevenue,
    required this.clientRetentionRate,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        period,
        totalRevenue,
        revenueGrowthRate,
        revenueTrend,
        totalBookings,
        bookingsGrowthRate,
        bookingsTrend,
        avgBookingValue,
        conversionRate,
        topCreators,
        revenueByCategory,
        revenueTimeline,
        bookingsTimeline,
        projectedRevenue,
        clientRetentionRate,
        generatedAt,
      ];
}
