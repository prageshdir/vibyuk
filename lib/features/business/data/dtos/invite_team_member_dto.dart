import 'package:vibyuk/features/business/domain/entities/team_member_entity.dart';
import 'package:vibyuk/features/business/domain/usecases/team/invite_team_member_use_case.dart';

class InviteTeamMemberDto {
  const InviteTeamMemberDto({required this.email, required this.role});

  final String email;
  final String role;

  factory InviteTeamMemberDto.fromParams(InviteTeamMemberParams params) =>
      InviteTeamMemberDto(email: params.email, role: params.role.name);

  factory InviteTeamMemberDto.fromRole(String email, TeamRole role) =>
      InviteTeamMemberDto(email: email, role: role.name);

  Map<String, dynamic> toJson() => {'email': email, 'role': role};
}
