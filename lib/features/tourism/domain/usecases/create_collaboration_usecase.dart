import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/tourism/domain/entities/creator_collaboration_entity.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';

class CreateCollaborationUseCase
    implements UseCase<CreatorCollaborationEntity, CreateCollaborationParams> {
  const CreateCollaborationUseCase(this._repository);

  final TourismRepository _repository;

  @override
  Future<Either<Failure, CreatorCollaborationEntity>> call(
      CreateCollaborationParams params) {
    return _repository.createCollaboration(params.toMap());
  }
}

class CreateCollaborationParams extends Equatable {
  const CreateCollaborationParams({
    required this.creatorId,
    required this.destinationId,
    required this.agreedFee,
    this.campaignId,
  });

  final String creatorId;
  final String destinationId;
  final double agreedFee;
  final String? campaignId;

  Map<String, dynamic> toMap() => {
        'creator_id': creatorId,
        'destination_id': destinationId,
        'agreed_fee': agreedFee,
        if (campaignId != null) 'campaign_id': campaignId,
      };

  @override
  List<Object?> get props => [creatorId, destinationId, agreedFee, campaignId];
}
