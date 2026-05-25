import 'package:flutter/material.dart';

class CapacityBarWidget extends StatelessWidget {
  final int sold;
  final int total;
  final bool compact;

  const CapacityBarWidget({
    super.key,
    required this.sold,
    required this.total,
    this.compact = false,
  });

  double get _ratio => total > 0 ? (sold / total).clamp(0.0, 1.0) : 0.0;

  Color _barColor(BuildContext context) {
    if (_ratio >= 0.8) return Colors.red.shade400;
    if (_ratio >= 0.5) return Colors.orange.shade400;
    return Colors.green.shade400;
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return SizedBox(
        width: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _ratio,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(_barColor(context)),
            minHeight: 6,
          ),
        ),
      );
    }

    final remaining = total - sold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Capacity',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              '$sold / $total',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _ratio,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(_barColor(context)),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          remaining > 0 ? '$remaining remaining' : 'Sold out',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
