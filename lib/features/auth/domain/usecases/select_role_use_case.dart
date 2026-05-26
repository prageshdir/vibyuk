import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';

class SelectRoleUseCase implements UseCase<UserEntity, SelectRoleParams> {
  SelectRoleUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(SelectRoleParams params) {
    return _repository.selectRole(role: params.role);
  }
}

class SelectRoleParams extends Equatable {
  final UserRole role;

  const SelectRoleParams({required this.role});

  @override
  List<Object?> get props => [role];
}
