import 'package:vibyuk/features/business/domain/entities/campaign_entity.dart';
import 'package:vibyuk/features/business/domain/usecases/campaign/create_campaign_use_case.dart';

class CreateCampaignDto {
  const CreateCampaignDto({
    required this.title,
    this.description,
    required this.budget,
    this.campaignType = CampaignType.standard,
    required this.startDate,
    this.endDate,
    required this.categories,
    this.targetCreatorCount = 1,
  });

  final String title;
  final String? description;
  final double budget;
  final CampaignType campaignType;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> categories;
  final int targetCreatorCount;

  factory CreateCampaignDto.fromParams(CreateCampaignParams params) =>
      CreateCampaignDto(
        title: params.title,
        description: params.description,
        budget: params.budget,
        campaignType: params.campaignType,
        startDate: params.startDate,
        endDate: params.endDate,
        categories: params.categories,
        targetCreatorCount: params.targetCreatorCount,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'budget': budget,
        'campaign_type': campaignType.apiValue,
        'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate!.toIso8601String(),
        'categories': categories,
        'target_creator_count': targetCreatorCount,
      };
}
