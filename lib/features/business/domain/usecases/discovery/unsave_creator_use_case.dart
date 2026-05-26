import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/repositories/discovery_repository.dart';

class UnsaveCreatorUseCase implements UseCase<Unit, UnsaveCreatorParams> {
  UnsaveCreatorUseCase(this._repository);
  final DiscoveryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(UnsaveCreatorParams params) {
    return _repository.unsaveCreator(params.creatorId);
  }
}

class UnsaveCreatorParams extends Equatable {
  const UnsaveCreatorParams({required this.creatorId});
  final String creatorId;

  @override
  List<Object?> get props => [creatorId];
}
