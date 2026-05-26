import 'package:flutter/material.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_plan_features.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.isCurrentPlan,
    required this.onSelect,
    this.isLoading = false,
  });

  final SubscriptionPlan plan;
  final bool isCurrentPlan;
  final VoidCallback? onSelect;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighlighted = plan == SubscriptionPlan.pro;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlan
              ? theme.colorScheme.primary
              : isHighlighted
                  ? theme.colorScheme.primary.withValues(alpha: 0.4)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: isCurrentPlan ? 2 : 1,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PlanHeader(plan: plan, isHighlighted: isHighlighted, isCurrentPlan: isCurrentPlan),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._features(plan).map((f) => _FeatureRow(label: f)),
                const SizedBox(height: 20),
                _ActionButton(
                  plan: plan,
                  isCurrentPlan: isCurrentPlan,
                  isLoading: isLoading,
                  onTap: onSelect,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _features(SubscriptionPlan plan) =>
      SubscriptionPlanFeatures.displayFeatures(plan)
          .map((f) => f.label)
          .toList();
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({
    required this.plan,
    required this.isHighlighted,
    required this.isCurrentPlan,
  });

  final SubscriptionPlan plan;
  final bool isHighlighted;
  final bool isCurrentPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isElite = plan == SubscriptionPlan.elite;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: isElite
            ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              )
            : isHighlighted
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  )
                : null,
        color: !isElite && !isHighlighted
            ? theme.colorScheme.surfaceVariant.withValues(alpha: 0.4)
            : null,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isHighlighted)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'MOST POPULAR',
                      style: TextStyle(
                        color: isHighlighted || isElite
                            ? Colors.white
                            : theme.colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                Text(
                  plan.displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isHighlighted || isElite ? Colors.white : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  plan.formattedPrice,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isHighlighted || isElite
                        ? Colors.white.withValues(alpha: 0.9)
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentPlan)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: Text(
                'Current',
                style: TextStyle(
                  color: isHighlighted || isElite
                      ? Colors.white
                      : theme.colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.plan,
    required this.isCurrentPlan,
    required this.isLoading,
    required this.onTap,
  });

  final SubscriptionPlan plan;
  final bool isCurrentPlan;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (isCurrentPlan) {
      return OutlinedButton(
        onPressed: null,
        child: const Text('Current Plan'),
      );
    }
    if (plan == SubscriptionPlan.free) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onTap,
        style: plan == SubscriptionPlan.elite
            ? FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
              )
            : null,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text('Upgrade to ${plan.displayName}'),
      ),
    );
  }
}
