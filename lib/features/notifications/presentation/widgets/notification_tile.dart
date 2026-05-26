import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_entity.dart';
import 'package:vibyuk/features/notifications/presentation/widgets/notification_type_chip.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: _DismissBackground(),
      onDismissed: (_) => onDismissed?.call(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: isUnread
              ? AppColors.primaryContainer.withOpacity(0.3)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TypeIcon(type: notification.type, isUnread: isUnread),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _timeAgo(notification.receivedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    NotificationTypeChip(
                      type: notification.type,
                      compact: true,
                    ),
                  ],
                ),
              ),
              if (isUnread)
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
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}

class _TypeIcon extends StatelessWidget {
  final dynamic type;
  final bool isUnread;

  const _TypeIcon({required this.type, required this.isUnread});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _bgColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_icon, size: 22, color: _bgColor),
    );
  }

  Color get _bgColor {
    final t = type.toString();
    if (t.contains('booking')) return AppColors.primary;
    if (t.contains('Message') || t.contains('newMessage')) {
      return AppColors.tertiary;
    }
    if (t.contains('payment')) return AppColors.success;
    if (t.contains('campaign')) return AppColors.warning;
    if (t.contains('Review') || t.contains('review')) return AppColors.secondary;
    if (t.contains('event')) return AppColors.primaryLight;
    return AppColors.textSecondary;
  }

  IconData get _icon {
    final t = type.toString();
    if (t.contains('booking')) return Icons.calendar_month_outlined;
    if (t.contains('Message') || t.contains('newMessage')) {
      return Icons.chat_bubble_outline;
    }
    if (t.contains('payment')) return Icons.payments_outlined;
    if (t.contains('campaign')) return Icons.campaign_outlined;
    if (t.contains('review') || t.contains('Review')) return Icons.star_outline;
    if (t.contains('event')) return Icons.event_outlined;
    if (t.contains('followed')) return Icons.person_add_outlined;
    return Icons.notifications_outlined;
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.error,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
    );
  }
}
