import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/kyc_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class GetKycStatusUseCase extends UseCase<KycEntity, NoParams> {
  final CreatorRepository _repository;
  const GetKycStatusUseCase(this._repository);

  @override
  Future<Either<Failure, KycEntity>> call(NoParams params) =>
      _repository.getKycStatus();
}
