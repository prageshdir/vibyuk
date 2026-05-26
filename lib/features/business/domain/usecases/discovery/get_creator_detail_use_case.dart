import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/creator_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/discovery_repository.dart';

class GetCreatorDetailUseCase implements UseCase<CreatorEntity, GetCreatorDetailParams> {
  GetCreatorDetailUseCase(this._repository);
  final DiscoveryRepository _repository;

  @override
  Future<Either<Failure, CreatorEntity>> call(GetCreatorDetailParams params) {
    return _repository.getCreatorDetail(params.creatorId);
  }
}

class GetCreatorDetailParams extends Equatable {
  const GetCreatorDetailParams({required this.creatorId});
  final String creatorId;

  @override
  List<Object?> get props => [creatorId];
}
