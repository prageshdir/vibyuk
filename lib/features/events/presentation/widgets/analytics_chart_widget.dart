import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/features/events/domain/entities/event_analytics_entity.dart';

class AnalyticsChartWidget extends StatefulWidget {
  final EventAnalyticsEntity analytics;
  final String title;

  const AnalyticsChartWidget({
    super.key,
    required this.analytics,
    required this.title,
  });

  @override
  State<AnalyticsChartWidget> createState() => _AnalyticsChartWidgetState();
}

class _AnalyticsChartWidgetState extends State<AnalyticsChartWidget> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _TabButton(
              label: 'Revenue',
              selected: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0),
            ),
            const SizedBox(width: 8),
            _TabButton(
              label: 'Tickets',
              selected: _selectedTab == 1,
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: _selectedTab == 0
              ? _buildRevenueChart(context)
              : _buildTicketChart(context),
        ),
        const SizedBox(height: 12),
        _buildSummaryRow(context),
      ],
    );
  }

  Widget _buildRevenueChart(BuildContext context) {
    final spots = widget.analytics.dailySales
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.revenue))
        .toList();

    if (spots.isEmpty) {
      return const Center(child: Text('No revenue data yet'));
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '₹${s.y.toStringAsFixed(0)}',
                      const TextStyle(color: Colors.white),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketChart(BuildContext context) {
    final salesByType = widget.analytics.salesByType;
    if (salesByType.isEmpty) {
      return const Center(child: Text('No ticket data yet'));
    }

    final maxY = salesByType
        .map((s) => s.quantity.toDouble())
        .reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxY * 1.2,
        barGroups: salesByType.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.quantity.toDouble(),
                color: Theme.of(context).colorScheme.primary,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= salesByType.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    salesByType[index].name,
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context) {
    final revenue = NumberFormat.currency(symbol: '₹', decimalDigits: 0)
        .format(widget.analytics.totalRevenue);
    final occupancy =
        '${(widget.analytics.occupancyRate * 100).toStringAsFixed(0)}%';

    return Row(
      children: [
        _SummaryChip(label: 'Revenue', value: revenue),
        const SizedBox(width: 8),
        _SummaryChip(label: 'Occupancy', value: occupancy),
        const SizedBox(width: 8),
        _SummaryChip(
          label: 'Check-ins',
          value:
              '${(widget.analytics.checkInRate * 100).toStringAsFixed(0)}%',
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
