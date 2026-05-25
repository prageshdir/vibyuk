import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_campaign.dart';
import 'package:vibyuk/features/ai/domain/repositories/ai_repository.dart';

class GenerateCampaignPlanUseCase
    implements UseCase<AiCampaign, CampaignPlanParams> {
  final AiRepository _repository;

  const GenerateCampaignPlanUseCase(this._repository);

  @override
  Future<Either<Failure, AiCampaign>> call(CampaignPlanParams params) {
    return _repository.generateCampaignPlan(
      title: params.title,
      objective: params.objective,
      targetAudience: params.targetAudience,
      budget: params.budget,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetSavedCampaignsUseCase
    implements NoParamUseCase<List<AiCampaign>> {
  final AiRepository _repository;

  const GetSavedCampaignsUseCase(this._repository);

  @override
  Future<Either<Failure, List<AiCampaign>>> call() {
    return _repository.getSavedCampaigns();
  }
}

class UpdateCampaignStepUseCase
    implements UseCase<AiCampaign, UpdateStepParams> {
  final AiRepository _repository;

  const UpdateCampaignStepUseCase(this._repository);

  @override
  Future<Either<Failure, AiCampaign>> call(UpdateStepParams params) {
    return _repository.updateCampaignStep(
      campaignId: params.campaignId,
      stepId: params.stepId,
      status: params.status,
    );
  }
}

class CampaignPlanParams extends Equatable {
  final String title;
  final String objective;
  final String targetAudience;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;

  const CampaignPlanParams({
    required this.title,
    required this.objective,
    required this.targetAudience,
    required this.budget,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [title, objective, targetAudience, budget, startDate, endDate];
}

class UpdateStepParams extends Equatable {
  final String campaignId;
  final String stepId;
  final CampaignStepStatus status;

  const UpdateStepParams({
    required this.campaignId,
    required this.stepId,
    required this.status,
  });

  @override
  List<Object?> get props => [campaignId, stepId, status];
}
