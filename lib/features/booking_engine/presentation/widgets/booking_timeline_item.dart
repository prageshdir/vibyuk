import 'package:flutter/material.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_timeline_event_entity.dart';

class BookingTimelineItem extends StatelessWidget {
  const BookingTimelineItem({
    super.key,
    required this.event,
    required this.isLast,
  });

  final BookingTimelineEventEntity event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _config(event.type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: color.withValues(alpha: 0.4), width: 2),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    event.title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (event.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (event.actorName != null) ...[
                        const Icon(Icons.person_outline,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 3),
                        Text(event.actorName!,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(width: 8),
                      ],
                      const Icon(Icons.access_time,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        _formatDateTime(event.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static (IconData, Color) _config(TimelineEventType t) => switch (t) {
        TimelineEventType.bookingCreated => (
            Icons.add_circle_outline_rounded,
            Colors.blue
          ),
        TimelineEventType.bookingConfirmed => (
            Icons.check_circle_outline_rounded,
            Colors.green
          ),
        TimelineEventType.contractSent ||
        TimelineEventType.contractSigned =>
          (Icons.description_outlined, Colors.purple),
        TimelineEventType.milestoneStarted => (
            Icons.play_circle_outline_rounded,
            Colors.teal
          ),
        TimelineEventType.milestoneSubmitted => (
            Icons.upload_outlined,
            Colors.orange
          ),
        TimelineEventType.milestoneApproved => (
            Icons.thumb_up_outlined,
            Colors.green
          ),
        TimelineEventType.milestoneRejected => (
            Icons.thumb_down_outlined,
            Colors.red
          ),
        TimelineEventType.paymentReleased => (
            Icons.payments_outlined,
            Colors.green
          ),
        TimelineEventType.rescheduleRequested ||
        TimelineEventType.rescheduled =>
          (Icons.event_repeat_rounded, Colors.orange),
        TimelineEventType.disputeOpened => (
            Icons.warning_amber_rounded,
            Colors.deepOrange
          ),
        TimelineEventType.disputeResolved => (
            Icons.gavel_rounded,
            Colors.green
          ),
        TimelineEventType.bookingCompleted => (
            Icons.star_rounded,
            Colors.amber
          ),
        TimelineEventType.bookingCancelled => (
            Icons.cancel_outlined,
            Colors.red
          ),
        TimelineEventType.messageReceived => (
            Icons.chat_bubble_outline_rounded,
            Colors.blue
          ),
      };

  String _formatDateTime(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
