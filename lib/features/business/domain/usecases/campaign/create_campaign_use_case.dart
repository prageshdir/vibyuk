import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/campaign_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/campaign_repository.dart';

class CreateCampaignUseCase implements UseCase<CampaignEntity, CreateCampaignParams> {
  CreateCampaignUseCase(this._repository);
  final CampaignRepository _repository;

  @override
  Future<Either<Failure, CampaignEntity>> call(CreateCampaignParams params) {
    return _repository.createCampaign(
      title: params.title,
      description: params.description,
      budget: params.budget,
      campaignType: params.campaignType,
      startDate: params.startDate,
      endDate: params.endDate,
      categories: params.categories,
      targetCreatorCount: params.targetCreatorCount,
    );
  }
}

class CreateCampaignParams extends Equatable {
  const CreateCampaignParams({
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

  @override
  List<Object?> get props => [title, description, budget, campaignType,
        startDate, endDate, categories, targetCreatorCount];
}
