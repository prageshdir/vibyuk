import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/chat/domain/entities/conversation_entity.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final ConversationEntity conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeLabel = _formatTime(conversation.lastMessageAt);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  backgroundImage: conversation.otherUserAvatarUrl != null
                      ? NetworkImage(conversation.otherUserAvatarUrl!)
                      : null,
                  child: conversation.otherUserAvatarUrl == null
                      ? Text(
                          conversation.otherUserName[0].toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontSize: 18),
                        )
                      : null,
                ),
                if (conversation.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: theme.colorScheme.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUserName,
                          style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: conversation.hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeLabel != null)
                        Text(
                          timeLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: conversation.hasUnread
                                  ? AppColors.primary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: conversation.hasUnread
                                  ? FontWeight.w600
                                  : null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage ?? 'Start a conversation',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: conversation.hasUnread
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: conversation.hasUnread
                                  ? FontWeight.w500
                                  : null),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            conversation.unreadCount > 99
                                ? '99+'
                                : '${conversation.unreadCount}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _formatTime(DateTime? dt) {
    if (dt == null) return null;
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dt.weekday - 1];
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}
