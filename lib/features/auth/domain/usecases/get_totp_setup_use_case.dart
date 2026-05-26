import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/auth/domain/entities/totp_setup_entity.dart';
import 'package:vibyuk/features/auth/domain/repositories/auth_repository.dart';

class GetTotpSetupUseCase extends UseCase<TotpSetupEntity, NoParams> {
  GetTotpSetupUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, TotpSetupEntity>> call(NoParams params) =>
      _repository.getTotpSetup();
}
