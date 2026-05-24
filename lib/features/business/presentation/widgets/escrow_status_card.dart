import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/business/domain/entities/escrow_entity.dart';

class EscrowStatusCard extends StatelessWidget {
  const EscrowStatusCard({
    super.key,
    required this.escrow,
    this.onRelease,
    this.onRefund,
  });

  final EscrowEntity escrow;
  final VoidCallback? onRelease;
  final VoidCallback? onRefund;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: AppColors.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text('Escrow', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                _StatusChip(status: escrow.status),
              ],
            ),
            const Divider(height: 24, color: AppColors.divider),
            _Row('Total', escrow.amountDisplay),
            const SizedBox(height: 6),
            _Row('Platform fee', '₹${escrow.platformFee.toStringAsFixed(2)}'),
            const SizedBox(height: 6),
            _Row('Creator receives', escrow.creatorAmountDisplay,
                valueColor: AppColors.success),
            if (escrow.status.isActive) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  if (onRelease != null)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onRelease,
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Release'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                      ),
                    ),
                  if (onRelease != null && onRefund != null) const SizedBox(width: 12),
                  if (onRefund != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRefund,
                        icon: const Icon(Icons.undo, size: 18),
                        label: const Text('Refund'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final EscrowStatus status;

  Color get _color => switch (status) {
        EscrowStatus.held => AppColors.warning,
        EscrowStatus.releasePending => AppColors.primary,
        EscrowStatus.released => AppColors.success,
        EscrowStatus.refundPending => AppColors.secondary,
        EscrowStatus.refunded => AppColors.textSecondary,
        EscrowStatus.disputed => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
