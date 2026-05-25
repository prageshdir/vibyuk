import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/ai/domain/usecases/get_campaign_plan_usecase.dart';
import 'ai_campaign_event.dart';
import 'ai_campaign_state.dart';

class AiCampaignBloc extends BaseBloc<AiCampaignEvent, AiCampaignState> {
  final GenerateCampaignPlanUseCase _generateCampaign;
  final GetSavedCampaignsUseCase _getSavedCampaigns;
  final UpdateCampaignStepUseCase _updateStep;

  AiCampaignBloc({
    required GenerateCampaignPlanUseCase generateCampaign,
    required GetSavedCampaignsUseCase getSavedCampaigns,
    required UpdateCampaignStepUseCase updateStep,
  })  : _generateCampaign = generateCampaign,
        _getSavedCampaigns = getSavedCampaigns,
        _updateStep = updateStep,
        super(const AiCampaignState()) {
    on<LoadSavedCampaigns>(_onLoad);
    on<GenerateCampaign>(_onGenerate);
    on<SelectCampaign>(_onSelect);
    on<UpdateStep>(_onUpdateStep);
  }

  Future<void> _onLoad(
    LoadSavedCampaigns event,
    Emitter<AiCampaignState> emit,
  ) async {
    emit(state.copyWith(status: AiCampaignStatus.loading));

    final result = await _getSavedCampaigns();
    result.fold(
      (failure) => emit(
        state.copyWith(status: AiCampaignStatus.failure, failure: failure),
      ),
      (data) => emit(
        state.copyWith(status: AiCampaignStatus.success, campaigns: data, failure: null),
      ),
    );
  }

  Future<void> _onGenerate(
    GenerateCampaign event,
    Emitter<AiCampaignState> emit,
  ) async {
    emit(state.copyWith(status: AiCampaignStatus.generating));

    final result = await _generateCampaign(
      CampaignPlanParams(
        title: event.title,
        objective: event.objective,
        targetAudience: event.targetAudience,
        budget: event.budget,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(status: AiCampaignStatus.failure, failure: failure),
      ),
      (campaign) => emit(
        state.copyWith(
          status: AiCampaignStatus.success,
          generatedCampaign: campaign,
          campaigns: [campaign, ...state.campaigns],
          selectedCampaign: campaign,
          failure: null,
        ),
      ),
    );
  }

  void _onSelect(SelectCampaign event, Emitter<AiCampaignState> emit) {
    final campaign = state.campaigns
        .where((c) => c.id == event.campaignId)
        .firstOrNull;
    if (campaign != null) {
      emit(state.copyWith(selectedCampaign: campaign));
    }
  }

  Future<void> _onUpdateStep(
    UpdateStep event,
    Emitter<AiCampaignState> emit,
  ) async {
    emit(state.copyWith(isUpdatingStep: true));

    final result = await _updateStep(
      UpdateStepParams(
        campaignId: event.campaignId,
        stepId: event.stepId,
        status: event.status,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(isUpdatingStep: false, failure: failure)),
      (updated) {
        final campaigns = state.campaigns
            .map((c) => c.id == updated.id ? updated : c)
            .toList();
        emit(state.copyWith(
          isUpdatingStep: false,
          campaigns: campaigns,
          selectedCampaign:
              state.selectedCampaign?.id == updated.id ? updated : state.selectedCampaign,
          failure: null,
        ));
      },
    );
  }
}
