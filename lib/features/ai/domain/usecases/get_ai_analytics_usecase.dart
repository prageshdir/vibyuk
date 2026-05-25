import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_analytics.dart';
import 'package:vibyuk/features/ai/domain/repositories/ai_repository.dart';

class GetAiAnalyticsUseCase implements UseCase<AiAnalytics, AnalyticsParams> {
  final AiRepository _repository;

  const GetAiAnalyticsUseCase(this._repository);

  @override
  Future<Either<Failure, AiAnalytics>> call(AnalyticsParams params) {
    return _repository.getAnalytics(period: params.period);
  }
}

class AnalyticsParams extends Equatable {
  final AnalyticsPeriod period;

  const AnalyticsParams({this.period = AnalyticsPeriod.last30Days});

  @override
  List<Object?> get props => [period];
}
