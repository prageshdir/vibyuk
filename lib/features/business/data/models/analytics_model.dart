import 'package:vibyuk/features/business/domain/entities/analytics_entity.dart';
import 'package:vibyuk/features/business/domain/entities/booking_entity.dart';

class ChartPointModel {
  const ChartPointModel({required this.label, required this.value});
  final String label;
  final double value;

  factory ChartPointModel.fromJson(Map<String, dynamic> json) => ChartPointModel(
        label: json['label'] as String,
        value: (json['value'] as num).toDouble(),
      );

  ChartPoint toEntity() => ChartPoint(label: label, value: value);
}

class CategoryStatModel {
  const CategoryStatModel({
    required this.category,
    required this.count,
    required this.percentage,
  });
  final String category;
  final int count;
  final double percentage;

  factory CategoryStatModel.fromJson(Map<String, dynamic> json) => CategoryStatModel(
        category: json['category'] as String,
        count: json['count'] as int,
        percentage: (json['percentage'] as num).toDouble(),
      );

  CategoryStat toEntity() =>
      CategoryStat(category: category, count: count, percentage: percentage);
}

class AnalyticsDashboardModel {
  const AnalyticsDashboardModel({
    required this.totalSpend,
    required this.activeCampaigns,
    required this.totalCreators,
    required this.avgRating,
    required this.spendOverTime,
    required this.bookingsByStatus,
    required this.topCategories,
    required this.period,
  });

  final double totalSpend;
  final int activeCampaigns;
  final int totalCreators;
  final double avgRating;
  final List<ChartPointModel> spendOverTime;
  final Map<String, int> bookingsByStatus;
  final List<CategoryStatModel> topCategories;
  final String period;

  factory AnalyticsDashboardModel.fromJson(Map<String, dynamic> json) =>
      AnalyticsDashboardModel(
        totalSpend: (json['total_spend'] as num).toDouble(),
        activeCampaigns: json['active_campaigns'] as int? ?? 0,
        totalCreators: json['total_creators'] as int? ?? 0,
        avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
        spendOverTime: (json['spend_over_time'] as List?)
                ?.map((e) => ChartPointModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        bookingsByStatus: (json['bookings_by_status'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as int)) ??
            {},
        topCategories: (json['top_categories'] as List?)
                ?.map((e) => CategoryStatModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        period: json['period'] as String? ?? '30d',
      );

  AnalyticsDashboardEntity toEntity() => AnalyticsDashboardEntity(
        totalSpend: totalSpend,
        activeCampaigns: activeCampaigns,
        totalCreators: totalCreators,
        avgRating: avgRating,
        spendOverTime: spendOverTime.map((e) => e.toEntity()).toList(),
        bookingsByStatus: bookingsByStatus.map((k, v) => MapEntry(
              BookingStatus.values.firstWhere(
                (s) => s.name == k,
                orElse: () => BookingStatus.pending,
              ),
              v,
            )),
        topCategories: topCategories.map((e) => e.toEntity()).toList(),
        period: period,
      );
}
