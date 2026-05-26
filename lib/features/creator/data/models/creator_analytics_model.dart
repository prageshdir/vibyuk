import 'package:vibyuk/features/creator/domain/entities/creator_analytics_entity.dart';

class CreatorAnalyticsModel {
  const CreatorAnalyticsModel({
    required this.creatorId,
    required this.profileViews,
    required this.profileViewsChange,
    required this.bookingRequests,
    required this.bookingRequestsChange,
    required this.acceptanceRate,
    required this.acceptanceRateChange,
    required this.averageRating,
    required this.totalReviews,
    this.viewsOverTime = const [],
    this.bookingsOverTime = const [],
    this.categoryPerformance = const [],
    this.trafficSources = const [],
  });

  final String creatorId;
  final int profileViews;
  final int profileViewsChange;
  final int bookingRequests;
  final int bookingRequestsChange;
  final double acceptanceRate;
  final double acceptanceRateChange;
  final double averageRating;
  final int totalReviews;
  final List<AnalyticsDataPointModel> viewsOverTime;
  final List<AnalyticsDataPointModel> bookingsOverTime;
  final List<CategoryPerformanceModel> categoryPerformance;
  final List<TrafficSourceModel> trafficSources;

  factory CreatorAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      CreatorAnalyticsModel(
        creatorId: json['creator_id'] as String,
        profileViews: json['profile_views'] as int? ?? 0,
        profileViewsChange: json['profile_views_change'] as int? ?? 0,
        bookingRequests: json['booking_requests'] as int? ?? 0,
        bookingRequestsChange: json['booking_requests_change'] as int? ?? 0,
        acceptanceRate: (json['acceptance_rate'] as num?)?.toDouble() ?? 0.0,
        acceptanceRateChange:
            (json['acceptance_rate_change'] as num?)?.toDouble() ?? 0.0,
        averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: json['total_reviews'] as int? ?? 0,
        viewsOverTime: (json['views_over_time'] as List?)
                ?.map((e) => AnalyticsDataPointModel.fromJson(
                    e as Map<String, dynamic>))
                .toList() ??
            [],
        bookingsOverTime: (json['bookings_over_time'] as List?)
                ?.map((e) => AnalyticsDataPointModel.fromJson(
                    e as Map<String, dynamic>))
                .toList() ??
            [],
        categoryPerformance: (json['category_performance'] as List?)
                ?.map((e) => CategoryPerformanceModel.fromJson(
                    e as Map<String, dynamic>))
                .toList() ??
            [],
        trafficSources: (json['traffic_sources'] as List?)
                ?.map((e) =>
                    TrafficSourceModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  CreatorAnalyticsEntity toEntity() => CreatorAnalyticsEntity(
        creatorId: creatorId,
        profileViews: profileViews,
        profileViewsChange: profileViewsChange,
        bookingRequests: bookingRequests,
        bookingRequestsChange: bookingRequestsChange,
        acceptanceRate: acceptanceRate,
        acceptanceRateChange: acceptanceRateChange,
        averageRating: averageRating,
        totalReviews: totalReviews,
        viewsOverTime: viewsOverTime.map((e) => e.toEntity()).toList(),
        bookingsOverTime: bookingsOverTime.map((e) => e.toEntity()).toList(),
        categoryPerformance:
            categoryPerformance.map((e) => e.toEntity()).toList(),
        trafficSources: trafficSources.map((e) => e.toEntity()).toList(),
      );
}

class AnalyticsDataPointModel {
  const AnalyticsDataPointModel({required this.date, required this.value});
  final String date;
  final double value;

  factory AnalyticsDataPointModel.fromJson(Map<String, dynamic> json) =>
      AnalyticsDataPointModel(
        date: json['date'] as String,
        value: (json['value'] as num).toDouble(),
      );

  AnalyticsDataPointEntity toEntity() => AnalyticsDataPointEntity(
        date: DateTime.parse(date),
        value: value,
      );
}

class CategoryPerformanceModel {
  const CategoryPerformanceModel({
    required this.category,
    required this.bookings,
    required this.revenue,
  });
  final String category;
  final int bookings;
  final double revenue;

  factory CategoryPerformanceModel.fromJson(Map<String, dynamic> json) =>
      CategoryPerformanceModel(
        category: json['category'] as String,
        bookings: json['bookings'] as int? ?? 0,
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      );

  CategoryPerformanceEntity toEntity() =>
      CategoryPerformanceEntity(category: category, bookings: bookings, revenue: revenue);
}

class TrafficSourceModel {
  const TrafficSourceModel({required this.source, required this.percentage});
  final String source;
  final double percentage;

  factory TrafficSourceModel.fromJson(Map<String, dynamic> json) =>
      TrafficSourceModel(
        source: json['source'] as String,
        percentage: (json['percentage'] as num).toDouble(),
      );

  TrafficSourceEntity toEntity() =>
      TrafficSourceEntity(source: source, percentage: percentage);
}
