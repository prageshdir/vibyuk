import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_campaign_entity.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';

class GetCampaignDetailUseCase
    implements UseCase<TourismCampaignEntity, CampaignIdParams> {
  const GetCampaignDetailUseCase(this._repository);

  final TourismRepository _repository;

  @override
  Future<Either<Failure, TourismCampaignEntity>> call(CampaignIdParams params) {
    return _repository.getCampaignDetail(params.id);
  }
}

class CampaignIdParams extends Equatable {
  const CampaignIdParams(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
