import 'package:flutter/material.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_user.dart';
import 'package:vibyuk/features/admin/presentation/widgets/common/admin_status_badge.dart';

class AdminUserCard extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onTap;
  final VoidCallback? onActionTap;

  const AdminUserCard({
    super.key,
    required this.user,
    required this.onTap,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: user.isHighRisk
                ? const Color(0xFFFF5C6B).withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _Avatar(user: user),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _statusBadge(user.status),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _chip(
                        Icons.star_rounded,
                        '${user.trustScore.toInt()}',
                        const Color(0xFFFFB020),
                      ),
                      const SizedBox(width: 8),
                      _chip(
                        Icons.flag_rounded,
                        '${user.flagCount}',
                        user.isHighRisk
                            ? const Color(0xFFFF5C6B)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 8),
                      _chip(
                        Icons.person_rounded,
                        _roleName(user.role),
                        const Color(0xFF7B2FFF),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onActionTap != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onActionTap,
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _statusBadge(AdminUserStatus status) {
    return switch (status) {
      AdminUserStatus.active => AdminStatusBadge.success('Active'),
      AdminUserStatus.suspended => AdminStatusBadge.warning('Suspended'),
      AdminUserStatus.banned => AdminStatusBadge.danger('Banned'),
      AdminUserStatus.pendingVerification =>
        AdminStatusBadge.info('Pending'),
      AdminUserStatus.deactivated => AdminStatusBadge.neutral('Deactivated'),
    };
  }

  String _roleName(AdminUserRole role) => switch (role) {
        AdminUserRole.client => 'Client',
        AdminUserRole.creator => 'Creator',
        AdminUserRole.moderator => 'Mod',
        AdminUserRole.admin => 'Admin',
        AdminUserRole.superAdmin => 'Super',
      };
}

class _Avatar extends StatelessWidget {
  final AdminUser user;
  const _Avatar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF7B2FFF).withValues(alpha: 0.15),
          backgroundImage:
              user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null
              ? Text(
                  user.displayName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF7B2FFF),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                )
              : null,
        ),
        if (user.isHighRisk)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5C6B),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).cardColor,
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.warning, size: 8, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
