import 'package:flutter/material.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/booking_engine/presentation/widgets/booking_status_chip.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.trailing,
  });

  final BookingEntity booking;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Business logo
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: booking.businessLogoUrl != null
                        ? NetworkImage(booking.businessLogoUrl!)
                        : null,
                    child: booking.businessLogoUrl == null
                        ? Text(
                            booking.businessName[0].toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.businessName,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          booking.packageTitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  BookingStatusChip(status: booking.status),
                ],
              ),
              const SizedBox(height: 12),

              // Amount + date row
              Row(
                children: [
                  const Icon(Icons.currency_rupee_rounded,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.currency} ${booking.totalAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  const Icon(Icons.calendar_today_outlined,
                      size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(booking.scheduledDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),

              // Milestone progress if applicable
              if (booking.milestonesTotal > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: booking.milestoneProgress,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${booking.milestonesCompleted}/${booking.milestonesTotal}',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],

              // Alerts
              if (booking.hasActiveDispute) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 13, color: Colors.deepOrange),
                    const SizedBox(width: 4),
                    Text(
                      'Active dispute',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.deepOrange),
                    ),
                  ],
                ),
              ],

              if (trailing != null) ...[
                const SizedBox(height: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}
