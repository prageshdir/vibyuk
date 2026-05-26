import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/campaign_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/campaign_repository.dart';

class UpdateCampaignUseCase implements UseCase<CampaignEntity, UpdateCampaignParams> {
  UpdateCampaignUseCase(this._repository);
  final CampaignRepository _repository;

  @override
  Future<Either<Failure, CampaignEntity>> call(UpdateCampaignParams params) {
    return _repository.updateCampaign(
      campaignId: params.campaignId,
      title: params.title,
      description: params.description,
      budget: params.budget,
      startDate: params.startDate,
      endDate: params.endDate,
      categories: params.categories,
      targetCreatorCount: params.targetCreatorCount,
    );
  }
}

class UpdateCampaignParams extends Equatable {
  const UpdateCampaignParams({
    required this.campaignId,
    this.title,
    this.description,
    this.budget,
    this.startDate,
    this.endDate,
    this.categories,
    this.targetCreatorCount,
  });

  final String campaignId;
  final String? title;
  final String? description;
  final double? budget;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categories;
  final int? targetCreatorCount;

  @override
  List<Object?> get props => [campaignId, title, description, budget, startDate,
        endDate, categories, targetCreatorCount];
}
