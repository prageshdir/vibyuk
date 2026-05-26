import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BudgetPieChart extends StatefulWidget {
  final Map<String, double> budgetByCategory;
  final double totalBudget;

  const BudgetPieChart({
    super.key,
    required this.budgetByCategory,
    required this.totalBudget,
  });

  @override
  State<BudgetPieChart> createState() => _BudgetPieChartState();
}

class _BudgetPieChartState extends State<BudgetPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = widget.budgetByCategory.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No budget data yet')),
      );
    }

    final colors = _generateColors(entries.length, theme);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    _touchedIndex = response?.touchedSection?.touchedSectionIndex ?? -1;
                  });
                },
              ),
              sections: entries.asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                final isTouched = i == _touchedIndex;
                final pct = widget.totalBudget > 0
                    ? (e.value / widget.totalBudget * 100)
                    : 0.0;
                return PieChartSectionData(
                  value: e.value,
                  color: colors[i],
                  radius: isTouched ? 70 : 60,
                  title: isTouched ? '${pct.toStringAsFixed(0)}%' : '',
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: entries.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors[i],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatCategory(e.key)}: ₹${e.value.toStringAsFixed(0)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatCategory(String cat) =>
      cat.replaceAll('_', ' ').split(' ').map((w) {
        if (w.isEmpty) return w;
        return w[0].toUpperCase() + w.substring(1);
      }).join(' ');

  List<Color> _generateColors(int count, ThemeData theme) {
    const palette = [
      Color(0xFF6C5CE7),
      Color(0xFF00B894),
      Color(0xFFE17055),
      Color(0xFF0984E3),
      Color(0xFFFDAB27),
      Color(0xFFE84393),
      Color(0xFF00CEC9),
      Color(0xFF636E72),
    ];
    return List.generate(count, (i) => palette[i % palette.length]);
  }
}
