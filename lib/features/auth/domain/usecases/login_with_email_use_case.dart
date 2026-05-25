import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/entities/auth_session_entity.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';

class LoginWithEmailUseCase implements UseCase<AuthSessionEntity, LoginWithEmailParams> {
  LoginWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthSessionEntity>> call(LoginWithEmailParams params) {
    return _repository.loginWithEmail(
      email: params.email,
      password: params.password,
      rememberMe: params.rememberMe,
    );
  }
}

class LoginWithEmailParams extends Equatable {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginWithEmailParams({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}
