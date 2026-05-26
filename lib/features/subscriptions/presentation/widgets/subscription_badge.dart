import 'package:flutter/material.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';

class SubscriptionBadge extends StatelessWidget {
  const SubscriptionBadge({
    super.key,
    required this.plan,
    this.compact = false,
  });

  final SubscriptionPlan plan;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (plan == SubscriptionPlan.free) return const SizedBox.shrink();

    final isElite = plan == SubscriptionPlan.elite;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isElite
              ? const [Color(0xFFFFD700), Color(0xFFFFA500)]
              : const [Color(0xFF7B2FFF), Color(0xFF5B0FDF)],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        plan.displayName.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 9 : 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
