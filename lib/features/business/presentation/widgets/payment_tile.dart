import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/business/domain/entities/payment_entity.dart';

class PaymentTile extends StatelessWidget {
  final PaymentEntity payment;
  final VoidCallback? onTap;

  const PaymentTile({
    super.key,
    required this.payment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _TypeIcon(type: payment.type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.description,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _StatusChip(status: payment.status),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('d MMM y').format(payment.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              payment.amountDisplay,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: switch (payment.status) {
                  PaymentStatus.refunded => AppColors.error,
                  PaymentStatus.failed => AppColors.error,
                  _ => AppColors.textPrimary,
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  final PaymentType type;
  const _TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color, bg) = switch (type) {
      PaymentType.booking => (
          Icons.calendar_today_rounded,
          AppColors.primary,
          AppColors.primaryContainer,
        ),
      PaymentType.subscription => (
          Icons.star_rounded,
          AppColors.secondary,
          AppColors.secondaryContainer,
        ),
      PaymentType.addon => (
          Icons.add_circle_rounded,
          AppColors.tertiary,
          AppColors.tertiaryContainer,
        ),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final PaymentStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      PaymentStatus.pending => (AppColors.warningContainer, AppColors.warning),
      PaymentStatus.completed => (AppColors.successContainer, AppColors.success),
      PaymentStatus.failed => (AppColors.errorContainer, AppColors.error),
      PaymentStatus.refunded => (AppColors.errorContainer, AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
