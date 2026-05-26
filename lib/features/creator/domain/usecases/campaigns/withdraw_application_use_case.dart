import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class WithdrawApplicationUseCase
    extends UseCase<void, WithdrawApplicationParams> {
  final CreatorRepository _repository;
  const WithdrawApplicationUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(WithdrawApplicationParams params) =>
      _repository.withdrawApplication(applicationId: params.applicationId);
}

class WithdrawApplicationParams extends Equatable {
  final String applicationId;
  const WithdrawApplicationParams({required this.applicationId});

  @override
  List<Object?> get props => [applicationId];
}
