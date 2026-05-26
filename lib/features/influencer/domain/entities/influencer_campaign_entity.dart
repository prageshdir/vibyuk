import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/business/domain/entities/search_filters_entity.dart';

enum InfluencerCampaignStatus {
  draft,
  published,
  applications,
  inProgress,
  completed,
  archived,
}

extension InfluencerCampaignStatusX on InfluencerCampaignStatus {
  String get label => switch (this) {
        InfluencerCampaignStatus.draft => 'Draft',
        InfluencerCampaignStatus.published => 'Published',
        InfluencerCampaignStatus.applications => 'Accepting Applications',
        InfluencerCampaignStatus.inProgress => 'In Progress',
        InfluencerCampaignStatus.completed => 'Completed',
        InfluencerCampaignStatus.archived => 'Archived',
      };

  bool get canPublish => this == InfluencerCampaignStatus.draft;
  bool get canEdit =>
      this == InfluencerCampaignStatus.draft ||
      this == InfluencerCampaignStatus.published;
  bool get isActive =>
      this == InfluencerCampaignStatus.applications ||
      this == InfluencerCampaignStatus.inProgress;
}

enum DeliverableType { instagramPost, instagramStory, youtubeVideo, tiktokVideo, tweet }

extension DeliverableTypeX on DeliverableType {
  String get label => switch (this) {
        DeliverableType.instagramPost => 'Instagram Post',
        DeliverableType.instagramStory => 'Instagram Story',
        DeliverableType.youtubeVideo => 'YouTube Video',
        DeliverableType.tiktokVideo => 'TikTok Video',
        DeliverableType.tweet => 'Tweet / X Post',
      };
}

enum DeliverableStatus {
  pending,
  submitted,
  underReview,
  revisionRequested,
  approved,
  published,
}

extension DeliverableStatusX on DeliverableStatus {
  String get label => switch (this) {
        DeliverableStatus.pending => 'Pending',
        DeliverableStatus.submitted => 'Submitted',
        DeliverableStatus.underReview => 'Under Review',
        DeliverableStatus.revisionRequested => 'Revision Requested',
        DeliverableStatus.approved => 'Approved',
        DeliverableStatus.published => 'Published',
      };
}

class ContentDeliverableEntity extends Equatable {
  const ContentDeliverableEntity({
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
  final DeliverableType type;
  final DeliverableStatus status;
  final String? submittedContentUrl;
  final String? publishedPostUrl;
  final String? revisionNote;
  final int? views;
  final int? likes;
  final int? comments;
  final int? storyFrames;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? publishedAt;

  bool get isPublished => status == DeliverableStatus.published;
  bool get needsRevision => status == DeliverableStatus.revisionRequested;
  bool get isApproved => status == DeliverableStatus.approved;

  @override
  List<Object?> get props => [
        id, campaignId, influencerId, influencerName, type, status,
        submittedContentUrl, publishedPostUrl, revisionNote,
        views, likes, comments, storyFrames,
        submittedAt, approvedAt, publishedAt,
      ];
}

class InfluencerCampaignAnalytics extends Equatable {
  const InfluencerCampaignAnalytics({
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

  double get completionRate => totalDeliverables > 0
      ? completedDeliverables / totalDeliverables
      : 0.0;

  String get spendDisplay =>
      '₹${(totalSpendPaise / 100).toStringAsFixed(0)}';

  String get cpmDisplay => '₹${cpm.toStringAsFixed(2)}';

  String get roiDisplay => '${roi.toStringAsFixed(1)}×';

  @override
  List<Object?> get props => [
        totalReach, totalImpressions, totalEngagements, totalSpendPaise,
        cpm, roi, influencerCount, completedDeliverables, totalDeliverables,
      ];
}

class InfluencerCampaignEntity extends Equatable {
  const InfluencerCampaignEntity({
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
  final InfluencerCampaignStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> categories;
  final List<InfluencerPlatform> platforms;
  final List<String> languages;
  final int? minFollowers;
  final int? maxFollowers;
  final double? minEngagementRate;
  final int maxInfluencers;
  final List<String> confirmedInfluencerIds;
  final List<ContentDeliverableEntity> deliverables;
  final InfluencerCampaignAnalytics? analytics;
  final DateTime createdAt;
  final DateTime? updatedAt;

  String get budgetDisplay => '₹${(budgetPaise / 100).toStringAsFixed(0)}';

  int get confirmedCount => confirmedInfluencerIds.length;
  bool get hasCapacity => confirmedCount < maxInfluencers;

  int get pendingDeliverables => deliverables
      .where((d) =>
          d.status == DeliverableStatus.submitted ||
          d.status == DeliverableStatus.underReview)
      .length;

  @override
  List<Object?> get props => [
        id, businessId, title, description, budgetPaise, status, startDate,
        endDate, categories, platforms, languages, minFollowers, maxFollowers,
        minEngagementRate, maxInfluencers, confirmedInfluencerIds,
        deliverables, analytics, createdAt, updatedAt,
      ];
}
