import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/creator/domain/entities/bank_account_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class SaveBankAccountUseCase
    implements UseCase<BankAccountEntity, SaveBankAccountParams> {
  const SaveBankAccountUseCase(this._repository);
  final CreatorRepository _repository;

  @override
  Future<Either<Failure, BankAccountEntity>> call(
          SaveBankAccountParams params) =>
      _repository.saveBankAccount(
        accountHolderName: params.accountHolderName,
        accountNumber: params.accountNumber,
        ifscCode: params.ifscCode,
        bankName: params.bankName,
      );
}

class SaveBankAccountParams extends Equatable {
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;

  const SaveBankAccountParams({
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
  });

  @override
  List<Object?> get props =>
      [accountHolderName, accountNumber, ifscCode, bankName];
}
