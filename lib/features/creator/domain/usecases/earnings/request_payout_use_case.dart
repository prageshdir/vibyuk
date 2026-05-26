import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_earnings_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class RequestPayoutUseCase extends UseCase<PayoutEntity, RequestPayoutParams> {
  final CreatorRepository _repository;
  const RequestPayoutUseCase(this._repository);

  @override
  Future<Either<Failure, PayoutEntity>> call(RequestPayoutParams params) =>
      _repository.requestPayout(amount: params.amount);
}

class RequestPayoutParams extends Equatable {
  final double amount;
  const RequestPayoutParams({required this.amount});

  @override
  List<Object?> get props => [amount];
}
