import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/creator/domain/entities/bank_account_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class GetBankAccountUseCase implements UseCase<BankAccountEntity?, NoParams> {
  const GetBankAccountUseCase(this._repository);
  final CreatorRepository _repository;

  @override
  Future<Either<Failure, BankAccountEntity?>> call(NoParams params) =>
      _repository.getBankAccount();
}
