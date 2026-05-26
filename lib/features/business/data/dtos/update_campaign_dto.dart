import 'package:vibyuk/features/business/domain/usecases/campaign/update_campaign_use_case.dart';

class UpdateCampaignDto {
  const UpdateCampaignDto({
    this.title,
    this.description,
    this.budget,
    this.startDate,
    this.endDate,
    this.categories,
    this.targetCreatorCount,
  });

  final String? title;
  final String? description;
  final double? budget;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categories;
  final int? targetCreatorCount;

  factory UpdateCampaignDto.fromParams(UpdateCampaignParams params) =>
      UpdateCampaignDto(
        title: params.title,
        description: params.description,
        budget: params.budget,
        startDate: params.startDate,
        endDate: params.endDate,
        categories: params.categories,
        targetCreatorCount: params.targetCreatorCount,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (budget != null) map['budget'] = budget;
    if (startDate != null) map['start_date'] = startDate!.toIso8601String();
    if (endDate != null) map['end_date'] = endDate!.toIso8601String();
    if (categories != null) map['categories'] = categories;
    if (targetCreatorCount != null) map['target_creator_count'] = targetCreatorCount;
    return map;
  }
}
