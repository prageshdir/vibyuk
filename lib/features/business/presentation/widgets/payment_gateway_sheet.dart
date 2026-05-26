import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/business/domain/entities/payment_order_entity.dart';

class PaymentGatewaySheet extends StatelessWidget {
  const PaymentGatewaySheet({
    super.key,
    required this.amount,
    required this.bookingId,
    required this.onGatewaySelected,
  });

  final double amount;
  final String bookingId;
  final void Function(PaymentGateway gateway) onGatewaySelected;

  static Future<void> show(
    BuildContext context, {
    required double amount,
    required String bookingId,
    required void Function(PaymentGateway gateway) onGatewaySelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PaymentGatewaySheet(
        amount: amount,
        bookingId: bookingId,
        onGatewaySelected: onGatewaySelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Amount: ₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _GatewayTile(
            name: 'Razorpay',
            subtitle: 'UPI, Cards, Net Banking, Wallets',
            icon: Icons.payment_rounded,
            iconColor: AppColors.primary,
            onTap: () {
              Navigator.pop(context);
              onGatewaySelected(PaymentGateway.razorpay);
            },
          ),
          const SizedBox(height: 12),
          _GatewayTile(
            name: 'Cashfree',
            subtitle: 'UPI, Cards, Net Banking',
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppColors.tertiary,
            onTap: () {
              Navigator.pop(context);
              onGatewaySelected(PaymentGateway.cashfree);
            },
          ),
        ],
      ),
    );
  }
}

class _GatewayTile extends StatelessWidget {
  const _GatewayTile({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.12),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
