import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_campaign_entity.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';

class UpdateCampaignUseCase
    implements UseCase<TourismCampaignEntity, UpdateCampaignParams> {
  const UpdateCampaignUseCase(this._repository);

  final TourismRepository _repository;

  @override
  Future<Either<Failure, TourismCampaignEntity>> call(UpdateCampaignParams params) {
    return _repository.updateCampaign(params.id, params.toMap());
  }
}

class UpdateCampaignParams extends Equatable {
  const UpdateCampaignParams({
    required this.id,
    this.title,
    this.description,
    this.budget,
    this.targetCreatorCount,
    this.hashtags,
    this.objectives,
    this.coverImageUrl,
    this.status,
  });

  final String id;
  final String? title;
  final String? description;
  final double? budget;
  final int? targetCreatorCount;
  final List<String>? hashtags;
  final List<String>? objectives;
  final String? coverImageUrl;
  final CampaignStatus? status;

  Map<String, dynamic> toMap() => {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (budget != null) 'budget': budget,
        if (targetCreatorCount != null) 'target_creator_count': targetCreatorCount,
        if (hashtags != null) 'hashtags': hashtags,
        if (objectives != null) 'objectives': objectives,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (status != null) 'status': status!.name,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        budget,
        targetCreatorCount,
        hashtags,
        objectives,
        coverImageUrl,
        status,
      ];
}
