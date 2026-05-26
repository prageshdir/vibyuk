import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/features/subscriptions/data/services/subscription_payment_service.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:vibyuk/features/subscriptions/presentation/bloc/subscription_bloc.dart';
import 'package:vibyuk/features/subscriptions/presentation/widgets/plan_card.dart';

class SubscriptionUpgradeScreen extends StatefulWidget {
  const SubscriptionUpgradeScreen({super.key});

  @override
  State<SubscriptionUpgradeScreen> createState() =>
      _SubscriptionUpgradeScreenState();
}

class _SubscriptionUpgradeScreenState
    extends State<SubscriptionUpgradeScreen> {
  final _paymentService = SubscriptionPaymentService();
  SubscriptionPlan? _tappedPlan;

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: _handleStateChange,
      builder: (context, state) {
        final currentPlan = switch (state) {
          SubscriptionLoaded(:final subscription) => subscription.plan,
          SubscriptionActivated(:final subscription) => subscription.plan,
          _ => SubscriptionPlan.free,
        };
        final isLoading = state is SubscriptionUpgrading ||
            state is SubscriptionVerifying;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Choose Your Plan'),
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
                      _Header(currentPlan: currentPlan),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemCount: SubscriptionPlan.values.length,
                  itemBuilder: (context, index) {
                    final plan = SubscriptionPlan.values[index];
                    return PlanCard(
                      plan: plan,
                      isCurrentPlan: plan == currentPlan,
                      isLoading:
                          isLoading && _tappedPlan == plan,
                      onSelect: plan == currentPlan || plan == SubscriptionPlan.free
                          ? null
                          : () => _onPlanSelected(context, plan),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }

  void _onPlanSelected(BuildContext context, SubscriptionPlan plan) {
    setState(() => _tappedPlan = plan);
    context
        .read<SubscriptionBloc>()
        .add(InitiateUpgradeEvent(plan: plan));
  }

  Future<void> _handleStateChange(
    BuildContext context,
    SubscriptionState state,
  ) async {
    if (state is SubscriptionPaymentReady) {
      final previousSub = _previousSubscription(context);
      final result = await _paymentService.launch(state.order);
      if (!mounted) return;

      if (result.success) {
        context.read<SubscriptionBloc>().add(
              VerifyPaymentEvent(
                paymentId: result.paymentId!,
                razorpayOrderId: result.razorpayOrderId!,
                signature: result.signature!,
                plan: state.order.plan,
              ),
            );
      } else {
        context.read<SubscriptionBloc>().add(
              PaymentCancelledEvent(previousSubscription: previousSub),
            );
        if (result.errorMessage != null &&
            result.errorMessage != 'Payment cancelled') {
          _showError(context, result.errorMessage!);
        }
      }
      setState(() => _tappedPlan = null);
    }

    if (state is SubscriptionActivated) {
      _showSuccess(context, state.subscription.plan);
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.of(context).pop();
    }

    if (state is SubscriptionError) {
      setState(() => _tappedPlan = null);
      _showError(context, state.message);
    }
  }

  SubscriptionEntity? _previousSubscription(BuildContext context) {
    final s = context.read<SubscriptionBloc>().state;
    return s is SubscriptionLoaded ? s.subscription : null;
  }

  void _showSuccess(BuildContext context, SubscriptionPlan plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome to ${plan.displayName}! 🎉'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.currentPlan});
  final SubscriptionPlan currentPlan;

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
                theme.colorScheme.primary.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          'Unlock Your Potential',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          currentPlan.isPaid
              ? 'You\'re on ${currentPlan.displayName}. Upgrade for more.'
              : 'Get more bookings with a Pro or Elite plan.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
