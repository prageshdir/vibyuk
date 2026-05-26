import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/repositories/campaign_repository.dart';

class DeleteCampaignUseCase implements UseCase<Unit, DeleteCampaignParams> {
  DeleteCampaignUseCase(this._repository);
  final CampaignRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteCampaignParams params) {
    return _repository.deleteCampaign(params.campaignId);
  }
}

class DeleteCampaignParams extends Equatable {
  const DeleteCampaignParams({required this.campaignId});
  final String campaignId;

  @override
  List<Object?> get props => [campaignId];
}
