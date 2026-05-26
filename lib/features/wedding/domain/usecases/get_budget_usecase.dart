import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_budget_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_wedding_usecase.dart';

class GetBudgetUseCase extends UseCase<WeddingBudgetEntity, WeddingIdParams> {
  const GetBudgetUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, WeddingBudgetEntity>> call(WeddingIdParams params) =>
      _repository.getBudget(params.weddingId);
}
