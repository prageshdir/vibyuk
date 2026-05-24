import 'package:equatable/equatable.dart';

class CreatorAnalyticsEntity extends Equatable {
  final String creatorId;
  final int profileViews;
  final int profileViewsChange;
  final int bookingRequests;
  final int bookingRequestsChange;
  final double acceptanceRate;
  final double acceptanceRateChange;
  final double averageRating;
  final int totalReviews;
  final List<AnalyticsDataPointEntity> viewsOverTime;
  final List<AnalyticsDataPointEntity> bookingsOverTime;
  final List<CategoryPerformanceEntity> categoryPerformance;
  final List<TrafficSourceEntity> trafficSources;

  const CreatorAnalyticsEntity({
    required this.creatorId,
    required this.profileViews,
    required this.profileViewsChange,
    required this.bookingRequests,
    required this.bookingRequestsChange,
    required this.acceptanceRate,
    required this.acceptanceRateChange,
    required this.averageRating,
    required this.totalReviews,
    required this.viewsOverTime,
    required this.bookingsOverTime,
    required this.categoryPerformance,
    required this.trafficSources,
  });

  @override
  List<Object?> get props => [
        creatorId,
        profileViews,
        profileViewsChange,
        bookingRequests,
        bookingRequestsChange,
        acceptanceRate,
        acceptanceRateChange,
        averageRating,
        totalReviews,
        viewsOverTime,
        bookingsOverTime,
        categoryPerformance,
        trafficSources,
      ];
}

class AnalyticsDataPointEntity extends Equatable {
  final DateTime date;
  final double value;

  const AnalyticsDataPointEntity({required this.date, required this.value});

  @override
  List<Object?> get props => [date, value];
}

class CategoryPerformanceEntity extends Equatable {
  final String category;
  final int bookings;
  final double revenue;

  const CategoryPerformanceEntity({
    required this.category,
    required this.bookings,
    required this.revenue,
  });

  @override
  List<Object?> get props => [category, bookings, revenue];
}

class TrafficSourceEntity extends Equatable {
  final String source;
  final double percentage;

  const TrafficSourceEntity({required this.source, required this.percentage});

  @override
  List<Object?> get props => [source, percentage];
}
