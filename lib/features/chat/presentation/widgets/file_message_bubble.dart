import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';

class FileMessageBubble extends StatelessWidget {
  const FileMessageBubble({super.key, required this.message});
  final ChatMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = message.isMe;

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 64 : 52,
        right: isMe ? 12 : 64,
        top: 2,
        bottom: 2,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? null : theme.colorScheme.surfaceVariant,
          gradient: isMe
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark])
              : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isMe ? Colors.white : AppColors.primary)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.insert_drive_file_rounded,
                color: isMe ? Colors.white : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.fileName ?? 'File',
                    style: TextStyle(
                      color: isMe ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (message.fileSize != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _fmtSize(message.fileSize!),
                      style: TextStyle(
                        color: isMe
                            ? Colors.white70
                            : theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    _fmt(message.createdAt),
                    style: TextStyle(
                      color: isMe
                          ? Colors.white60
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.download_rounded,
              color: isMe ? Colors.white70 : AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _fmtSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
