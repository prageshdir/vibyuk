import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/team_member_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/team_repository.dart';

class InviteTeamMemberUseCase
    implements UseCase<TeamMemberEntity, InviteTeamMemberParams> {
  InviteTeamMemberUseCase(this._repository);
  final TeamRepository _repository;

  @override
  Future<Either<Failure, TeamMemberEntity>> call(InviteTeamMemberParams params) {
    return _repository.inviteTeamMember(email: params.email, role: params.role);
  }
}

class InviteTeamMemberParams extends Equatable {
  const InviteTeamMemberParams({required this.email, required this.role});
  final String email;
  final TeamRole role;

  @override
  List<Object?> get props => [email, role];
}
