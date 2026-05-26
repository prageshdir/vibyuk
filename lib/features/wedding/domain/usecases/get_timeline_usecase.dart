import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_timeline_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_wedding_usecase.dart';

class GetTimelineUseCase
    extends UseCase<WeddingTimelineEntity, WeddingIdParams> {
  const GetTimelineUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, WeddingTimelineEntity>> call(
    WeddingIdParams params,
  ) =>
      _repository.getTimeline(params.weddingId);
}
