import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/business/domain/entities/transaction_entity.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({super.key, required this.transaction, this.onTap});
  final TransactionEntity transaction;
  final VoidCallback? onTap;

  static final _fmt = DateFormat('d MMM y, h:mm a');

  IconData get _icon => switch (transaction.type) {
        TransactionType.payment => Icons.payment_rounded,
        TransactionType.refund => Icons.undo_rounded,
        TransactionType.escrowHold => Icons.lock_rounded,
        TransactionType.escrowRelease => Icons.lock_open_rounded,
        TransactionType.payout => Icons.account_balance_rounded,
        TransactionType.platformFee => Icons.percent_rounded,
        TransactionType.adjustment => Icons.tune_rounded,
      };

  Color get _iconColor => transaction.type.isCredit ? AppColors.success : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: _iconColor.withOpacity(0.12),
        child: Icon(_icon, color: _iconColor, size: 20),
      ),
      title: Text(
        transaction.type.label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.description,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            _fmt.format(transaction.createdAt),
            style: const TextStyle(fontSize: 11, color: AppColors.textDisabled),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${transaction.type.isCredit ? '+' : '-'}${transaction.amountDisplay}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: transaction.type.isCredit ? AppColors.success : AppColors.textPrimary,
            ),
          ),
          _StatusBadge(status: transaction.status),
        ],
      ),
      isThreeLine: true,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final TransactionStatus status;

  Color get _color => switch (status) {
        TransactionStatus.pending => AppColors.warning,
        TransactionStatus.processing => AppColors.primary,
        TransactionStatus.completed => AppColors.success,
        TransactionStatus.failed => AppColors.error,
        TransactionStatus.reversed => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Text(
      status.name,
      style: TextStyle(fontSize: 10, color: _color, fontWeight: FontWeight.w600),
    );
  }
}
