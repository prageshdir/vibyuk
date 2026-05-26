import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_earnings_entity.dart';

class CreatorEarningsChart extends StatelessWidget {
  const CreatorEarningsChart({
    super.key,
    required this.history,
    this.height = 200,
  });

  final List<EarningsPeriodEntity> history;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No earnings data')),
      );
    }

    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.amount);
    }).toList();

    final maxY = history.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Colors.grey.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (v, _) => Text(
                  '₹${v.toInt()}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= history.length) {
                    return const SizedBox.shrink();
                  }
                  final d = history[idx].periodStart;
                  return Text(
                    '${d.month}/${d.year % 100}',
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 2.5,
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        '₹${s.y.toStringAsFixed(0)}',
                        const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
