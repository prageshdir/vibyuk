import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_analytics_entity.dart';
import 'package:vibyuk/features/creator/presentation/blocs/creator_analytics/creator_analytics_bloc.dart';

class CreatorAnalyticsScreen extends StatefulWidget {
  const CreatorAnalyticsScreen({super.key});

  @override
  State<CreatorAnalyticsScreen> createState() => _CreatorAnalyticsScreenState();
}

class _CreatorAnalyticsScreenState extends State<CreatorAnalyticsScreen> {
  String _period = 'last30days';

  @override
  void initState() {
    super.initState();
    context
        .read<CreatorAnalyticsBloc>()
        .add(LoadCreatorAnalyticsEvent(period: _period));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<CreatorAnalyticsBloc, CreatorAnalyticsState>(
        builder: (context, state) => switch (state) {
          CreatorAnalyticsLoadingState() =>
            const Center(child: AppLoader()),
          CreatorAnalyticsLoadedState(:final analytics) =>
            RefreshIndicator(
              onRefresh: () async => context
                  .read<CreatorAnalyticsBloc>()
                  .add(LoadCreatorAnalyticsEvent(period: _period)),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Period selector
                  Wrap(
                    spacing: 8,
                    children: ['last7days', 'last30days', 'last90days', 'alltime']
                        .map((p) => ChoiceChip(
                              label: Text(_periodLabel(p)),
                              selected: _period == p,
                              onSelected: (v) {
                                if (v) {
                                  setState(() => _period = p);
                                  context.read<CreatorAnalyticsBloc>().add(
                                        ChangePeriodEvent(period: p),
                                      );
                                }
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // KPI grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _KpiTile(
                          label: 'Profile Views',
                          value: '${analytics.profileViews}',
                          change: analytics.profileViewsChange,
                          icon: Icons.visibility_outlined),
                      _KpiTile(
                          label: 'Booking Requests',
                          value: '${analytics.bookingRequests}',
                          change: analytics.bookingRequestsChange,
                          icon: Icons.inbox_outlined),
                      _KpiTile(
                          label: 'Acceptance Rate',
                          value:
                              '${analytics.acceptanceRate.toStringAsFixed(0)}%',
                          changeDouble: analytics.acceptanceRateChange,
                          icon: Icons.check_circle_outline_rounded),
                      _KpiTile(
                          label: 'Avg Rating',
                          value:
                              analytics.averageRating.toStringAsFixed(1),
                          icon: Icons.star_rounded,
                          iconColor: Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Views chart
                  Text('Profile Views',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _ViewsLineChart(data: analytics.viewsOverTime),
                  const SizedBox(height: 24),

                  // Traffic sources
                  if (analytics.trafficSources.isNotEmpty) ...[
                    Text('Traffic Sources',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ...analytics.trafficSources.map((s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 100,
                                  child: Text(s.source,
                                      style: theme.textTheme.bodySmall)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: s.percentage / 100,
                                    minHeight: 8,
                                    backgroundColor: theme
                                        .colorScheme.surfaceContainerHighest,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  '${s.percentage.toStringAsFixed(0)}%',
                                  style: theme.textTheme.labelSmall),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          CreatorAnalyticsErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bar_chart_outlined,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<CreatorAnalyticsBloc>()
                        .add(LoadCreatorAnalyticsEvent(period: _period)),
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

  String _periodLabel(String p) {
    return switch (p) {
      'last7days' => '7 days',
      'last30days' => '30 days',
      'last90days' => '90 days',
      _ => 'All time',
    };
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
    this.change,
    this.changeDouble,
    this.iconColor,
  });
  final String label;
  final String value;
  final IconData icon;
  final int? change;
  final double? changeDouble;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = (change ?? 0) >= 0 || (changeDouble ?? 0) >= 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
              const Spacer(),
              if (change != null || changeDouble != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 12,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    Text(
                      change != null
                          ? '${change!.abs()}'
                          : '${changeDouble!.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                          fontSize: 11,
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
            ],
          ),
          Text(value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ViewsLineChart extends StatelessWidget {
  const _ViewsLineChart({required this.data});
  final List<AnalyticsDataPointEntity> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
          height: 150,
          child: Center(child: Text('No data available')));
    }
    final spots = data.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();
    final maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            leftTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 2,
              belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withOpacity(0.08)),
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
