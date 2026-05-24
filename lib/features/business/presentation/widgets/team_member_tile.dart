import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/business/domain/entities/team_member_entity.dart';

class TeamMemberTile extends StatelessWidget {
  final TeamMemberEntity member;
  final bool canManage;
  final VoidCallback? onChangeRole;
  final VoidCallback? onRemove;
  final VoidCallback? onResendInvite;

  const TeamMemberTile({
    super.key,
    required this.member,
    this.canManage = false,
    this.onChangeRole,
    this.onRemove,
    this.onResendInvite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _Avatar(member: member),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _RoleBadge(role: member.role),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  member.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (member.isPending)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _InvitePendingBadge(onResend: onResendInvite),
                  ),
              ],
            ),
          ),
          if (canManage && member.role != TeamRole.owner)
            _ActionsMenu(
              member: member,
              onChangeRole: onChangeRole,
              onRemove: onRemove,
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final TeamMemberEntity member;
  const _Avatar({required this.member});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primaryContainer,
      backgroundImage:
          member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
      child: member.avatarUrl == null
          ? Text(
              member.initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            )
          : null,
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final TeamRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (role) {
      TeamRole.owner => (AppColors.primaryContainer, AppColors.primary),
      TeamRole.admin => (AppColors.secondaryContainer, AppColors.secondary),
      TeamRole.member => (AppColors.surfaceVariant, AppColors.textSecondary),
      TeamRole.viewer => (AppColors.surfaceVariant, AppColors.textDisabled),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InvitePendingBadge extends StatelessWidget {
  final VoidCallback? onResend;
  const _InvitePendingBadge({this.onResend});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.warningContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Invite pending',
            style: TextStyle(
                color: AppColors.warning,
                fontSize: 10,
                fontWeight: FontWeight.w600),
          ),
        ),
        if (onResend != null) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onResend,
            child: const Text(
              'Resend',
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  final TeamMemberEntity member;
  final VoidCallback? onChangeRole;
  final VoidCallback? onRemove;

  const _ActionsMenu({
    required this.member,
    this.onChangeRole,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded,
          size: 18, color: AppColors.textSecondary),
      itemBuilder: (_) => [
        if (onChangeRole != null)
          const PopupMenuItem(
            value: 'role',
            child: Text('Change role'),
          ),
        if (onRemove != null)
          const PopupMenuItem(
            value: 'remove',
            child: Text('Remove member',
                style: TextStyle(color: AppColors.error)),
          ),
      ],
      onSelected: (value) {
        if (value == 'role') onChangeRole?.call();
        if (value == 'remove') onRemove?.call();
      },
    );
  }
}
