import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/profile/domain/entities/profile_entity.dart';
import 'package:vibyuk/features/profile/domain/repositories/profile_repository.dart';

class GetUserProfileUseCase implements UseCase<ProfileEntity, GetUserProfileParams> {
  GetUserProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, ProfileEntity>> call(GetUserProfileParams params) {
    return _repository.getUserProfile(params.userId);
  }
}

class GetUserProfileParams extends Equatable {
  final String userId;

  const GetUserProfileParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
