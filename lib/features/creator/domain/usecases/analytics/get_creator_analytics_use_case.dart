import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_analytics_entity.dart';
import 'package:vibyuk/features/creator/domain/repositories/creator_repository.dart';

class GetCreatorAnalyticsUseCase
    extends UseCase<CreatorAnalyticsEntity, GetCreatorAnalyticsParams> {
  final CreatorRepository _repository;
  const GetCreatorAnalyticsUseCase(this._repository);

  @override
  Future<Either<Failure, CreatorAnalyticsEntity>> call(
          GetCreatorAnalyticsParams params) =>
      _repository.getAnalytics(period: params.period);
}

class GetCreatorAnalyticsParams extends Equatable {
  final String period;
  const GetCreatorAnalyticsParams({required this.period});

  @override
  List<Object?> get props => [period];
}
