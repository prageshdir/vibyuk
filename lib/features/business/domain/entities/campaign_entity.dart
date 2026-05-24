import 'package:equatable/equatable.dart';

enum CampaignStatus { draft, active, paused, completed, cancelled }

extension CampaignStatusX on CampaignStatus {
  String get label => switch (this) {
        CampaignStatus.draft => 'Draft',
        CampaignStatus.active => 'Active',
        CampaignStatus.paused => 'Paused',
        CampaignStatus.completed => 'Completed',
        CampaignStatus.cancelled => 'Cancelled',
      };
}

class CampaignEntity extends Equatable {
  const CampaignEntity({
    required this.id,
    required this.title,
    this.description,
    required this.budget,
    required this.status,
    required this.startDate,
    this.endDate,
    this.categories = const [],
    this.targetCreatorCount = 1,
    this.bookedCount = 0,
    this.metrics,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final double budget;
  final CampaignStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> categories;
  final int targetCreatorCount;
  final int bookedCount;
  final CampaignMetrics? metrics;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isActive => status == CampaignStatus.active;
  bool get isDraft => status == CampaignStatus.draft;
  bool get canPublish => status == CampaignStatus.draft;
  bool get canEdit => status == CampaignStatus.draft || status == CampaignStatus.paused;

  double get bookingProgress =>
      targetCreatorCount > 0 ? (bookedCount / targetCreatorCount).clamp(0.0, 1.0) : 0.0;

  String get budgetDisplay => '£${budget.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
        id, title, description, budget, status, startDate, endDate,
        categories, targetCreatorCount, bookedCount, metrics, createdAt, updatedAt,
      ];
}

class CampaignMetrics extends Equatable {
  const CampaignMetrics({
    this.impressions = 0,
    this.engagementRate = 0.0,
    this.reach = 0,
    this.conversions = 0,
    this.spend = 0.0,
  });

  final int impressions;
  final double engagementRate;
  final int reach;
  final int conversions;
  final double spend;

  @override
  List<Object?> get props => [impressions, engagementRate, reach, conversions, spend];
}
