import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/portfolio_item_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class AddPortfolioItemUseCase
    extends UseCase<PortfolioItemEntity, AddPortfolioItemParams> {
  final CreatorRepository _repository;
  const AddPortfolioItemUseCase(this._repository);

  @override
  Future<Either<Failure, PortfolioItemEntity>> call(
          AddPortfolioItemParams params) =>
      _repository.addPortfolioItem(
        title: params.title,
        description: params.description,
        mediaType: params.mediaType,
        filePath: params.filePath,
        tags: params.tags,
        isFeatured: params.isFeatured,
      );
}

class AddPortfolioItemParams extends Equatable {
  final String title;
  final String? description;
  final MediaType mediaType;
  final String filePath;
  final List<String> tags;
  final bool isFeatured;

  const AddPortfolioItemParams({
    required this.title,
    this.description,
    required this.mediaType,
    required this.filePath,
    required this.tags,
    this.isFeatured = false,
  });

  @override
  List<Object?> get props => [title, description, mediaType, filePath, tags, isFeatured];
}
