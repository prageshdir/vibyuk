import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/team_member_entity.dart';
import 'package:vibyuk/features/business/domain/usecases/team/get_team_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/team/invite_team_member_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/team/remove_team_member_use_case.dart';
import 'package:vibyuk/features/business/domain/usecases/team/update_team_member_role_use_case.dart';

part 'team_event.dart';
part 'team_state.dart';

class TeamBloc extends BaseBloc<TeamEvent, TeamState> {
  TeamBloc({
    required GetTeamUseCase getTeam,
    required InviteTeamMemberUseCase inviteTeamMember,
    required RemoveTeamMemberUseCase removeTeamMember,
    required UpdateTeamMemberRoleUseCase updateTeamMemberRole,
  })  : _getTeam = getTeam,
        _inviteTeamMember = inviteTeamMember,
        _removeTeamMember = removeTeamMember,
        _updateTeamMemberRole = updateTeamMemberRole,
        super(const TeamInitialState()) {
    on<LoadTeamEvent>(_onLoad);
    on<InviteTeamMemberEvent>(_onInvite);
    on<BulkInviteTeamMembersEvent>(_onBulkInvite);
    on<RemoveTeamMemberEvent>(_onRemove);
    on<UpdateTeamMemberRoleEvent>(_onUpdateRole);
  }

  final GetTeamUseCase _getTeam;
  final InviteTeamMemberUseCase _inviteTeamMember;
  final RemoveTeamMemberUseCase _removeTeamMember;
  final UpdateTeamMemberRoleUseCase _updateTeamMemberRole;

  List<TeamMemberEntity> _cachedMembers = [];

  Future<void> _onLoad(LoadTeamEvent event, Emitter<TeamState> emit) async {
    emit(const TeamLoadingState());
    final result = await _getTeam();
    result.fold(
      (f) => emit(TeamErrorState(failure: f)),
      (members) {
        _cachedMembers = members;
        emit(TeamLoadedState(members: members));
      },
    );
  }

  Future<void> _onInvite(
      InviteTeamMemberEvent event, Emitter<TeamState> emit) async {
    emit(const TeamLoadingState());
    final result = await _inviteTeamMember(
        InviteTeamMemberParams(email: event.email, role: event.role));
    result.fold(
      (f) => emit(TeamErrorState(failure: f)),
      (member) {
        _cachedMembers = [..._cachedMembers, member];
        emit(MemberInvitedState(member: member));
      },
    );
  }

  Future<void> _onBulkInvite(
      BulkInviteTeamMembersEvent event, Emitter<TeamState> emit) async {
    emit(const TeamLoadingState());
    final failedEmails = <String>[];
    int successCount = 0;

    for (final email in event.emails) {
      final result = await _inviteTeamMember(
          InviteTeamMemberParams(email: email, role: event.role));
      result.fold(
        (_) => failedEmails.add(email),
        (member) {
          _cachedMembers = [..._cachedMembers, member];
          successCount++;
        },
      );
    }

    emit(BulkInvitedState(
      successCount: successCount,
      failedEmails: failedEmails,
    ));
  }

  Future<void> _onRemove(
      RemoveTeamMemberEvent event, Emitter<TeamState> emit) async {
    final result = await _removeTeamMember(
        RemoveTeamMemberParams(memberId: event.memberId));
    result.fold(
      (f) => emit(TeamErrorState(failure: f)),
      (_) {
        _cachedMembers =
            _cachedMembers.where((m) => m.id != event.memberId).toList();
        emit(MemberRemovedState(memberId: event.memberId));
      },
    );
  }

  Future<void> _onUpdateRole(
      UpdateTeamMemberRoleEvent event, Emitter<TeamState> emit) async {
    final result = await _updateTeamMemberRole(UpdateTeamMemberRoleParams(
      memberId: event.memberId,
      role: event.role,
    ));
    result.fold(
      (f) => emit(TeamErrorState(failure: f)),
      (member) {
        _cachedMembers = _cachedMembers
            .map((m) => m.id == event.memberId ? member : m)
            .toList();
        emit(MemberRoleUpdatedState(member: member));
      },
    );
  }
}
