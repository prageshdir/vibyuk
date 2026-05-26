import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/base/base_repository.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/data/datasources/team_remote_data_source.dart';
import 'package:vibyuk/features/business/data/dtos/invite_team_member_dto.dart';
import 'package:vibyuk/features/business/data/models/team_member_model.dart';
import 'package:vibyuk/features/business/domain/entities/team_member_entity.dart';
import 'package:vibyuk/features/business/domain/repositories/team_repository.dart';

class TeamRepositoryImpl extends BaseRepository implements TeamRepository {
  TeamRepositoryImpl({required TeamRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final TeamRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<TeamMemberEntity>>> getTeamMembers() =>
      safeCall(() async {
        final list = await _remote.getTeamMembers();
        return list
            .map((e) =>
                TeamMemberModel.fromJson(e as Map<String, dynamic>).toEntity())
            .toList();
      });

  @override
  Future<Either<Failure, TeamMemberEntity>> inviteTeamMember({
    required String email,
    required TeamRole role,
  }) =>
      safeCall(() async {
        final dto = InviteTeamMemberDto.fromRole(email, role);
        final data = await _remote.inviteTeamMember(dto);
        return TeamMemberModel.fromJson(data).toEntity();
      });

  @override
  Future<Either<Failure, Unit>> removeTeamMember(String memberId) =>
      safeCall(() async {
        await _remote.removeTeamMember(memberId);
        return unit;
      });

  @override
  Future<Either<Failure, TeamMemberEntity>> updateTeamMemberRole({
    required String memberId,
    required TeamRole role,
  }) =>
      safeCall(() async {
        final data = await _remote.updateTeamMemberRole(memberId, role);
        return TeamMemberModel.fromJson(data).toEntity();
      });
}
