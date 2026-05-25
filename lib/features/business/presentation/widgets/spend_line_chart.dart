import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/business/domain/entities/analytics_entity.dart';

class SpendLineChart extends StatefulWidget {
  final List<ChartPoint> points;
  final double height;

  const SpendLineChart({
    super.key,
    required this.points,
    this.height = 200,
  });

  @override
  State<SpendLineChart> createState() => _SpendLineChartState();
}

class _SpendLineChartState extends State<SpendLineChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text('No data available',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final maxY = widget.points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final minY = widget.points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final yPadding = (maxY - minY) * 0.15 + 1;

    final spots = widget.points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    return SizedBox(
      height: widget.height,
      child: LineChart(
        LineChartData(
          minY: (minY - yPadding).clamp(0, double.infinity),
          maxY: maxY + yPadding,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY / 4).clamp(1, double.infinity),
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.outlineVariant,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, _) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    '£${value.toInt()}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: (widget.points.length / 5).ceilToDouble(),
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= widget.points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.points[index].label,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((spot) {
                return LineTooltipItem(
                  '£${spot.y.toStringAsFixed(0)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
            touchCallback: (event, response) {
              setState(() {
                _touchedIndex =
                    response?.lineBarSpots?.first.spotIndex;
              });
            },
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.primary,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  final isTouched = index == _touchedIndex;
                  return FlDotCirclePainter(
                    radius: isTouched ? 5 : 3,
                    color: AppColors.primary,
                    strokeWidth: isTouched ? 2 : 0,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
