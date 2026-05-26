import 'package:equatable/equatable.dart';

enum CampaignType { standard, directBooking }

extension CampaignTypeX on CampaignType {
  String get label => switch (this) {
        CampaignType.standard => 'Open Campaign',
        CampaignType.directBooking => 'Direct Booking',
      };
  String get apiValue => switch (this) {
        CampaignType.standard => 'standard',
        CampaignType.directBooking => 'direct_booking',
      };
}

enum CampaignStatus {
  draft,
  active,
  published,
  applications,
  inProgress,
  completed,
  archived,
  paused,
  cancelled,
}

extension CampaignStatusX on CampaignStatus {
  String get label => switch (this) {
        CampaignStatus.draft => 'Draft',
        CampaignStatus.active => 'Active',
        CampaignStatus.published => 'Published',
        CampaignStatus.applications => 'Accepting Applications',
        CampaignStatus.inProgress => 'In Progress',
        CampaignStatus.completed => 'Completed',
        CampaignStatus.archived => 'Archived',
        CampaignStatus.paused => 'Paused',
        CampaignStatus.cancelled => 'Cancelled',
      };

  bool get isActive =>
      this == CampaignStatus.active ||
      this == CampaignStatus.published ||
      this == CampaignStatus.applications ||
      this == CampaignStatus.inProgress;

  bool get canPublish => this == CampaignStatus.draft;

  bool get canEdit =>
      this == CampaignStatus.draft || this == CampaignStatus.paused;

  bool get canArchive =>
      this == CampaignStatus.completed || this == CampaignStatus.cancelled;
}

class CampaignEntity extends Equatable {
  const CampaignEntity({
    required this.id,
    required this.title,
    this.description,
    required this.budget,
    required this.status,
    this.campaignType = CampaignType.standard,
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
  final CampaignType campaignType;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> categories;
  final int targetCreatorCount;
  final int bookedCount;
  final CampaignMetrics? metrics;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isActive => status.isActive;
  bool get isDraft => status == CampaignStatus.draft;
  bool get canPublish => status.canPublish;
  bool get canEdit => status.canEdit;
  bool get isDirectBooking => campaignType == CampaignType.directBooking;

  double get bookingProgress =>
      targetCreatorCount > 0
          ? (bookedCount / targetCreatorCount).clamp(0.0, 1.0)
          : 0.0;

  String get budgetDisplay => '₹${budget.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
        id, title, description, budget, status, campaignType, startDate,
        endDate, categories, targetCreatorCount, bookedCount, metrics,
        createdAt, updatedAt,
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
