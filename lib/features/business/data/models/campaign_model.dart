import 'package:vibyuk/features/business/domain/entities/campaign_entity.dart';

class CampaignMetricsModel {
  const CampaignMetricsModel({
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

  factory CampaignMetricsModel.fromJson(Map<String, dynamic> json) =>
      CampaignMetricsModel(
        impressions: json['impressions'] as int? ?? 0,
        engagementRate: (json['engagement_rate'] as num?)?.toDouble() ?? 0.0,
        reach: json['reach'] as int? ?? 0,
        conversions: json['conversions'] as int? ?? 0,
        spend: (json['spend'] as num?)?.toDouble() ?? 0.0,
      );

  CampaignMetrics toEntity() => CampaignMetrics(
        impressions: impressions,
        engagementRate: engagementRate,
        reach: reach,
        conversions: conversions,
        spend: spend,
      );
}

class CampaignModel {
  const CampaignModel({
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
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> categories;
  final int targetCreatorCount;
  final int bookedCount;
  final CampaignMetricsModel? metrics;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory CampaignModel.fromJson(Map<String, dynamic> json) => CampaignModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        budget: (json['budget'] as num).toDouble(),
        status: json['status'] as String? ?? 'draft',
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: json['end_date'] != null
            ? DateTime.parse(json['end_date'] as String)
            : null,
        categories: (json['categories'] as List?)?.cast<String>() ?? [],
        targetCreatorCount: json['target_creator_count'] as int? ?? 1,
        bookedCount: json['booked_count'] as int? ?? 0,
        metrics: json['metrics'] != null
            ? CampaignMetricsModel.fromJson(
                json['metrics'] as Map<String, dynamic>)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );

  CampaignEntity toEntity() => CampaignEntity(
        id: id,
        title: title,
        description: description,
        budget: budget,
        status: CampaignStatus.values.firstWhere(
          (s) => s.name == status,
          orElse: () => CampaignStatus.draft,
        ),
        startDate: startDate,
        endDate: endDate,
        categories: categories,
        targetCreatorCount: targetCreatorCount,
        bookedCount: bookedCount,
        metrics: metrics?.toEntity(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
