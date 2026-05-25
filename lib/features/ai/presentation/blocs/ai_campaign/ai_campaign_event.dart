import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_campaign.dart';

abstract class AiCampaignEvent extends Equatable {
  const AiCampaignEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedCampaigns extends AiCampaignEvent {
  const LoadSavedCampaigns();
}

class GenerateCampaign extends AiCampaignEvent {
  final String title;
  final String objective;
  final String targetAudience;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;

  const GenerateCampaign({
    required this.title,
    required this.objective,
    required this.targetAudience,
    required this.budget,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props =>
      [title, objective, targetAudience, budget, startDate, endDate];
}

class SelectCampaign extends AiCampaignEvent {
  final String campaignId;

  const SelectCampaign({required this.campaignId});

  @override
  List<Object?> get props => [campaignId];
}

class UpdateStep extends AiCampaignEvent {
  final String campaignId;
  final String stepId;
  final CampaignStepStatus status;

  const UpdateStep({
    required this.campaignId,
    required this.stepId,
    required this.status,
  });

  @override
  List<Object?> get props => [campaignId, stepId, status];
}
