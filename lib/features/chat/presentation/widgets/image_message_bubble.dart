import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';

class ImageMessageBubble extends StatelessWidget {
  const ImageMessageBubble({super.key, required this.message});
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
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _openViewer(context),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              child: CachedNetworkImage(
                imageUrl: message.mediaUrl ?? '',
                width: 220,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 220,
                  height: 200,
                  color: theme.colorScheme.surfaceVariant,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 220,
                  height: 200,
                  color: theme.colorScheme.surfaceVariant,
                  child: const Icon(Icons.broken_image_rounded, size: 40),
                ),
              ),
            ),
          ),
          if (message.text != null && message.text!.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxWidth: 220),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primary
                    : theme.colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                message.text!,
                style: TextStyle(
                  color: isMe ? Colors.white : theme.colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(height: 2),
          Text(
            _fmt(message.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _openViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => _ImageViewer(imageUrl: message.mediaUrl ?? '')),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _ImageViewer extends StatelessWidget {
  const _ImageViewer({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
