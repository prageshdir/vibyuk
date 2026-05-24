part of 'team_bloc.dart';

sealed class TeamEvent extends Equatable {
  const TeamEvent();
}

class LoadTeamEvent extends TeamEvent {
  const LoadTeamEvent();
  @override
  List<Object?> get props => [];
}

class InviteTeamMemberEvent extends TeamEvent {
  const InviteTeamMemberEvent({required this.email, required this.role});
  final String email;
  final TeamRole role;
  @override
  List<Object?> get props => [email, role];
}

class RemoveTeamMemberEvent extends TeamEvent {
  const RemoveTeamMemberEvent({required this.memberId});
  final String memberId;
  @override
  List<Object?> get props => [memberId];
}

class UpdateTeamMemberRoleEvent extends TeamEvent {
  const UpdateTeamMemberRoleEvent({
    required this.memberId,
    required this.role,
  });
  final String memberId;
  final TeamRole role;
  @override
  List<Object?> get props => [memberId, role];
}
