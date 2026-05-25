import 'package:vibyuk/features/ai/domain/entities/ai_analytics.dart';

class AiMetricPointModel extends AiMetricPoint {
  const AiMetricPointModel({
    required super.label,
    required super.value,
    required super.date,
  });

  factory AiMetricPointModel.fromJson(Map<String, dynamic> json) {
    return AiMetricPointModel(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'value': value,
        'date': date.toIso8601String(),
      };
}

class AiTopCreatorModel extends AiTopCreator {
  const AiTopCreatorModel({
    required super.creatorId,
    required super.creatorName,
    super.avatarUrl,
    required super.revenue,
    required super.bookings,
    required super.rating,
  });

  factory AiTopCreatorModel.fromJson(Map<String, dynamic> json) {
    return AiTopCreatorModel(
      creatorId: json['creator_id'] as String,
      creatorName: json['creator_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      revenue: (json['revenue'] as num).toDouble(),
      bookings: json['bookings'] as int,
      rating: (json['rating'] as num).toDouble(),
    );
  }
}

class AiCategoryRevenueModel extends AiCategoryRevenue {
  const AiCategoryRevenueModel({
    required super.category,
    required super.revenue,
    required super.percentage,
  });

  factory AiCategoryRevenueModel.fromJson(Map<String, dynamic> json) {
    return AiCategoryRevenueModel(
      category: json['category'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class AiAnalyticsModel extends AiAnalytics {
  const AiAnalyticsModel({
    required super.id,
    required super.period,
    required super.totalRevenue,
    required super.revenueGrowthRate,
    required super.revenueTrend,
    required super.totalBookings,
    required super.bookingsGrowthRate,
    required super.bookingsTrend,
    required super.avgBookingValue,
    required super.conversionRate,
    required super.topCreators,
    required super.revenueByCategory,
    required super.revenueTimeline,
    required super.bookingsTimeline,
    required super.projectedRevenue,
    required super.clientRetentionRate,
    required super.generatedAt,
  });

  factory AiAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AiAnalyticsModel(
      id: json['id'] as String,
      period: AnalyticsPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => AnalyticsPeriod.last30Days,
      ),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      revenueGrowthRate: (json['revenue_growth_rate'] as num).toDouble(),
      revenueTrend: MetricTrend.values.firstWhere(
        (e) => e.name == json['revenue_trend'],
        orElse: () => MetricTrend.stable,
      ),
      totalBookings: json['total_bookings'] as int,
      bookingsGrowthRate: (json['bookings_growth_rate'] as num).toDouble(),
      bookingsTrend: MetricTrend.values.firstWhere(
        (e) => e.name == json['bookings_trend'],
        orElse: () => MetricTrend.stable,
      ),
      avgBookingValue: (json['avg_booking_value'] as num).toDouble(),
      conversionRate: (json['conversion_rate'] as num).toDouble(),
      topCreators: (json['top_creators'] as List)
          .map((c) => AiTopCreatorModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      revenueByCategory: (json['revenue_by_category'] as List)
          .map((c) =>
              AiCategoryRevenueModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      revenueTimeline: (json['revenue_timeline'] as List)
          .map((p) => AiMetricPointModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      bookingsTimeline: (json['bookings_timeline'] as List)
          .map((p) => AiMetricPointModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      projectedRevenue: (json['projected_revenue'] as num).toDouble(),
      clientRetentionRate: (json['client_retention_rate'] as num).toDouble(),
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }
}
