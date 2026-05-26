import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class DeletePortfolioItemUseCase
    extends UseCase<void, DeletePortfolioItemParams> {
  final CreatorRepository _repository;
  const DeletePortfolioItemUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(DeletePortfolioItemParams params) =>
      _repository.deletePortfolioItem(itemId: params.itemId);
}

class DeletePortfolioItemParams extends Equatable {
  final String itemId;
  const DeletePortfolioItemParams({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}
