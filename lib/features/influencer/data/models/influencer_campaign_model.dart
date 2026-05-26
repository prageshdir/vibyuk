import 'package:vibyuk/features/business/domain/entities/search_filters_entity.dart';
import 'package:vibyuk/features/influencer/domain/entities/influencer_campaign_entity.dart';

class ContentDeliverableModel {
  const ContentDeliverableModel({
    required this.id,
    required this.campaignId,
    required this.influencerId,
    required this.influencerName,
    required this.type,
    required this.status,
    this.submittedContentUrl,
    this.publishedPostUrl,
    this.revisionNote,
    this.views,
    this.likes,
    this.comments,
    this.storyFrames,
    this.submittedAt,
    this.approvedAt,
    this.publishedAt,
  });

  final String id;
  final String campaignId;
  final String influencerId;
  final String influencerName;
  final String type;
  final String status;
  final String? submittedContentUrl;
  final String? publishedPostUrl;
  final String? revisionNote;
  final int? views;
  final int? likes;
  final int? comments;
  final int? storyFrames;
  final String? submittedAt;
  final String? approvedAt;
  final String? publishedAt;

  factory ContentDeliverableModel.fromJson(Map<String, dynamic> json) =>
      ContentDeliverableModel(
        id: json['id'] as String,
        campaignId: json['campaign_id'] as String,
        influencerId: json['influencer_id'] as String,
        influencerName: json['influencer_name'] as String,
        type: json['type'] as String,
        status: json['status'] as String,
        submittedContentUrl: json['submitted_content_url'] as String?,
        publishedPostUrl: json['published_post_url'] as String?,
        revisionNote: json['revision_note'] as String?,
        views: json['views'] as int?,
        likes: json['likes'] as int?,
        comments: json['comments'] as int?,
        storyFrames: json['story_frames'] as int?,
        submittedAt: json['submitted_at'] as String?,
        approvedAt: json['approved_at'] as String?,
        publishedAt: json['published_at'] as String?,
      );

  ContentDeliverableEntity toEntity() => ContentDeliverableEntity(
        id: id,
        campaignId: campaignId,
        influencerId: influencerId,
        influencerName: influencerName,
        type: _typeFromString(type),
        status: _statusFromString(status),
        submittedContentUrl: submittedContentUrl,
        publishedPostUrl: publishedPostUrl,
        revisionNote: revisionNote,
        views: views,
        likes: likes,
        comments: comments,
        storyFrames: storyFrames,
        submittedAt: submittedAt != null ? DateTime.tryParse(submittedAt!) : null,
        approvedAt: approvedAt != null ? DateTime.tryParse(approvedAt!) : null,
        publishedAt: publishedAt != null ? DateTime.tryParse(publishedAt!) : null,
      );

  static DeliverableType _typeFromString(String v) =>
      DeliverableType.values.firstWhere(
        (e) => e.name == v,
        orElse: () => DeliverableType.instagramPost,
      );

  static DeliverableStatus _statusFromString(String v) =>
      DeliverableStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => DeliverableStatus.pending,
      );
}

class InfluencerCampaignAnalyticsModel {
  const InfluencerCampaignAnalyticsModel({
    this.totalReach = 0,
    this.totalImpressions = 0,
    this.totalEngagements = 0,
    this.totalSpendPaise = 0,
    this.cpm = 0.0,
    this.roi = 0.0,
    this.influencerCount = 0,
    this.completedDeliverables = 0,
    this.totalDeliverables = 0,
  });

  final int totalReach;
  final int totalImpressions;
  final int totalEngagements;
  final int totalSpendPaise;
  final double cpm;
  final double roi;
  final int influencerCount;
  final int completedDeliverables;
  final int totalDeliverables;

  factory InfluencerCampaignAnalyticsModel.fromJson(Map<String, dynamic> j) =>
      InfluencerCampaignAnalyticsModel(
        totalReach: j['total_reach'] as int? ?? 0,
        totalImpressions: j['total_impressions'] as int? ?? 0,
        totalEngagements: j['total_engagements'] as int? ?? 0,
        totalSpendPaise: j['total_spend_paise'] as int? ?? 0,
        cpm: (j['cpm'] as num?)?.toDouble() ?? 0.0,
        roi: (j['roi'] as num?)?.toDouble() ?? 0.0,
        influencerCount: j['influencer_count'] as int? ?? 0,
        completedDeliverables: j['completed_deliverables'] as int? ?? 0,
        totalDeliverables: j['total_deliverables'] as int? ?? 0,
      );

  InfluencerCampaignAnalytics toEntity() => InfluencerCampaignAnalytics(
        totalReach: totalReach,
        totalImpressions: totalImpressions,
        totalEngagements: totalEngagements,
        totalSpendPaise: totalSpendPaise,
        cpm: cpm,
        roi: roi,
        influencerCount: influencerCount,
        completedDeliverables: completedDeliverables,
        totalDeliverables: totalDeliverables,
      );
}

class InfluencerCampaignModel {
  const InfluencerCampaignModel({
    required this.id,
    required this.businessId,
    required this.title,
    this.description,
    required this.budgetPaise,
    required this.status,
    required this.startDate,
    this.endDate,
    this.categories = const [],
    this.platforms = const [],
    this.languages = const [],
    this.minFollowers,
    this.maxFollowers,
    this.minEngagementRate,
    this.maxInfluencers = 10,
    this.confirmedInfluencerIds = const [],
    this.deliverables = const [],
    this.analytics,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String businessId;
  final String title;
  final String? description;
  final int budgetPaise;
  final String status;
  final String startDate;
  final String? endDate;
  final List<String> categories;
  final List<String> platforms;
  final List<String> languages;
  final int? minFollowers;
  final int? maxFollowers;
  final double? minEngagementRate;
  final int maxInfluencers;
  final List<String> confirmedInfluencerIds;
  final List<ContentDeliverableModel> deliverables;
  final InfluencerCampaignAnalyticsModel? analytics;
  final String createdAt;
  final String? updatedAt;

  factory InfluencerCampaignModel.fromJson(Map<String, dynamic> j) =>
      InfluencerCampaignModel(
        id: j['id'] as String,
        businessId: j['business_id'] as String,
        title: j['title'] as String,
        description: j['description'] as String?,
        budgetPaise: j['budget_paise'] as int,
        status: j['status'] as String,
        startDate: j['start_date'] as String,
        endDate: j['end_date'] as String?,
        categories: List<String>.from(j['categories'] as List? ?? []),
        platforms: List<String>.from(j['platforms'] as List? ?? []),
        languages: List<String>.from(j['languages'] as List? ?? []),
        minFollowers: j['min_followers'] as int?,
        maxFollowers: j['max_followers'] as int?,
        minEngagementRate: (j['min_engagement_rate'] as num?)?.toDouble(),
        maxInfluencers: j['max_influencers'] as int? ?? 10,
        confirmedInfluencerIds:
            List<String>.from(j['confirmed_influencer_ids'] as List? ?? []),
        deliverables: ((j['deliverables'] as List?) ?? [])
            .map((e) =>
                ContentDeliverableModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        analytics: j['analytics'] != null
            ? InfluencerCampaignAnalyticsModel.fromJson(
                j['analytics'] as Map<String, dynamic>)
            : null,
        createdAt: j['created_at'] as String,
        updatedAt: j['updated_at'] as String?,
      );

  InfluencerCampaignEntity toEntity() => InfluencerCampaignEntity(
        id: id,
        businessId: businessId,
        title: title,
        description: description,
        budgetPaise: budgetPaise,
        status: _statusFromString(status),
        startDate: DateTime.parse(startDate),
        endDate: endDate != null ? DateTime.tryParse(endDate!) : null,
        categories: categories,
        platforms: platforms.map(_platformFromString).toList(),
        languages: languages,
        minFollowers: minFollowers,
        maxFollowers: maxFollowers,
        minEngagementRate: minEngagementRate,
        maxInfluencers: maxInfluencers,
        confirmedInfluencerIds: confirmedInfluencerIds,
        deliverables: deliverables.map((d) => d.toEntity()).toList(),
        analytics: analytics?.toEntity(),
        createdAt: DateTime.parse(createdAt),
        updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
      );

  static InfluencerCampaignStatus _statusFromString(String v) =>
      InfluencerCampaignStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => InfluencerCampaignStatus.draft,
      );

  static InfluencerPlatform _platformFromString(String v) =>
      InfluencerPlatform.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => InfluencerPlatform.instagram,
      );
}
