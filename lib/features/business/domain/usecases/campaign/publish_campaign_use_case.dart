import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/campaign_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/campaign_repository.dart';

class PublishCampaignUseCase implements UseCase<CampaignEntity, PublishCampaignParams> {
  PublishCampaignUseCase(this._repository);
  final CampaignRepository _repository;

  @override
  Future<Either<Failure, CampaignEntity>> call(PublishCampaignParams params) {
    return _repository.publishCampaign(params.campaignId);
  }
}

class PublishCampaignParams extends Equatable {
  const PublishCampaignParams({required this.campaignId});
  final String campaignId;

  @override
  List<Object?> get props => [campaignId];
}
