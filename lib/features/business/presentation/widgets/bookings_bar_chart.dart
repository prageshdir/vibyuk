import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/business/domain/entities/booking_entity.dart';

class BookingsBarChart extends StatefulWidget {
  final Map<BookingStatus, int> bookingsByStatus;
  final double height;

  const BookingsBarChart({
    super.key,
    required this.bookingsByStatus,
    this.height = 200,
  });

  @override
  State<BookingsBarChart> createState() => _BookingsBarChartState();
}

class _BookingsBarChartState extends State<BookingsBarChart> {
  int? _touchedIndex;

  static const _statusColors = {
    BookingStatus.pending: AppColors.warning,
    BookingStatus.confirmed: AppColors.primary,
    BookingStatus.inProgress: AppColors.tertiary,
    BookingStatus.completed: AppColors.success,
    BookingStatus.cancelled: AppColors.error,
    BookingStatus.disputed: AppColors.secondary,
  };

  @override
  Widget build(BuildContext context) {
    final entries = widget.bookingsByStatus.entries
        .where((e) => e.value > 0)
        .toList();

    if (entries.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text('No booking data',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final maxY =
        entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    final barGroups = entries.asMap().entries.map((entry) {
      final index = entry.key;
      final status = entry.value.key;
      final count = entry.value.value;
      final isTouched = index == _touchedIndex;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: _statusColors[status] ?? AppColors.primary,
            width: isTouched ? 20 : 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY * 1.1,
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: widget.height,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          barGroups: barGroups,
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
                reservedSize: 28,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      entries[index].key.label,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
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
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, __) {
                final status = entries[group.x].key;
                return BarTooltipItem(
                  '${status.label}\n${rod.toY.toInt()} bookings',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
            touchCallback: (event, response) {
              setState(() {
                _touchedIndex =
                    response?.spot?.touchedBarGroupIndex;
              });
            },
          ),
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
