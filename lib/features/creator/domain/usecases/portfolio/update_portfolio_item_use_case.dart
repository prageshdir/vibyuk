import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/portfolio_item_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class UpdatePortfolioItemUseCase
    extends UseCase<PortfolioItemEntity, UpdatePortfolioItemParams> {
  final CreatorRepository _repository;
  const UpdatePortfolioItemUseCase(this._repository);

  @override
  Future<Either<Failure, PortfolioItemEntity>> call(
          UpdatePortfolioItemParams params) =>
      _repository.updatePortfolioItem(
        itemId: params.itemId,
        title: params.title,
        description: params.description,
        tags: params.tags,
        isFeatured: params.isFeatured,
      );
}

class UpdatePortfolioItemParams extends Equatable {
  final String itemId;
  final String title;
  final String? description;
  final List<String> tags;
  final bool isFeatured;

  const UpdatePortfolioItemParams({
    required this.itemId,
    required this.title,
    this.description,
    required this.tags,
    required this.isFeatured,
  });

  @override
  List<Object?> get props => [itemId, title, description, tags, isFeatured];
}
