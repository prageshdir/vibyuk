import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_analytics_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_wedding_usecase.dart';

class GetWeddingAnalyticsUseCase
    extends UseCase<WeddingAnalyticsEntity, WeddingIdParams> {
  const GetWeddingAnalyticsUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, WeddingAnalyticsEntity>> call(
    WeddingIdParams params,
  ) =>
      _repository.getAnalytics(params.weddingId);
}
