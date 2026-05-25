import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_insight.dart';
import 'package:vibyuk/features/ai/domain/repositories/ai_repository.dart';

class GetAiInsightsUseCase implements NoParamUseCase<List<AiInsight>> {
  final AiRepository _repository;

  const GetAiInsightsUseCase(this._repository);

  @override
  Future<Either<Failure, List<AiInsight>>> call() {
    return _repository.getInsights();
  }
}

class DismissInsightUseCase implements UseCase<bool, DismissInsightParams> {
  final AiRepository _repository;

  const DismissInsightUseCase(this._repository);

  @override
  Future<Either<Failure, bool>> call(DismissInsightParams params) {
    return _repository.dismissInsight(insightId: params.insightId);
  }
}

class DismissInsightParams extends Equatable {
  final String insightId;

  const DismissInsightParams({required this.insightId});

  @override
  List<Object?> get props => [insightId];
}
