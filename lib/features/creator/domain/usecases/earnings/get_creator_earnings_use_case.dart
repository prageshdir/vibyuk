import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_earnings_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class GetCreatorEarningsUseCase
    extends UseCase<CreatorEarningsEntity, GetCreatorEarningsParams> {
  final CreatorRepository _repository;
  const GetCreatorEarningsUseCase(this._repository);

  @override
  Future<Either<Failure, CreatorEarningsEntity>> call(
          GetCreatorEarningsParams params) =>
      _repository.getEarnings(period: params.period);
}

class GetCreatorEarningsParams extends Equatable {
  final String period;
  const GetCreatorEarningsParams({required this.period});

  @override
  List<Object?> get props => [period];
}
