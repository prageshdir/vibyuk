import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase implements NoParamUseCase<UserEntity> {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call() {
    return _repository.getCurrentUser();
  }
}
