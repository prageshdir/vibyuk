import 'package:vibyuk/features/creator/domain/entities/campaign_application_entity.dart';

class CampaignApplicationModel {
  const CampaignApplicationModel({
    required this.id,
    required this.creatorId,
    required this.campaignId,
    required this.campaignTitle,
    required this.businessId,
    required this.businessName,
    this.businessLogoUrl,
    this.coverLetter,
    this.portfolioItemIds = const [],
    required this.proposedRate,
    required this.currency,
    required this.status,
    this.rejectionReason,
    required this.appliedAt,
    this.respondedAt,
  });

  final String id;
  final String creatorId;
  final String campaignId;
  final String campaignTitle;
  final String businessId;
  final String businessName;
  final String? businessLogoUrl;
  final String? coverLetter;
  final List<String> portfolioItemIds;
  final double proposedRate;
  final String currency;
  final String status;
  final String? rejectionReason;
  final String appliedAt;
  final String? respondedAt;

  factory CampaignApplicationModel.fromJson(Map<String, dynamic> json) =>
      CampaignApplicationModel(
        id: json['id'] as String,
        creatorId: json['creator_id'] as String,
        campaignId: json['campaign_id'] as String,
        campaignTitle: json['campaign_title'] as String,
        businessId: json['business_id'] as String,
        businessName: json['business_name'] as String,
        businessLogoUrl: json['business_logo_url'] as String?,
        coverLetter: json['cover_letter'] as String?,
        portfolioItemIds:
            (json['portfolio_item_ids'] as List?)?.cast<String>() ?? [],
        proposedRate: (json['proposed_rate'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'GBP',
        status: json['status'] as String? ?? 'pending',
        rejectionReason: json['rejection_reason'] as String?,
        appliedAt: json['applied_at'] as String,
        respondedAt: json['responded_at'] as String?,
      );

  CampaignApplicationEntity toEntity() => CampaignApplicationEntity(
        id: id,
        creatorId: creatorId,
        campaignId: campaignId,
        campaignTitle: campaignTitle,
        businessId: businessId,
        businessName: businessName,
        businessLogoUrl: businessLogoUrl,
        coverLetter: coverLetter,
        portfolioItemIds: portfolioItemIds,
        proposedRate: proposedRate,
        currency: currency,
        status: ApplicationStatus.values.firstWhere(
          (e) => e.name == status,
          orElse: () => ApplicationStatus.pending,
        ),
        rejectionReason: rejectionReason,
        appliedAt: DateTime.parse(appliedAt),
        respondedAt: respondedAt != null ? DateTime.parse(respondedAt!) : null,
      );
}
