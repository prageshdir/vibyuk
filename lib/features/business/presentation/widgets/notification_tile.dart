import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/business/domain/entities/notification_item_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationItemEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkRead;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (!notification.isRead) onMarkRead?.call();
        onTap?.call();
      },
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : AppColors.primaryContainer.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TypeIcon(type: notification.type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(notification.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textDisabled,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(dt);
  }
}

class _TypeIcon extends StatelessWidget {
  final NotificationType type;
  const _TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color, bg) = switch (type) {
      NotificationType.booking => (
          Icons.calendar_today_rounded,
          AppColors.primary,
          AppColors.primaryContainer,
        ),
      NotificationType.campaign => (
          Icons.campaign_rounded,
          AppColors.tertiary,
          AppColors.tertiaryContainer,
        ),
      NotificationType.payment => (
          Icons.payments_rounded,
          AppColors.success,
          AppColors.successContainer,
        ),
      NotificationType.team => (
          Icons.group_rounded,
          AppColors.secondary,
          AppColors.secondaryContainer,
        ),
      NotificationType.system => (
          Icons.info_rounded,
          AppColors.textSecondary,
          AppColors.surfaceVariant,
        ),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 18),
    );
  }
}
