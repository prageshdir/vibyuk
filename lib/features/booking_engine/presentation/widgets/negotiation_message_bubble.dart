import 'package:flutter/material.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_negotiation_message_entity.dart';

class NegotiationMessageBubble extends StatelessWidget {
  const NegotiationMessageBubble({
    super.key,
    required this.msg,
    required this.isCurrentUser,
  });

  final BookingNegotiationMessageEntity msg;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (msg.isSystem) {
      return _SystemBubble(msg: msg);
    }

    final bubbleColor = isCurrentUser
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final textColor =
        isCurrentUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              backgroundImage: msg.senderAvatarUrl != null
                  ? NetworkImage(msg.senderAvatarUrl!)
                  : null,
              child: msg.senderAvatarUrl == null
                  ? Text(msg.senderName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 12))
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft:
                      Radius.circular(isCurrentUser ? 18 : 4),
                  bottomRight:
                      Radius.circular(isCurrentUser ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(
                      msg.senderName,
                      style: TextStyle(
                          color: textColor.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  if (msg.isOffer && msg.offeredPrice != null) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sell_outlined,
                            size: 14, color: textColor.withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Text(
                          '${msg.currency ?? ''} ${msg.offeredPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 16),
                        ),
                      ],
                    ),
                    Text(
                      msg.type == NegotiationMessageType.offer
                          ? 'Initial offer'
                          : 'Counter-offer',
                      style: TextStyle(
                          color: textColor.withValues(alpha: 0.7), fontSize: 11),
                    ),
                  ],
                  if (msg.message != null && msg.message!.isNotEmpty)
                    Text(msg.message!,
                        style: TextStyle(color: textColor, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(msg.createdAt),
                    style: TextStyle(
                        color: textColor.withValues(alpha: 0.6), fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _SystemBubble extends StatelessWidget {
  const _SystemBubble({required this.msg});
  final BookingNegotiationMessageEntity msg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAccepted = msg.type == NegotiationMessageType.acceptance;
    final color = isAccepted ? Colors.green : Colors.red;
    final icon =
        isAccepted ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label = isAccepted ? 'Offer Accepted' : 'Offer Rejected';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
