import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/profile/domain/repositories/profile_repository.dart';

class ChangePasswordUseCase implements UseCase<Unit, ChangePasswordParams> {
  ChangePasswordUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(ChangePasswordParams params) {
    return _repository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
      newPasswordConfirmation: params.newPasswordConfirmation,
    );
  }
}

class ChangePasswordParams extends Equatable {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, newPasswordConfirmation];
}
