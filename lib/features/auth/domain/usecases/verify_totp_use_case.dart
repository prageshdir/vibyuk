import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';

class VerifyTotpParams extends Equatable {
  const VerifyTotpParams({required this.token});

  final String token;

  @override
  List<Object?> get props => [token];
}

class VerifyTotpUseCase extends UseCase<bool, VerifyTotpParams> {
  VerifyTotpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, bool>> call(VerifyTotpParams params) =>
      _repository.verifyTotpToken(token: params.token);
}

class VerifyTotpRecoveryParams extends Equatable {
  const VerifyTotpRecoveryParams({required this.recoveryCode});

  final String recoveryCode;

  @override
  List<Object?> get props => [recoveryCode];
}

class VerifyTotpRecoveryUseCase extends UseCase<bool, VerifyTotpRecoveryParams> {
  VerifyTotpRecoveryUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, bool>> call(VerifyTotpRecoveryParams params) =>
      _repository.verifyTotpRecovery(recoveryCode: params.recoveryCode);
}
