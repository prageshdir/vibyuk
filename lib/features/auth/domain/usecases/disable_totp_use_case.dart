import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';

class DisableTotpParams extends Equatable {
  const DisableTotpParams({required this.password});

  final String password;

  @override
  List<Object?> get props => [password];
}

class DisableTotpUseCase extends UseCase<Unit, DisableTotpParams> {
  DisableTotpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DisableTotpParams params) =>
      _repository.disableTotp(password: params.password);
}
