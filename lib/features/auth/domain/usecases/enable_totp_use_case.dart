import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';

class EnableTotpParams extends Equatable {
  const EnableTotpParams({required this.totpCode});

  final String totpCode;

  @override
  List<Object?> get props => [totpCode];
}

class EnableTotpUseCase extends UseCase<Unit, EnableTotpParams> {
  EnableTotpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(EnableTotpParams params) =>
      _repository.enableTotp(totpCode: params.totpCode);
}
