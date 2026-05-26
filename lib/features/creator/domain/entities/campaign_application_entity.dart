import 'package:equatable/equatable.dart';

enum ApplicationStatus { pending, accepted, rejected, withdrawn }

class CampaignApplicationEntity extends Equatable {
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
  final ApplicationStatus status;
  final String? rejectionReason;
  final DateTime appliedAt;
  final DateTime? respondedAt;

  const CampaignApplicationEntity({
    required this.id,
    required this.creatorId,
    required this.campaignId,
    required this.campaignTitle,
    required this.businessId,
    required this.businessName,
    this.businessLogoUrl,
    this.coverLetter,
    required this.portfolioItemIds,
    required this.proposedRate,
    required this.currency,
    required this.status,
    this.rejectionReason,
    required this.appliedAt,
    this.respondedAt,
  });

  bool get isPending => status == ApplicationStatus.pending;

  @override
  List<Object?> get props => [
        id,
        creatorId,
        campaignId,
        campaignTitle,
        businessId,
        businessName,
        businessLogoUrl,
        coverLetter,
        portfolioItemIds,
        proposedRate,
        currency,
        status,
        rejectionReason,
        appliedAt,
        respondedAt,
      ];
}
