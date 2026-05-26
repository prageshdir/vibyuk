import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/profile/domain/entities/profile_entity.dart';
import 'package:vibyuk/features/profile/domain/repositories/profile_repository.dart';

class GetMyProfileUseCase implements NoParamUseCase<ProfileEntity> {
  GetMyProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, ProfileEntity>> call() {
    return _repository.getMyProfile();
  }
}
