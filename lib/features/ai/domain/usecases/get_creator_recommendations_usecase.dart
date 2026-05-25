import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_recommendation.dart';
import 'package:vibyuk/features/ai/domain/repositories/ai_repository.dart';

class GetCreatorRecommendationsUseCase
    implements UseCase<List<AiRecommendation>, RecommendationParams> {
  final AiRepository _repository;

  const GetCreatorRecommendationsUseCase(this._repository);

  @override
  Future<Either<Failure, List<AiRecommendation>>> call(
    RecommendationParams params,
  ) {
    return _repository.getCreatorRecommendations(
      eventType: params.eventType,
      budget: params.budget,
      location: params.location,
      filters: params.filters,
    );
  }
}

class RecommendationParams extends Equatable {
  final String eventType;
  final double budget;
  final String location;
  final Map<String, dynamic>? filters;

  const RecommendationParams({
    required this.eventType,
    required this.budget,
    required this.location,
    this.filters,
  });

  @override
  List<Object?> get props => [eventType, budget, location, filters];
}
