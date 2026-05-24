import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/business/domain/entities/booking_entity.dart';

class AnalyticsDashboardEntity extends Equatable {
  const AnalyticsDashboardEntity({
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
  final List<ChartPoint> spendOverTime;
  final Map<BookingStatus, int> bookingsByStatus;
  final List<CategoryStat> topCategories;
  final String period;

  String get totalSpendDisplay => '£${totalSpend.toStringAsFixed(0)}';
  String get avgRatingDisplay => avgRating.toStringAsFixed(1);

  @override
  List<Object?> get props => [
        totalSpend, activeCampaigns, totalCreators, avgRating,
        spendOverTime, bookingsByStatus, topCategories, period,
      ];
}

class ChartPoint extends Equatable {
  const ChartPoint({required this.label, required this.value});

  final String label;
  final double value;

  @override
  List<Object?> get props => [label, value];
}

class CategoryStat extends Equatable {
  const CategoryStat({
    required this.category,
    required this.count,
    required this.percentage,
  });

  final String category;
  final int count;
  final double percentage;

  @override
  List<Object?> get props => [category, count, percentage];
}
