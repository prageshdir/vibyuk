import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_campaign.dart';

enum AiCampaignStatus { initial, loading, generating, success, failure }

class AiCampaignState extends Equatable {
  final AiCampaignStatus status;
  final List<AiCampaign> campaigns;
  final AiCampaign? selectedCampaign;
  final AiCampaign? generatedCampaign;
  final Failure? failure;
  final bool isUpdatingStep;

  const AiCampaignState({
    this.status = AiCampaignStatus.initial,
    this.campaigns = const [],
    this.selectedCampaign,
    this.generatedCampaign,
    this.failure,
    this.isUpdatingStep = false,
  });

  bool get isLoading => status == AiCampaignStatus.loading;
  bool get isGenerating => status == AiCampaignStatus.generating;
  bool get hasData => campaigns.isNotEmpty;
  bool get hasError => status == AiCampaignStatus.failure;

  AiCampaignState copyWith({
    AiCampaignStatus? status,
    List<AiCampaign>? campaigns,
    AiCampaign? selectedCampaign,
    AiCampaign? generatedCampaign,
    Failure? failure,
    bool? isUpdatingStep,
  }) {
    return AiCampaignState(
      status: status ?? this.status,
      campaigns: campaigns ?? this.campaigns,
      selectedCampaign: selectedCampaign ?? this.selectedCampaign,
      generatedCampaign: generatedCampaign ?? this.generatedCampaign,
      failure: failure ?? this.failure,
      isUpdatingStep: isUpdatingStep ?? this.isUpdatingStep,
    );
  }

  @override
  List<Object?> get props => [
        status,
        campaigns,
        selectedCampaign,
        generatedCampaign,
        failure,
        isUpdatingStep,
      ];
}
