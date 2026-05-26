import 'package:flutter/material.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_dispute.dart';
import 'package:vibyuk/features/admin/presentation/widgets/common/admin_status_badge.dart';

class AdminDisputeCard extends StatelessWidget {
  final AdminDispute dispute;
  final VoidCallback onTap;

  const AdminDisputeCard({
    super.key,
    required this.dispute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUrgent = dispute.isHighPriority;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent
                ? const Color(0xFFFF5C6B).withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.08),
            width: isUrgent ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _TypeIcon(type: dispute.type),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dispute.subject,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '#${dispute.id.substring(0, 8).toUpperCase()}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(dispute.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _PartyChip(
                  name: dispute.complainant.displayName,
                  role: dispute.complainant.role,
                  isComplainant: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
                _PartyChip(
                  name: dispute.respondent.displayName,
                  role: dispute.respondent.role,
                  isComplainant: false,
                ),
                const Spacer(),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5C6B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.priority_high_rounded,
                          size: 11,
                          color: Color(0xFFFF5C6B),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF5C6B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                ),
                const SizedBox(width: 4),
                Text(
                  '${dispute.daysSinceOpened}d open',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
                if (dispute.assignedModeratorName != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.person_outline_rounded,
                    size: 12,
                    color: const Color(0xFF7B2FFF).withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dispute.assignedModeratorName!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF7B2FFF).withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  _typeName(dispute.type),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(DisputeStatus status) => switch (status) {
        DisputeStatus.open => AdminStatusBadge.warning('Open'),
        DisputeStatus.inReview => AdminStatusBadge.info('In Review'),
        DisputeStatus.pendingInfo => AdminStatusBadge.neutral('Pending Info'),
        DisputeStatus.resolved => AdminStatusBadge.success('Resolved'),
        DisputeStatus.closed => AdminStatusBadge.neutral('Closed'),
        DisputeStatus.escalated => AdminStatusBadge.danger('Escalated'),
      };

  String _typeName(DisputeType type) => switch (type) {
        DisputeType.paymentIssue => 'Payment',
        DisputeType.serviceQuality => 'Quality',
        DisputeType.noShow => 'No-show',
        DisputeType.cancellation => 'Cancellation',
        DisputeType.fraud => 'Fraud',
        DisputeType.other => 'Other',
      };
}

class _TypeIcon extends StatelessWidget {
  final DisputeType type;
  const _TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      DisputeType.paymentIssue => (Icons.payment_rounded, const Color(0xFF7B2FFF)),
      DisputeType.serviceQuality => (Icons.star_outline_rounded, const Color(0xFFFFB020)),
      DisputeType.noShow => (Icons.person_off_rounded, const Color(0xFFFF5C6B)),
      DisputeType.cancellation => (Icons.cancel_rounded, const Color(0xFFFF8C42)),
      DisputeType.fraud => (Icons.security_rounded, const Color(0xFFFF5C6B)),
      DisputeType.other => (Icons.help_outline_rounded, Colors.grey),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _PartyChip extends StatelessWidget {
  final String name;
  final String role;
  final bool isComplainant;

  const _PartyChip({
    required this.name,
    required this.role,
    required this.isComplainant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          role,
          style: TextStyle(
            fontSize: 10,
            color: isComplainant
                ? const Color(0xFFFF5C6B).withValues(alpha: 0.7)
                : const Color(0xFF7B2FFF).withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
