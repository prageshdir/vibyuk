import 'package:flutter/material.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_milestone_entity.dart';

class MilestoneCard extends StatelessWidget {
  const MilestoneCard({
    super.key,
    required this.milestone,
    this.onSubmit,
    this.onApprove,
    this.onReject,
    this.isActioning = false,
  });

  final BookingMilestoneEntity milestone;
  final VoidCallback? onSubmit;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isActioning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusLabel, statusColor) = _statusConfig(milestone.status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _OrderBadge(order: milestone.order),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(milestone.title,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      if (milestone.description != null)
                        Text(milestone.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.currency_rupee_rounded,
                    size: 13, color: Colors.grey),
                const SizedBox(width: 2),
                Text(
                  '${milestone.currency} ${milestone.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Due ${_formatDate(milestone.dueDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: milestone.isOverdue
                        ? Colors.red
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            if (milestone.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        milestone.rejectionReason!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (onSubmit != null ||
                onApprove != null ||
                onReject != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onSubmit != null)
                    Expanded(
                      child: FilledButton(
                        onPressed: isActioning ? null : onSubmit,
                        style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(38)),
                        child: isActioning
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Submit'),
                      ),
                    ),
                  if (onApprove != null) ...[
                    Expanded(
                      child: FilledButton(
                        onPressed: isActioning ? null : onApprove,
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size.fromHeight(38)),
                        child: const Text('Approve'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isActioning ? null : onReject,
                        style: OutlinedButton.styleFrom(
                            foregroundColor:
                                theme.colorScheme.error,
                            side: BorderSide(
                                color: theme.colorScheme.error),
                            minimumSize: const Size.fromHeight(38)),
                        child: const Text('Reject'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static (String, Color) _statusConfig(MilestoneStatus s) => switch (s) {
        MilestoneStatus.pending => ('Pending', Colors.grey),
        MilestoneStatus.inProgress => ('In Progress', Colors.blue),
        MilestoneStatus.submitted => ('Submitted', Colors.orange),
        MilestoneStatus.approved => ('Approved', Colors.green),
        MilestoneStatus.rejected => ('Rejected', Colors.red),
        MilestoneStatus.released => ('Released', Colors.teal),
      };

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _OrderBadge extends StatelessWidget {
  const _OrderBadge({required this.order});
  final int order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$order',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
