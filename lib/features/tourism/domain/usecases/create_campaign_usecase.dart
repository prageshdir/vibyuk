import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_campaign_entity.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';

class CreateCampaignUseCase
    implements UseCase<TourismCampaignEntity, CreateCampaignParams> {
  const CreateCampaignUseCase(this._repository);

  final TourismRepository _repository;

  @override
  Future<Either<Failure, TourismCampaignEntity>> call(CreateCampaignParams params) {
    return _repository.createCampaign(params.toMap());
  }
}

class CreateCampaignParams extends Equatable {
  const CreateCampaignParams({
    required this.title,
    required this.destinationId,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.targetCreatorCount,
    required this.hashtags,
    required this.objectives,
    this.coverImageUrl,
  });

  final String title;
  final String destinationId;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final int targetCreatorCount;
  final List<String> hashtags;
  final List<String> objectives;
  final String? coverImageUrl;

  Map<String, dynamic> toMap() => {
        'title': title,
        'destination_id': destinationId,
        'description': description,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'budget': budget,
        'target_creator_count': targetCreatorCount,
        'hashtags': hashtags,
        'objectives': objectives,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      };

  @override
  List<Object?> get props => [
        title,
        destinationId,
        description,
        startDate,
        endDate,
        budget,
        targetCreatorCount,
        hashtags,
        objectives,
        coverImageUrl,
      ];
}
