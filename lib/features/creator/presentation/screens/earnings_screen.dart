import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_earnings_entity.dart';
import 'package:vibyuk/features/creator/presentation/blocs/earnings/earnings_bloc.dart';
import 'package:vibyuk/features/creator/presentation/widgets/creator_earnings_chart.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _period = 'last30days';

  @override
  void initState() {
    super.initState();
    context
        .read<EarningsBloc>()
        .add(LoadEarningsEvent(period: _period));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<EarningsBloc, EarningsState>(
        builder: (context, state) => switch (state) {
          EarningsLoadingState() => const Center(child: AppLoader()),
          EarningsLoadedState(:final earnings) => RefreshIndicator(
              onRefresh: () async => context
                  .read<EarningsBloc>()
                  .add(LoadEarningsEvent(period: _period)),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.7)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Available Balance',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          '£${earnings.availableBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _EarningsStat(
                                label: 'Pending',
                                value:
                                    '£${earnings.pendingPayout.toStringAsFixed(0)}'),
                            const SizedBox(width: 24),
                            _EarningsStat(
                                label: 'Lifetime',
                                value:
                                    '£${earnings.lifetimeEarnings.toStringAsFixed(0)}'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: earnings.availableBalance > 0
                                ? () => _showPayoutDialog(context, earnings)
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                            ),
                            child: const Text('Request Payout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Period selector
                  Wrap(
                    spacing: 8,
                    children: ['last30days', 'last90days', 'alltime']
                        .map((p) => ChoiceChip(
                              label: Text(_periodLabel(p)),
                              selected: _period == p,
                              onSelected: (v) {
                                if (v) {
                                  setState(() => _period = p);
                                  context.read<EarningsBloc>().add(
                                        ChangePeriodEvent(period: p),
                                      );
                                }
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Chart
                  Text('Earnings History',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CreatorEarningsChart(
                          history: earnings.earningsHistory),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent payouts
                  if (earnings.recentPayouts.isNotEmpty) ...[
                    Text('Recent Payouts',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ...earnings.recentPayouts
                        .map((p) => _PayoutTile(payout: p)),
                  ],
                ],
              ),
            ),
          EarningsErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.currency_pound_rounded,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<EarningsBloc>()
                        .add(LoadEarningsEvent(period: _period)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  void _showPayoutDialog(BuildContext context, CreatorEarningsEntity earnings) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Request Payout'),
        content: Text(
            'Request payout of £${earnings.availableBalance.toStringAsFixed(2)} to your registered bank account?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<EarningsBloc>().add(
                    RequestPayoutEvent(amount: earnings.availableBalance),
                  );
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  String _periodLabel(String p) => switch (p) {
        'last30days' => '30 days',
        'last90days' => '90 days',
        _ => 'All time',
      };
}

class _EarningsStat extends StatelessWidget {
  const _EarningsStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
      ],
    );
  }
}

class _PayoutTile extends StatelessWidget {
  const _PayoutTile({required this.payout});
  final PayoutEntity payout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (payout.status) {
      PayoutStatus.completed => Colors.green,
      PayoutStatus.processing => Colors.blue,
      PayoutStatus.pending => Colors.orange,
      PayoutStatus.failed => Colors.red,
    };
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: statusColor.withOpacity(0.12),
        child: Icon(Icons.currency_pound_rounded, color: statusColor),
      ),
      title: Text('£${payout.amount.toStringAsFixed(2)}',
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700)),
      subtitle: Text(
          '${payout.requestedAt.day}/${payout.requestedAt.month}/${payout.requestedAt.year}'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(payout.status.name,
            style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
