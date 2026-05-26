import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase implements UseCase<Unit, ResetPasswordParams> {
  ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(ResetPasswordParams params) {
    return _repository.resetPassword(
      token: params.token,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
    );
  }
}

class ResetPasswordParams extends Equatable {
  final String token;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordParams({
    required this.token,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [token, password, passwordConfirmation];
}
