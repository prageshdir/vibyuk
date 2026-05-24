import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_profile_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class GetPublicCreatorProfileUseCase
    extends UseCase<CreatorProfileEntity, GetPublicCreatorProfileParams> {
  final CreatorRepository _repository;
  const GetPublicCreatorProfileUseCase(this._repository);

  @override
  Future<Either<Failure, CreatorProfileEntity>> call(
          GetPublicCreatorProfileParams params) =>
      _repository.getPublicProfile(creatorId: params.creatorId);
}

class GetPublicCreatorProfileParams extends Equatable {
  final String creatorId;
  const GetPublicCreatorProfileParams({required this.creatorId});

  @override
  List<Object?> get props => [creatorId];
}
