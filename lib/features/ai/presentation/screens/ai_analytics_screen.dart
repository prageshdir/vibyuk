import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_analytics.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_analytics/ai_analytics_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_analytics/ai_analytics_event.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_analytics/ai_analytics_state.dart';
import 'package:vibyuk/features/ai/presentation/widgets/charts/ai_analytics_chart.dart';
import 'package:vibyuk/features/ai/presentation/widgets/charts/ai_performance_gauge.dart';
import 'package:vibyuk/features/ai/presentation/widgets/common/ai_gradient_header.dart';
import 'package:vibyuk/features/ai/presentation/widgets/common/ai_loading_shimmer.dart';

class AiAnalyticsScreen extends StatefulWidget {
  const AiAnalyticsScreen({super.key});

  @override
  State<AiAnalyticsScreen> createState() => _AiAnalyticsScreenState();
}

class _AiAnalyticsScreenState extends State<AiAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<AiAnalyticsBloc>()
        .add(const LoadAnalytics());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AiAnalyticsBloc>().add(const RefreshAnalytics());
        },
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AiGradientHeader(
                title: 'AI Analytics',
                subtitle: 'Real-time intelligent business insights',
              ),
            ),
            SliverToBoxAdapter(
              child: _PeriodSelector(),
            ),
            BlocBuilder<AiAnalyticsBloc, AiAnalyticsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const SliverToBoxAdapter(
                    child: AiLoadingShimmer(cardCount: 4, cardHeight: 150),
                  );
                }

                if (!state.hasData) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.analytics_outlined,
                              size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          const Text('No analytics data'),
                          if (state.hasError)
                            Text(
                              state.failure?.message ?? '',
                              style: const TextStyle(color: AppColors.error),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                final data = state.analytics!;

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // KPI cards row
                      _KpiRow(analytics: data),
                      const SizedBox(height: 20),

                      // Revenue chart
                      _ChartCard(
                        title: 'Revenue Trend',
                        subtitle:
                            '${data.revenueGrowthRate >= 0 ? '+' : ''}${data.revenueGrowthRate.toStringAsFixed(1)}% vs previous period',
                        subtitleColor: data.revenueTrend == MetricTrend.up
                            ? AppColors.success
                            : AppColors.error,
                        child: AiAnalyticsChart(
                          dataPoints: data.revenueTimeline,
                          lineColor: AppColors.primary,
                          label: 'Revenue',
                          unit: '₹',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Bookings chart
                      _ChartCard(
                        title: 'Bookings Trend',
                        subtitle:
                            '${data.bookingsGrowthRate >= 0 ? '+' : ''}${data.bookingsGrowthRate.toStringAsFixed(1)}% growth',
                        subtitleColor: data.bookingsTrend == MetricTrend.up
                            ? AppColors.success
                            : AppColors.error,
                        child: AiAnalyticsChart(
                          dataPoints: data.bookingsTimeline,
                          lineColor: AppColors.tertiary,
                          label: 'Bookings',
                          unit: '',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Gauges row
                      _GaugesRow(analytics: data),
                      const SizedBox(height: 20),

                      // Revenue by category
                      _CategoryBreakdown(analytics: data),
                      const SizedBox(height: 20),

                      // Top creators
                      _TopCreatorsSection(analytics: data),
                      const SizedBox(height: 24),
                    ]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final periods = AnalyticsPeriod.values;
    final periodLabels = {
      AnalyticsPeriod.last7Days: '7 Days',
      AnalyticsPeriod.last30Days: '30 Days',
      AnalyticsPeriod.last90Days: '90 Days',
      AnalyticsPeriod.last12Months: '12 Months',
    };

    return BlocBuilder<AiAnalyticsBloc, AiAnalyticsState>(
      builder: (context, state) {
        return Container(
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: periods.map((period) {
              final isSelected = state.selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => context
                      .read<AiAnalyticsBloc>()
                      .add(ChangePeriod(period: period)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: AppColors.brandGradient,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      periodLabels[period] ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _KpiRow extends StatelessWidget {
  final AiAnalytics analytics;

  const _KpiRow({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: 'Revenue',
            value: '₹${_formatNumber(analytics.totalRevenue)}',
            trend: analytics.revenueTrend,
            changePercent: analytics.revenueGrowthRate,
            color: AppColors.primary,
            icon: Icons.payments_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            label: 'Bookings',
            value: analytics.totalBookings.toString(),
            trend: analytics.bookingsTrend,
            changePercent: analytics.bookingsGrowthRate,
            color: AppColors.tertiary,
            icon: Icons.calendar_today_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            label: 'Avg Value',
            value: '₹${analytics.avgBookingValue.toStringAsFixed(0)}',
            trend: MetricTrend.stable,
            changePercent: 0,
            color: AppColors.secondary,
            icon: Icons.trending_up_rounded,
          ),
        ),
      ],
    );
  }

  String _formatNumber(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final MetricTrend trend;
  final double changePercent;
  final Color color;
  final IconData icon;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.changePercent,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = trend == MetricTrend.up
        ? AppColors.success
        : trend == MetricTrend.down
            ? AppColors.error
            : AppColors.textSecondary;
    final trendIcon = trend == MetricTrend.up
        ? Icons.arrow_upward_rounded
        : trend == MetricTrend.down
            ? Icons.arrow_downward_rounded
            : Icons.remove_rounded;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).cardColor,
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          if (changePercent != 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(trendIcon, size: 10, color: trendColor),
                Text(
                  '${changePercent.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: trendColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    this.subtitleColor = AppColors.textSecondary,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
        border: Border.all(color: AppColors.outline.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: subtitleColor),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _GaugesRow extends StatelessWidget {
  final AiAnalytics analytics;

  const _GaugesRow({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
        border: Border.all(color: AppColors.outline.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Gauges',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AiPerformanceGauge(
                value: analytics.conversionRate,
                maxValue: 100,
                label: '${analytics.conversionRate.toStringAsFixed(0)}%',
                sublabel: 'Conversion',
                color: AppColors.primary,
              ),
              AiPerformanceGauge(
                value: analytics.clientRetentionRate,
                maxValue: 100,
                label: '${analytics.clientRetentionRate.toStringAsFixed(0)}%',
                sublabel: 'Retention',
                color: AppColors.tertiary,
              ),
              AiPerformanceGauge(
                value: analytics.projectedRevenue,
                maxValue: analytics.totalRevenue * 1.5,
                label: '₹${_fmt(analytics.projectedRevenue)}',
                sublabel: 'Projected',
                color: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toStringAsFixed(0);
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final AiAnalytics analytics;

  const _CategoryBreakdown({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.warning,
      AppColors.success,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
        border: Border.all(color: AppColors.outline.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue by Category',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 14),
          ...analytics.revenueByCategory.asMap().entries.map((e) {
            final color = colors[e.key % colors.length];
            final cat = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cat.category,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: cat.percentage / 100,
                        minHeight: 6,
                        backgroundColor: color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${cat.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TopCreatorsSection extends StatelessWidget {
  final AiAnalytics analytics;

  const _TopCreatorsSection({required this.analytics});

  @override
  Widget build(BuildContext context) {
    if (analytics.topCreators.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
        border: Border.all(color: AppColors.outline.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performers',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...analytics.topCreators.asMap().entries.map((e) {
            final rank = e.key + 1;
            final creator = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: rank <= 3
                          ? LinearGradient(
                              colors: rank == 1
                                  ? [const Color(0xFFFFAB00), const Color(0xFFFF6F00)]
                                  : rank == 2
                                      ? [AppColors.outline, AppColors.textSecondary]
                                      : [const Color(0xFFCD7F32), const Color(0xFF8D4E2A)],
                            )
                          : null,
                      color: rank > 3 ? AppColors.surfaceVariant : null,
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: rank <= 3
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          creator.creatorName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${creator.bookings} bookings',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${creator.revenue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
