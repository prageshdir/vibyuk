import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
  });

  final ChatMessageEntity message;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (message.isMe) return _buildMyBubble(context, theme);
    return _buildTheirBubble(context, theme);
  }

  Widget _buildMyBubble(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 12, top: 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  message.text ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 4),
                  _StatusIcon(status: message.status),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTheirBubble(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 64, top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showAvatar)
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              backgroundImage: message.senderAvatarUrl != null
                  ? NetworkImage(message.senderAvatarUrl!)
                  : null,
              child: message.senderAvatarUrl == null
                  ? Text(
                      message.senderName[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    )
                  : null,
            )
          else
            const SizedBox(width: 28),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Text(
                  message.text ?? '',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface, fontSize: 14),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTime(message.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});
  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
                strokeWidth: 1.5, color: Colors.white54));
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 12, color: Colors.white70);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 12, color: Colors.white70);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 12, color: AppColors.tertiary);
      case MessageStatus.failed:
        return const Icon(Icons.error_outline, size: 12, color: Colors.red);
    }
  }
}
