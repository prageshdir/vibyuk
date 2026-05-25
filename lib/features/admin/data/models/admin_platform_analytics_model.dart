import 'package:vibyuk/features/admin/domain/entities/admin_platform_analytics.dart';

class AdminTimeSeriesPointModel extends AdminTimeSeriesPoint {
  const AdminTimeSeriesPointModel({
    required super.label,
    required super.value,
    required super.date,
  });

  factory AdminTimeSeriesPointModel.fromJson(Map<String, dynamic> json) {
    return AdminTimeSeriesPointModel(
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

class AdminCategoryBreakdownModel extends AdminCategoryBreakdown {
  const AdminCategoryBreakdownModel({
    required super.label,
    required super.value,
    required super.percentage,
    super.previousValue,
  });

  factory AdminCategoryBreakdownModel.fromJson(Map<String, dynamic> json) {
    return AdminCategoryBreakdownModel(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      previousValue: (json['previous_value'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'value': value,
        'percentage': percentage,
        'previous_value': previousValue,
      };
}

class AdminPlatformKpiModel extends AdminPlatformKpi {
  const AdminPlatformKpiModel({
    required super.label,
    required super.value,
    super.previousValue,
    super.unit,
    super.isPositiveTrend,
  });

  factory AdminPlatformKpiModel.fromJson(Map<String, dynamic> json) {
    return AdminPlatformKpiModel(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      previousValue: (json['previous_value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      isPositiveTrend: json['is_positive_trend'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'value': value,
        'previous_value': previousValue,
        'unit': unit,
        'is_positive_trend': isPositiveTrend,
      };
}

class AdminPlatformAnalyticsModel extends AdminPlatformAnalytics {
  const AdminPlatformAnalyticsModel({
    required super.id,
    required super.period,
    required super.totalUsers,
    required super.newUsers,
    required super.activeUsers,
    required super.totalCreators,
    required super.newCreators,
    required super.creatorToClientRatio,
    required super.totalBookings,
    required super.completedBookings,
    required super.cancelledBookings,
    required super.bookingCompletionRate,
    required super.averageBookingValue,
    required super.totalRevenue,
    required super.platformFeeRevenue,
    required super.openDisputes,
    required super.resolvedDisputes,
    required super.disputeResolutionRate,
    required super.averageResolutionTimeDays,
    required super.pendingVerifications,
    required super.openReports,
    required super.revenueTimeline,
    required super.userGrowthTimeline,
    required super.bookingsTimeline,
    required super.disputesTimeline,
    required super.revenueByCategory,
    required super.usersByRegion,
    required super.bookingsByCreatorCategory,
    required super.kpis,
    required super.generatedAt,
  });

  factory AdminPlatformAnalyticsModel.fromJson(Map<String, dynamic> json) {
    List<AdminTimeSeriesPoint> _parseTimeSeries(dynamic raw) =>
        (raw as List<dynamic>? ?? [])
            .map((e) => AdminTimeSeriesPointModel.fromJson(
                  e as Map<String, dynamic>,
                ))
            .toList();

    List<AdminCategoryBreakdown> _parseBreakdown(dynamic raw) =>
        (raw as List<dynamic>? ?? [])
            .map((e) => AdminCategoryBreakdownModel.fromJson(
                  e as Map<String, dynamic>,
                ))
            .toList();

    return AdminPlatformAnalyticsModel(
      id: json['id'] as String,
      period: AdminAnalyticsPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => AdminAnalyticsPeriod.last30Days,
      ),
      totalUsers: json['total_users'] as int? ?? 0,
      newUsers: json['new_users'] as int? ?? 0,
      activeUsers: json['active_users'] as int? ?? 0,
      totalCreators: json['total_creators'] as int? ?? 0,
      newCreators: json['new_creators'] as int? ?? 0,
      creatorToClientRatio:
          (json['creator_to_client_ratio'] as num?)?.toDouble() ?? 0,
      totalBookings: json['total_bookings'] as int? ?? 0,
      completedBookings: json['completed_bookings'] as int? ?? 0,
      cancelledBookings: json['cancelled_bookings'] as int? ?? 0,
      bookingCompletionRate:
          (json['booking_completion_rate'] as num?)?.toDouble() ?? 0,
      averageBookingValue:
          (json['average_booking_value'] as num?)?.toDouble() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      platformFeeRevenue:
          (json['platform_fee_revenue'] as num?)?.toDouble() ?? 0,
      openDisputes: json['open_disputes'] as int? ?? 0,
      resolvedDisputes: json['resolved_disputes'] as int? ?? 0,
      disputeResolutionRate:
          (json['dispute_resolution_rate'] as num?)?.toDouble() ?? 0,
      averageResolutionTimeDays:
          (json['average_resolution_time_days'] as num?)?.toDouble() ?? 0,
      pendingVerifications: json['pending_verifications'] as int? ?? 0,
      openReports: json['open_reports'] as int? ?? 0,
      revenueTimeline: _parseTimeSeries(json['revenue_timeline']),
      userGrowthTimeline: _parseTimeSeries(json['user_growth_timeline']),
      bookingsTimeline: _parseTimeSeries(json['bookings_timeline']),
      disputesTimeline: _parseTimeSeries(json['disputes_timeline']),
      revenueByCategory: _parseBreakdown(json['revenue_by_category']),
      usersByRegion: _parseBreakdown(json['users_by_region']),
      bookingsByCreatorCategory:
          _parseBreakdown(json['bookings_by_creator_category']),
      kpis: (json['kpis'] as List<dynamic>? ?? [])
          .map((e) =>
              AdminPlatformKpiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }
}
