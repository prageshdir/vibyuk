import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/repositories/team_repository.dart';

class RemoveTeamMemberUseCase implements UseCase<Unit, RemoveTeamMemberParams> {
  RemoveTeamMemberUseCase(this._repository);
  final TeamRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(RemoveTeamMemberParams params) {
    return _repository.removeTeamMember(params.memberId);
  }
}

class RemoveTeamMemberParams extends Equatable {
  const RemoveTeamMemberParams({required this.memberId});
  final String memberId;

  @override
  List<Object?> get props => [memberId];
}
