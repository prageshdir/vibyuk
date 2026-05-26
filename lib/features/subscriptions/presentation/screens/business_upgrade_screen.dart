import 'package:flutter/material.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_plan_features.dart';

class BusinessUpgradeScreen extends StatelessWidget {
  const BusinessUpgradeScreen({super.key, required this.currentPlan});

  final BusinessPlan currentPlan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Plans'),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                children: [
                  _BusinessHeader(currentPlan: currentPlan),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemCount: BusinessPlan.values.length,
              itemBuilder: (context, index) {
                final plan = BusinessPlan.values[index];
                return BusinessPlanCard(
                  plan: plan,
                  isCurrentPlan: plan == currentPlan,
                  onUpgrade: plan == currentPlan || !plan.isPaid
                      ? null
                      : () => _onUpgrade(context, plan),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  void _onUpgrade(BuildContext context, BusinessPlan plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upgrading to ${plan.displayName}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _BusinessHeader extends StatelessWidget {
  const _BusinessHeader({required this.currentPlan});
  final BusinessPlan currentPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.business_center_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          'Grow Your Business',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          currentPlan.isPaid
              ? 'You\'re on ${currentPlan.displayName}. Upgrade for more reach.'
              : 'Unlock more campaigns, lower commissions, and team features.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class BusinessPlanCard extends StatelessWidget {
  const BusinessPlanCard({
    super.key,
    required this.plan,
    required this.isCurrentPlan,
    required this.onUpgrade,
  });

  final BusinessPlan plan;
  final bool isCurrentPlan;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighlighted = plan == BusinessPlan.professional;
    final features = BusinessPlanFeatures.forPlan(plan);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlan
              ? theme.colorScheme.primary
              : isHighlighted
                  ? theme.colorScheme.primary.withOpacity(0.4)
                  : theme.colorScheme.outline.withOpacity(0.2),
          width: isCurrentPlan ? 2 : 1,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BusinessPlanHeader(
            plan: plan,
            isHighlighted: isHighlighted,
            isCurrentPlan: isCurrentPlan,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...features.displayFeatureList
                    .map((f) => _BusinessFeatureRow(label: f)),
                const SizedBox(height: 20),
                _BusinessActionButton(
                  plan: plan,
                  isCurrentPlan: isCurrentPlan,
                  onTap: onUpgrade,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessPlanHeader extends StatelessWidget {
  const _BusinessPlanHeader({
    required this.plan,
    required this.isHighlighted,
    required this.isCurrentPlan,
  });

  final BusinessPlan plan;
  final bool isHighlighted;
  final bool isCurrentPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnterprise = plan == BusinessPlan.enterprise;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: isEnterprise
            ? const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              )
            : isHighlighted
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  )
                : null,
        color: !isEnterprise && !isHighlighted
            ? theme.colorScheme.surfaceVariant.withOpacity(0.4)
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'MOST POPULAR',
                      style: TextStyle(
                        color: isHighlighted || isEnterprise
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
                    color: isHighlighted || isEnterprise ? Colors.white : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  plan.formattedPrice,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isHighlighted || isEnterprise
                        ? Colors.white.withOpacity(0.9)
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(plan.commissionRate * 100).toStringAsFixed(0)}% commission',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isHighlighted || isEnterprise
                        ? Colors.white.withOpacity(0.75)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentPlan)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: Colors.white.withOpacity(0.5)),
              ),
              child: Text(
                'Current',
                style: TextStyle(
                  color: isHighlighted || isEnterprise
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

class _BusinessFeatureRow extends StatelessWidget {
  const _BusinessFeatureRow({required this.label});
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

class _BusinessActionButton extends StatelessWidget {
  const _BusinessActionButton({
    required this.plan,
    required this.isCurrentPlan,
    required this.onTap,
  });

  final BusinessPlan plan;
  final bool isCurrentPlan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (isCurrentPlan) {
      return OutlinedButton(
        onPressed: null,
        child: const Text('Current Plan'),
      );
    }
    if (!plan.isPaid) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        style: plan == BusinessPlan.enterprise
            ? FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
              )
            : null,
        child: Text('Upgrade to ${plan.displayName}'),
      ),
    );
  }
}
