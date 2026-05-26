part of 'team_bloc.dart';

sealed class TeamState extends Equatable {
  const TeamState();
}

class TeamInitialState extends TeamState {
  const TeamInitialState();
  @override
  List<Object?> get props => [];
}

class TeamLoadingState extends TeamState {
  const TeamLoadingState();
  @override
  List<Object?> get props => [];
}

class TeamLoadedState extends TeamState {
  const TeamLoadedState({required this.members});
  final List<TeamMemberEntity> members;

  TeamLoadedState copyWith({List<TeamMemberEntity>? members}) =>
      TeamLoadedState(members: members ?? this.members);

  @override
  List<Object?> get props => [members];
}

class MemberInvitedState extends TeamState {
  const MemberInvitedState({required this.member});
  final TeamMemberEntity member;
  @override
  List<Object?> get props => [member];
}

class MemberRemovedState extends TeamState {
  const MemberRemovedState({required this.memberId});
  final String memberId;
  @override
  List<Object?> get props => [memberId];
}

class MemberRoleUpdatedState extends TeamState {
  const MemberRoleUpdatedState({required this.member});
  final TeamMemberEntity member;
  @override
  List<Object?> get props => [member];
}

class BulkInvitedState extends TeamState {
  const BulkInvitedState({
    required this.successCount,
    required this.failedEmails,
  });
  final int successCount;
  final List<String> failedEmails;
  @override
  List<Object?> get props => [successCount, failedEmails];
}

class TeamErrorState extends TeamState {
  const TeamErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
