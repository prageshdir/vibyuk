import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/creator/domain/entities/review_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class RespondToReviewUseCase
    extends UseCase<ReviewEntity, RespondToReviewParams> {
  final CreatorRepository _repository;
  const RespondToReviewUseCase(this._repository);

  @override
  Future<Either<Failure, ReviewEntity>> call(RespondToReviewParams params) =>
      _repository.respondToReview(
        reviewId: params.reviewId,
        response: params.response,
      );
}

class RespondToReviewParams extends Equatable {
  final String reviewId;
  final String response;

  const RespondToReviewParams({
    required this.reviewId,
    required this.response,
  });

  @override
  List<Object?> get props => [reviewId, response];
}
