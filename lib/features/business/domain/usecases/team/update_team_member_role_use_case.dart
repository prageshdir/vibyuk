import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/team_member_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/team_repository.dart';

class UpdateTeamMemberRoleUseCase
    implements UseCase<TeamMemberEntity, UpdateTeamMemberRoleParams> {
  UpdateTeamMemberRoleUseCase(this._repository);
  final TeamRepository _repository;

  @override
  Future<Either<Failure, TeamMemberEntity>> call(UpdateTeamMemberRoleParams params) {
    return _repository.updateTeamMemberRole(
        memberId: params.memberId, role: params.role);
  }
}

class UpdateTeamMemberRoleParams extends Equatable {
  const UpdateTeamMemberRoleParams({required this.memberId, required this.role});
  final String memberId;
  final TeamRole role;

  @override
  List<Object?> get props => [memberId, role];
}
