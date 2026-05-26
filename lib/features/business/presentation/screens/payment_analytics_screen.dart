import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/di/injection_container.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/business/domain/entities/payment_analytics_entity.dart';
import 'package:vibyuk/features/business/presentation/blocs/payment_analytics/payment_analytics_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/kpi_card.dart';

class PaymentAnalyticsScreen extends StatelessWidget {
  const PaymentAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PaymentAnalyticsBloc>()
        ..add(const LoadPaymentAnalyticsEvent()),
      child: const _PaymentAnalyticsView(),
    );
  }
}

class _PaymentAnalyticsView extends StatefulWidget {
  const _PaymentAnalyticsView();

  @override
  State<_PaymentAnalyticsView> createState() => _PaymentAnalyticsViewState();
}

class _PaymentAnalyticsViewState extends State<_PaymentAnalyticsView> {
  static const _periods = [
    ('7 days', '7d'),
    ('30 days', '30d'),
    ('90 days', '90d'),
    ('Year', '1y'),
  ];
  String _selected = '30d';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Analytics',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface,
      ),
      body: BlocBuilder<PaymentAnalyticsBloc, PaymentAnalyticsState>(
        builder: (context, state) {
          if (state is PaymentAnalyticsLoadingState) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is PaymentAnalyticsErrorState) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: 12),
                  Text(state.failure.message,
                      style:
                          const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context
                        .read<PaymentAnalyticsBloc>()
                        .add(LoadPaymentAnalyticsEvent(period: _selected)),
                    style:
                        FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is PaymentAnalyticsLoadedState) {
            return _AnalyticsBody(
              analytics: state.analytics,
              selectedPeriod: _selected,
              periods: _periods,
              onPeriodChanged: (p) {
                setState(() => _selected = p);
                context
                    .read<PaymentAnalyticsBloc>()
                    .add(ChangePeriodPaymentAnalyticsEvent(p));
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({
    required this.analytics,
    required this.selectedPeriod,
    required this.periods,
    required this.onPeriodChanged,
  });

  final PaymentAnalyticsEntity analytics;
  final String selectedPeriod;
  final List<(String, String)> periods;
  final void Function(String) onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => context
          .read<PaymentAnalyticsBloc>()
          .add(LoadPaymentAnalyticsEvent(period: selectedPeriod)),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: periods
                    .map((p) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(p.$1),
                            selected: selectedPeriod == p.$2,
                            onSelected: (_) => onPeriodChanged(p.$2),
                            selectedColor: AppColors.primaryContainer,
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: selectedPeriod == p.$2
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // KPI grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                KpiCard(
                  title: 'Total Collected',
                  value: analytics.totalAmountDisplay,
                  icon: Icons.currency_rupee_rounded,
                  iconColor: AppColors.primary,
                  iconBgColor: AppColors.primaryContainer,
                ),
                KpiCard(
                  title: 'Success Rate',
                  value: analytics.successRateDisplay,
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: AppColors.success,
                  iconBgColor: AppColors.successContainer,
                ),
                KpiCard(
                  title: 'Avg Transaction',
                  value: analytics.avgTransactionDisplay,
                  icon: Icons.receipt_rounded,
                  iconColor: AppColors.tertiary,
                  iconBgColor: AppColors.tertiaryContainer,
                ),
                KpiCard(
                  title: 'Refunded',
                  value: '₹${analytics.totalRefunded.toStringAsFixed(0)}',
                  icon: Icons.undo_rounded,
                  iconColor: AppColors.secondary,
                  iconBgColor: AppColors.secondaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Payment counts row
            _SectionTitle('Payment Summary'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _StatTile(
                  label: 'Total',
                  value: '${analytics.totalPayments}',
                  color: AppColors.primary,
                )),
                Expanded(
                    child: _StatTile(
                  label: 'Success',
                  value: '${analytics.successfulPayments}',
                  color: AppColors.success,
                )),
                Expanded(
                    child: _StatTile(
                  label: 'Failed',
                  value: '${analytics.failedPayments}',
                  color: AppColors.error,
                )),
                Expanded(
                    child: _StatTile(
                  label: 'Refunded',
                  value: '${analytics.refundedPayments}',
                  color: AppColors.warning,
                )),
              ],
            ),
            const SizedBox(height: 24),

            // Escrow section
            _SectionTitle('Escrow Overview'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _EscrowCard(
                    label: 'Held',
                    amount: analytics.escrowHeldAmount,
                    color: AppColors.warning,
                    icon: Icons.lock_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _EscrowCard(
                    label: 'Released',
                    amount: analytics.escrowReleasedAmount,
                    color: AppColors.success,
                    icon: Icons.lock_open_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Monthly trend
            if (analytics.monthlyTrend.isNotEmpty) ...[
              _SectionTitle('Monthly Trend'),
              const SizedBox(height: 12),
              _TrendChart(points: analytics.monthlyTrend),
              const SizedBox(height: 24),
            ],

            // Gateway breakdown
            if (analytics.gatewayBreakdown.isNotEmpty) ...[
              _SectionTitle('Gateway Breakdown'),
              const SizedBox(height: 12),
              ...analytics.gatewayBreakdown.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _GatewayRow(gateway: e.key, count: e.value,
                      total: analytics.totalPayments),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.textPrimary));
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _EscrowCard extends StatelessWidget {
  const _EscrowCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              Text('₹${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.points});
  final List<PaymentTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    final maxAmount = points.map((p) => p.amount).reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points.map((p) {
                final ratio = maxAmount > 0 ? p.amount / maxAmount : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 90 * ratio + 4,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.label,
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GatewayRow extends StatelessWidget {
  const _GatewayRow({required this.gateway, required this.count, required this.total});
  final String gateway;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(gateway.toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            Text('$count (${(pct * 100).toStringAsFixed(0)}%)',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.surfaceVariant,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
