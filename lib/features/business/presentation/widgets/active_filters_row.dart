import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/business/domain/entities/search_filters_entity.dart';

class ActiveFiltersRow extends StatelessWidget {
  final SearchFiltersEntity filters;
  final VoidCallback onClearAll;
  final ValueChanged<SearchFiltersEntity> onFilterRemoved;

  const ActiveFiltersRow({
    super.key,
    required this.filters,
    required this.onClearAll,
    required this.onFilterRemoved,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();

    final chips = _buildChips();
    if (chips.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ...chips,
          const SizedBox(width: 8),
          ActionChip(
            label: const Text('Clear all'),
            onPressed: onClearAll,
            backgroundColor: AppColors.errorContainer,
            labelStyle: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChips() {
    final chips = <Widget>[];

    for (final category in filters.categories) {
      chips.add(_FilterChip(
        label: category,
        onRemove: () => onFilterRemoved(
          SearchFiltersEntity(
            categories:
                filters.categories.where((c) => c != category).toList(),
            minRate: filters.minRate,
            maxRate: filters.maxRate,
            location: filters.location,
            minRating: filters.minRating,
            isVerifiedOnly: filters.isVerifiedOnly,
            sortBy: filters.sortBy,
            availability: filters.availability,
          ),
        ),
      ));
    }

    if (filters.minRating != null) {
      chips.add(_FilterChip(
        label: '${filters.minRating!.toStringAsFixed(1)}+ stars',
        onRemove: () => onFilterRemoved(
          SearchFiltersEntity(
            categories: filters.categories,
            minRate: filters.minRate,
            maxRate: filters.maxRate,
            location: filters.location,
            isVerifiedOnly: filters.isVerifiedOnly,
            sortBy: filters.sortBy,
            availability: filters.availability,
          ),
        ),
      ));
    }

    if (filters.minRate != null || filters.maxRate != null) {
      final label = filters.minRate != null && filters.maxRate != null
          ? '₹${filters.minRate!.toInt()}–₹${filters.maxRate!.toInt()}/hr'
          : filters.minRate != null
              ? '₹${filters.minRate!.toInt()}+/hr'
              : 'Up to ₹${filters.maxRate!.toInt()}/hr';
      chips.add(_FilterChip(
        label: label,
        onRemove: () => onFilterRemoved(
          SearchFiltersEntity(
            categories: filters.categories,
            location: filters.location,
            minRating: filters.minRating,
            isVerifiedOnly: filters.isVerifiedOnly,
            sortBy: filters.sortBy,
            availability: filters.availability,
          ),
        ),
      ));
    }

    if (filters.location != null) {
      chips.add(_FilterChip(
        label: filters.location!,
        onRemove: () => onFilterRemoved(
          SearchFiltersEntity(
            categories: filters.categories,
            minRate: filters.minRate,
            maxRate: filters.maxRate,
            minRating: filters.minRating,
            isVerifiedOnly: filters.isVerifiedOnly,
            sortBy: filters.sortBy,
            availability: filters.availability,
          ),
        ),
      ));
    }

    if (filters.isVerifiedOnly) {
      chips.add(_FilterChip(
        label: 'Verified only',
        onRemove: () => onFilterRemoved(
          SearchFiltersEntity(
            categories: filters.categories,
            minRate: filters.minRate,
            maxRate: filters.maxRate,
            location: filters.location,
            minRating: filters.minRating,
            sortBy: filters.sortBy,
            availability: filters.availability,
          ),
        ),
      ));
    }

    if (filters.sortBy != SortBy.relevant) {
      chips.add(_FilterChip(
        label: filters.sortBy.label,
        onRemove: () => onFilterRemoved(
          SearchFiltersEntity(
            categories: filters.categories,
            minRate: filters.minRate,
            maxRate: filters.maxRate,
            location: filters.location,
            minRating: filters.minRating,
            isVerifiedOnly: filters.isVerifiedOnly,
            availability: filters.availability,
          ),
        ),
        color: AppColors.tertiaryContainer,
        textColor: AppColors.onTertiaryContainer,
      ));
    }

    return chips;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  final Color? color;
  final Color? textColor;

  const _FilterChip({
    required this.label,
    required this.onRemove,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close_rounded, size: 14),
        onDeleted: onRemove,
        backgroundColor: color ?? AppColors.primaryContainer,
        labelStyle: TextStyle(
          color: textColor ?? AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        deleteIconColor: textColor ?? AppColors.primary,
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
