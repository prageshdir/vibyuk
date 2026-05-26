import 'package:flutter/material.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_budget_entity.dart';

class BudgetCategoryCard extends StatelessWidget {
  final String category;
  final List<WeddingBudgetItemEntity> items;
  final VoidCallback? onAddItem;

  const BudgetCategoryCard({
    super.key,
    required this.category,
    required this.items,
    this.onAddItem,
  });

  double get _totalEstimated =>
      items.fold(0.0, (sum, i) => sum + i.estimatedAmount);
  double get _totalActual =>
      items.fold(0.0, (sum, i) => sum + i.actualAmount);
  bool get _isOverBudget => _totalActual > _totalEstimated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _isOverBudget
              ? theme.colorScheme.error.withValues(alpha: 0.15)
              : theme.colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(
            _categoryIcon(category),
            size: 20,
            color: _isOverBudget
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
        ),
        title: Text(
          _categoryLabel(category),
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Est: ₹${_totalEstimated.toStringAsFixed(0)} · Actual: ₹${_totalActual.toStringAsFixed(0)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: _isOverBudget ? theme.colorScheme.error : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isOverBudget)
              Icon(Icons.warning_amber_rounded, size: 16, color: theme.colorScheme.error),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          ...items.map((item) => _BudgetItemTile(item: item)),
          if (onAddItem != null)
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add item'),
              onTap: onAddItem,
              dense: true,
            ),
        ],
      ),
    );
  }

  String _categoryLabel(String cat) =>
      cat.replaceAll('_', ' ').split(' ').map((w) {
        if (w.isEmpty) return w;
        return w[0].toUpperCase() + w.substring(1);
      }).join(' ');

  IconData _categoryIcon(String cat) => switch (cat) {
        'venue' => Icons.location_city,
        'catering' => Icons.restaurant,
        'photography' => Icons.camera_alt,
        'videography' => Icons.videocam,
        'flowers' => Icons.local_florist,
        'music' => Icons.music_note,
        'attire' => Icons.checkroom,
        'beauty' => Icons.face,
        'stationery' => Icons.article,
        'transport' => Icons.directions_car,
        'honeymoon' => Icons.flight,
        _ => Icons.category,
      };
}

class _BudgetItemTile extends StatelessWidget {
  final WeddingBudgetItemEntity item;
  const _BudgetItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(
            item.isPaid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: item.isPaid ? Colors.green : theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(item.description, style: theme.textTheme.bodySmall),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${item.actualAmount.toStringAsFixed(0)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: item.isOverBudget ? theme.colorScheme.error : null,
                ),
              ),
              Text(
                'est ₹${item.estimatedAmount.toStringAsFixed(0)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
