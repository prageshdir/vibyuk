import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/tourism/domain/entities/tourism_analytics_entity.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/tourism_analytics/tourism_analytics_cubit.dart';
import 'package:vibyuk/features/tourism/presentation/widgets/tourism_stat_card.dart';

class TourismAnalyticsScreen extends StatefulWidget {
  const TourismAnalyticsScreen({super.key});

  @override
  State<TourismAnalyticsScreen> createState() =>
      _TourismAnalyticsScreenState();
}

class _TourismAnalyticsScreenState extends State<TourismAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TourismAnalyticsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tourism Analytics',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<TourismAnalyticsCubit>().refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showDatePicker,
          ),
        ],
      ),
      body: BlocBuilder<TourismAnalyticsCubit, TourismAnalyticsState>(
        builder: (context, state) {
          if (state.status == TourismAnalyticsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == TourismAnalyticsStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.analytics_outlined,
                      size: 64, color: AppColors.outline),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Failed to load analytics'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        context.read<TourismAnalyticsCubit>().refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state.analytics == null) {
            return const Center(child: Text('No analytics data'));
          }
          return _buildAnalytics(context, state.analytics!);
        },
      ),
    );
  }

  Widget _buildAnalytics(
      BuildContext context, TourismAnalyticsEntity analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodHeader(context, analytics),
          const SizedBox(height: 20),
          _buildStatsGrid(context, analytics),
          const SizedBox(height: 24),
          _buildReachChart(context, analytics),
          const SizedBox(height: 24),
          _buildTopDestinations(context, analytics),
          const SizedBox(height: 24),
          _buildEngagementStats(context, analytics),
        ],
      ),
    );
  }

  Widget _buildPeriodHeader(
      BuildContext context, TourismAnalyticsEntity analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B5EFF), Color(0xFF7B2FFF)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analytics Period',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '${_formatDate(analytics.periodStart)} – ${_formatDate(analytics.periodEnd)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            analytics.formattedReach,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
      BuildContext context, TourismAnalyticsEntity analytics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        TourismStatCard(
          icon: Icons.place_outlined,
          value: '${analytics.totalDestinations}',
          label: 'Destinations',
          color: AppColors.primary,
        ),
        TourismStatCard(
          icon: Icons.campaign_outlined,
          value: '${analytics.totalCampaigns}',
          label: 'Total Campaigns',
          color: AppColors.secondary,
        ),
        TourismStatCard(
          icon: Icons.bolt_outlined,
          value: '${analytics.activeCampaigns}',
          label: 'Active Campaigns',
          color: AppColors.success,
        ),
        TourismStatCard(
          icon: Icons.people_outline,
          value: '${analytics.totalCreators}',
          label: 'Creators',
          color: AppColors.tertiary,
        ),
        TourismStatCard(
          icon: Icons.flight_takeoff,
          value: '${analytics.completedFamTrips}',
          label: 'FAM Trips Done',
          color: const Color(0xFF2B5EFF),
        ),
        TourismStatCard(
          icon: Icons.photo_library_outlined,
          value: '${analytics.contentPieces}',
          label: 'Content Pieces',
          color: AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildReachChart(
      BuildContext context, TourismAnalyticsEntity analytics) {
    if (analytics.reachByDay.isEmpty) return const SizedBox.shrink();

    final entries = analytics.reachByDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final maxY = entries
        .map((e) => e.value.toDouble())
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Reach',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                drawHorizontalLine: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppColors.outlineVariant,
                  strokeWidth: 0.8,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (entries.length / 5).ceil().toDouble(),
                    getTitlesWidget: (v, meta) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= entries.length) {
                        return const SizedBox.shrink();
                      }
                      final key = entries[idx].key;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          key.length >= 5 ? key.substring(5) : key,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (v, _) => Text(
                      v >= 1000000
                          ? '${(v / 1000000).toStringAsFixed(1)}M'
                          : v >= 1000
                              ? '${(v / 1000).toStringAsFixed(0)}K'
                              : v.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    entries.length,
                    (i) => FlSpot(i.toDouble(), entries[i].value.toDouble()),
                  ),
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopDestinations(
      BuildContext context, TourismAnalyticsEntity analytics) {
    if (analytics.topDestinations.isEmpty) return const SizedBox.shrink();

    final maxReach = analytics.topDestinations
        .map((d) => d.reach.toDouble())
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Destinations by Reach',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: analytics.topDestinations
                  .asMap()
                  .entries
                  .map((e) => BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.reach.toDouble(),
                            color: AppColors.primary,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ],
                      ))
                  .toList(),
              maxY: maxReach * 1.2,
              gridData:
                  const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx < 0 ||
                          idx >= analytics.topDestinations.length) {
                        return const SizedBox.shrink();
                      }
                      final name =
                          analytics.topDestinations[idx].destinationName;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          name.length > 8
                              ? '${name.substring(0, 7)}…'
                              : name,
                          style: const TextStyle(fontSize: 9),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (v, _) => Text(
                      v >= 1000000
                          ? '${(v / 1000000).toStringAsFixed(1)}M'
                          : v >= 1000
                              ? '${(v / 1000).toStringAsFixed(0)}K'
                              : v.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEngagementStats(
      BuildContext context, TourismAnalyticsEntity analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Overview',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _EngagementStat(
                  label: 'Avg Engagement',
                  value:
                      '${analytics.averageEngagementRate.toStringAsFixed(1)}%',
                  icon: Icons.favorite_outline,
                  color: AppColors.secondary,
                ),
              ),
              Expanded(
                child: _EngagementStat(
                  label: 'Content Pieces',
                  value: '${analytics.contentPieces}',
                  icon: Icons.photo_library_outlined,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (range != null && mounted) {
      context
          .read<TourismAnalyticsCubit>()
          .load(from: range.start, to: range.end);
    }
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _EngagementStat extends StatelessWidget {
  const _EngagementStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18),
            ),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
