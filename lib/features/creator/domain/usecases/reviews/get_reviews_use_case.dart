import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/creator/domain/entities/review_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class GetReviewsUseCase
    extends UseCase<PaginatedResult<ReviewEntity>, GetReviewsParams> {
  final CreatorRepository _repository;
  const GetReviewsUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<ReviewEntity>>> call(
          GetReviewsParams params) =>
      _repository.getReviews(page: params.page, pageSize: params.pageSize);
}

class GetReviewsParams extends Equatable {
  final int page;
  final int pageSize;
  const GetReviewsParams({required this.page, this.pageSize = 20});

  @override
  List<Object?> get props => [page, pageSize];
}
