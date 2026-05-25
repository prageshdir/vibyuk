import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/entities/auth_session_entity.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';

class LoginWithGoogleUseCase implements UseCase<AuthSessionEntity, LoginWithGoogleParams> {
  LoginWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthSessionEntity>> call(LoginWithGoogleParams params) {
    return _repository.loginWithGoogle(idToken: params.idToken);
  }
}

class LoginWithGoogleParams extends Equatable {
  final String idToken;

  const LoginWithGoogleParams({required this.idToken});

  @override
  List<Object?> get props => [idToken];
}
