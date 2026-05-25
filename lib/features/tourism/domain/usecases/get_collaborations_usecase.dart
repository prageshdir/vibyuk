import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/pagination/paginated_response.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/tourism/domain/entities/creator_collaboration_entity.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';

class GetCollaborationsUseCase
    implements UseCase<PaginatedResponse<CreatorCollaborationEntity>, GetCollaborationsParams> {
  const GetCollaborationsUseCase(this._repository);

  final TourismRepository _repository;

  @override
  Future<Either<Failure, PaginatedResponse<CreatorCollaborationEntity>>> call(
      GetCollaborationsParams params) {
    return _repository.getCollaborations(
      page: params.page,
      perPage: params.perPage,
      destinationId: params.destinationId,
      campaignId: params.campaignId,
    );
  }
}

class GetCollaborationsParams extends Equatable {
  const GetCollaborationsParams({
    this.page = 1,
    this.perPage = 20,
    this.destinationId,
    this.campaignId,
  });

  final int page;
  final int perPage;
  final String? destinationId;
  final String? campaignId;

  @override
  List<Object?> get props => [page, perPage, destinationId, campaignId];
}
