import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class ReorderPortfolioUseCase extends UseCase<void, ReorderPortfolioParams> {
  final CreatorRepository _repository;
  const ReorderPortfolioUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ReorderPortfolioParams params) =>
      _repository.reorderPortfolio(orderedIds: params.orderedIds);
}

class ReorderPortfolioParams extends Equatable {
  final List<String> orderedIds;
  const ReorderPortfolioParams({required this.orderedIds});

  @override
  List<Object?> get props => [orderedIds];
}
