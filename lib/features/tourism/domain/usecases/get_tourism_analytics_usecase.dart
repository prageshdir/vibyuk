import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_analytics_entity.dart';
import 'package:vibyuk/features/tourism/domain/repositories/tourism_repository.dart';

class GetTourismAnalyticsUseCase
    implements UseCase<TourismAnalyticsEntity, GetTourismAnalyticsParams> {
  const GetTourismAnalyticsUseCase(this._repository);

  final TourismRepository _repository;

  @override
  Future<Either<Failure, TourismAnalyticsEntity>> call(
      GetTourismAnalyticsParams params) {
    return _repository.getAnalytics(from: params.from, to: params.to);
  }
}

class GetTourismAnalyticsParams extends Equatable {
  const GetTourismAnalyticsParams({this.from, this.to});

  final DateTime? from;
  final DateTime? to;

  @override
  List<Object?> get props => [from, to];
}
