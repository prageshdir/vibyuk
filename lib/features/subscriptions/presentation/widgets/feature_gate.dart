import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_plan_features.dart';
import 'package:vibyuk/features/subscriptions/presentation/bloc/subscription_bloc.dart';

/// Conditionally renders [child] when the user's active plan includes [feature].
/// Falls back to [locked] or a default upgrade prompt when access is denied.
class FeatureGate extends StatelessWidget {
  const FeatureGate({
    super.key,
    required this.feature,
    required this.child,
    this.locked,
    this.requiredPlan = SubscriptionPlan.pro,
  });

  final SubscriptionFeature feature;
  final Widget child;

  /// Custom widget shown when access is denied.
  /// Defaults to [_UpgradePrompt] if null.
  final Widget? locked;

  /// Minimum plan required — used only for the default prompt label.
  final SubscriptionPlan requiredPlan;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      buildWhen: (prev, next) =>
          prev.runtimeType != next.runtimeType ||
          (next is SubscriptionLoaded && prev is SubscriptionLoaded
              ? prev.plan != next.plan
              : false),
      builder: (context, state) {
        final hasAccess = state is SubscriptionLoaded
            ? state.hasAccess(feature)
            : false;

        return hasAccess
            ? child
            : locked ?? _UpgradePrompt(requiredPlan: requiredPlan);
      },
    );
  }
}

/// Inline lock prompt that navigates to the upgrade screen.
class _UpgradePrompt extends StatelessWidget {
  const _UpgradePrompt({required this.requiredPlan});
  final SubscriptionPlan requiredPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 32,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            '${requiredPlan.displayName} Feature',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Upgrade to ${requiredPlan.displayName} to unlock this feature.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () =>
                Navigator.of(context).pushNamed('/subscription/upgrade'),
            child: Text('View ${requiredPlan.displayName} Plans'),
          ),
        ],
      ),
    );
  }
}

/// Overlay variant — wraps any widget with a semi-transparent lock layer.
class FeatureGateOverlay extends StatelessWidget {
  const FeatureGateOverlay({
    super.key,
    required this.feature,
    required this.child,
    this.requiredPlan = SubscriptionPlan.pro,
  });

  final SubscriptionFeature feature;
  final Widget child;
  final SubscriptionPlan requiredPlan;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      buildWhen: (prev, next) =>
          prev.runtimeType != next.runtimeType ||
          (next is SubscriptionLoaded && prev is SubscriptionLoaded
              ? prev.plan != next.plan
              : false),
      builder: (context, state) {
        final hasAccess = state is SubscriptionLoaded
            ? state.hasAccess(feature)
            : false;

        if (hasAccess) return child;

        return Stack(
          children: [
            IgnorePointer(child: Opacity(opacity: 0.3, child: child)),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () =>
                      Navigator.of(context).pushNamed('/subscription/upgrade'),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${requiredPlan.displayName} only',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
