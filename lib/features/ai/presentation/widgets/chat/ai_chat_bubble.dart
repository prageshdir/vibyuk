import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_chat_message.dart';

class AiChatBubble extends StatelessWidget {
  final AiChatMessage message;
  final VoidCallback? onRetry;

  const AiChatBubble({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: message.isFromUser ? 60 : 0,
        right: message.isFromUser ? 0 : 60,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: message.isFromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isFromUser) ...[
            _AiAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isFromUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!message.isFromUser)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      'Viby AI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: message.isFromUser
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.brandGradient,
                          )
                        : null,
                    color: message.isFromUser
                        ? null
                        : Theme.of(context).brightness == Brightness.dark
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(
                        message.isFromUser ? 18 : 4,
                      ),
                      bottomRight: Radius.circular(
                        message.isFromUser ? 4 : 18,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (message.isFromUser
                                ? AppColors.primary
                                : Colors.black)
                            .withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: message.hasFailed
                      ? _FailedContent(
                          content: message.content,
                          onRetry: onRetry,
                        )
                      : Text(
                          message.content,
                          style: TextStyle(
                            color: message.isFromUser
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (message.isFromUser) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isSending
                            ? Icons.schedule_rounded
                            : message.hasFailed
                                ? Icons.error_outline_rounded
                                : Icons.done_all_rounded,
                        size: 12,
                        color: message.hasFailed
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
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

class _AiAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.tertiary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}

class _FailedContent extends StatelessWidget {
  final String content;
  final VoidCallback? onRetry;

  const _FailedContent({required this.content, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onRetry,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh_rounded,
                size: 13,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 4),
              Text(
                'Retry',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
