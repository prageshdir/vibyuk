import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/tourism/domain/entities/creator_collaboration_entity.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';

class UpdateCollaborationUseCase
    implements UseCase<CreatorCollaborationEntity, UpdateCollaborationParams> {
  const UpdateCollaborationUseCase(this._repository);

  final TourismRepository _repository;

  @override
  Future<Either<Failure, CreatorCollaborationEntity>> call(
      UpdateCollaborationParams params) {
    return _repository.updateCollaboration(params.id, params.toMap());
  }
}

class UpdateCollaborationParams extends Equatable {
  const UpdateCollaborationParams({
    required this.id,
    this.status,
    this.contentUrls,
    this.reach,
    this.engagementRate,
  });

  final String id;
  final CollaborationStatus? status;
  final List<String>? contentUrls;
  final int? reach;
  final double? engagementRate;

  Map<String, dynamic> toMap() => {
        if (status != null) 'status': status!.name,
        if (contentUrls != null) 'content_urls': contentUrls,
        if (reach != null) 'reach': reach,
        if (engagementRate != null) 'engagement_rate': engagementRate,
      };

  @override
  List<Object?> get props => [id, status, contentUrls, reach, engagementRate];
}
