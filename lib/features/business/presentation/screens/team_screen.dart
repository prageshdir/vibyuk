import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/business/domain/entities/team_member_entity.dart';
import 'package:vibyuk/features/business/presentation/blocs/team/team_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/business_empty_state.dart';
import 'package:vibyuk/features/business/presentation/widgets/team_member_tile.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeamBloc>().add(const LoadTeamEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_rounded),
            tooltip: 'Bulk invite',
            onPressed: () => _showBulkInviteDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Invite member',
            onPressed: () => _showInviteDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<TeamBloc, TeamState>(
        listener: (context, state) {
          if (state is MemberInvitedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Invite sent to ${state.member.email}')),
            );
          }
          if (state is BulkInvitedState) {
            final msg = state.failedEmails.isEmpty
                ? '${state.successCount} invite(s) sent successfully'
                : '${state.successCount} sent. Failed: ${state.failedEmails.join(', ')}';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: state.failedEmails.isEmpty
                    ? Colors.green
                    : AppColors.error,
              ),
            );
          }
          if (state is MemberRemovedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Member removed')),
            );
          }
          if (state is TeamErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) => switch (state) {
          TeamLoadingState() => const Center(child: AppLoader()),
          TeamLoadedState(:final members) => members.isEmpty
              ? BusinessEmptyState.noTeamMembers(
                  onInvite: () => _showInviteDialog(context),
                )
              : _MemberList(
                  members: members,
                  currentUserRole: _getMyRole(members),
                  onChangeRole: (m) => _showRoleDialog(context, m),
                  onRemove: (m) => _confirmRemove(context, m),
                ),
          TeamErrorState(:final failure) =>
            BusinessEmptyState(
              title: 'Failed to load team',
              description: failure.message,
              icon: Icons.error_outline_rounded,
              actionLabel: 'Retry',
              onAction: () =>
                  context.read<TeamBloc>().add(const LoadTeamEvent()),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  TeamRole _getMyRole(List<TeamMemberEntity> members) {
    // In a real app, compare with current user ID. Default to member for safety.
    return members.isNotEmpty ? members.first.role : TeamRole.member;
  }

  void _showInviteDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    TeamRole selectedRole = TeamRole.member;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Invite team member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: emailCtrl,
                label: 'Email address',
                hint: 'colleague@company.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TeamRole>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                items: [
                  TeamRole.admin,
                  TeamRole.member,
                  TeamRole.viewer,
                ].map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(r.label),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => selectedRole = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              label: 'Send invite',
              onPressed: () {
                if (emailCtrl.text.isNotEmpty) {
                  Navigator.pop(ctx);
                  context.read<TeamBloc>().add(
                        InviteTeamMemberEvent(
                          email: emailCtrl.text.trim(),
                          role: selectedRole,
                        ),
                      );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkInviteDialog(BuildContext context) {
    final bulkEmailCtrl = TextEditingController();
    TeamRole selectedRole = TeamRole.member;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Bulk invite'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter multiple email addresses, one per line or comma-separated.',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bulkEmailCtrl,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\t')),
                ],
                decoration: InputDecoration(
                  hintText: 'alice@co.com\nbob@co.com',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TeamRole>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role for all',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                items: [TeamRole.admin, TeamRole.member, TeamRole.viewer]
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.label),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => selectedRole = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              label: 'Send invites',
              onPressed: () {
                final raw = bulkEmailCtrl.text;
                final emails = raw
                    .split(RegExp(r'[\n,]+'))
                    .map((e) => e.trim())
                    .where((e) => e.contains('@'))
                    .toList();
                if (emails.isNotEmpty) {
                  Navigator.pop(ctx);
                  context.read<TeamBloc>().add(
                        BulkInviteTeamMembersEvent(
                          emails: emails,
                          role: selectedRole,
                        ),
                      );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleDialog(BuildContext context, TeamMemberEntity member) {
    TeamRole selectedRole = member.role;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Change ${member.displayName}\'s role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [TeamRole.admin, TeamRole.member, TeamRole.viewer]
                .map((r) {
              return RadioListTile<TeamRole>(
                value: r,
                groupValue: selectedRole,
                title: Text(r.label),
                onChanged: (v) {
                  if (v != null) setState(() => selectedRole = v);
                },
                activeColor: AppColors.primary,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<TeamBloc>().add(
                      UpdateTeamMemberRoleEvent(
                        memberId: member.id,
                        role: selectedRole,
                      ),
                    );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, TeamMemberEntity member) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove member?'),
        content: Text(
            'Remove ${member.displayName} from the team? They will lose access immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TeamBloc>().add(
                    RemoveTeamMemberEvent(memberId: member.id),
                  );
            },
            style: TextButton.styleFrom(
                foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _MemberList extends StatelessWidget {
  final List<TeamMemberEntity> members;
  final TeamRole currentUserRole;
  final ValueChanged<TeamMemberEntity> onChangeRole;
  final ValueChanged<TeamMemberEntity> onRemove;

  const _MemberList({
    required this.members,
    required this.currentUserRole,
    required this.onChangeRole,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: members.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 68),
      itemBuilder: (context, index) {
        final member = members[index];
        return TeamMemberTile(
          member: member,
          canManage: currentUserRole.canManageTeam &&
              member.role != TeamRole.owner,
          onChangeRole: () => onChangeRole(member),
          onRemove: () => onRemove(member),
        );
      },
    );
  }
}
