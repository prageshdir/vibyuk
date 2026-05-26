import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class GetWeddingUseCase extends UseCase<WeddingEntity, WeddingIdParams> {
  const GetWeddingUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, WeddingEntity>> call(WeddingIdParams params) =>
      _repository.getWedding(params.weddingId);
}

class WeddingIdParams extends Equatable {
  const WeddingIdParams(this.weddingId);
  final String weddingId;

  @override
  List<Object?> get props => [weddingId];
}
