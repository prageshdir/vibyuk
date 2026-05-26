import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/campaign_application_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class ApplyToCampaignUseCase
    extends UseCase<CampaignApplicationEntity, ApplyToCampaignParams> {
  final CreatorRepository _repository;
  const ApplyToCampaignUseCase(this._repository);

  @override
  Future<Either<Failure, CampaignApplicationEntity>> call(
          ApplyToCampaignParams params) =>
      _repository.applyToCampaign(
        campaignId: params.campaignId,
        coverLetter: params.coverLetter,
        portfolioItemIds: params.portfolioItemIds,
        proposedRate: params.proposedRate,
        currency: params.currency,
      );
}

class ApplyToCampaignParams extends Equatable {
  final String campaignId;
  final String? coverLetter;
  final List<String> portfolioItemIds;
  final double proposedRate;
  final String currency;

  const ApplyToCampaignParams({
    required this.campaignId,
    this.coverLetter,
    required this.portfolioItemIds,
    required this.proposedRate,
    required this.currency,
  });

  @override
  List<Object?> get props =>
      [campaignId, coverLetter, portfolioItemIds, proposedRate, currency];
}
