import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/team_member_entity.dart';

abstract interface class TeamRepository {
  Future<Either<Failure, List<TeamMemberEntity>>> getTeamMembers();

  Future<Either<Failure, TeamMemberEntity>> inviteTeamMember({
    required String email,
    required TeamRole role,
  });

  Future<Either<Failure, Unit>> removeTeamMember(String memberId);

  Future<Either<Failure, TeamMemberEntity>> updateTeamMemberRole({
    required String memberId,
    required TeamRole role,
  });
}
