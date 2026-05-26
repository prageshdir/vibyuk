import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/repositories/discovery_repository.dart';

class SaveCreatorUseCase implements UseCase<Unit, SaveCreatorParams> {
  SaveCreatorUseCase(this._repository);
  final DiscoveryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SaveCreatorParams params) {
    return _repository.saveCreator(params.creatorId);
  }
}

class SaveCreatorParams extends Equatable {
  const SaveCreatorParams({required this.creatorId});
  final String creatorId;

  @override
  List<Object?> get props => [creatorId];
}
