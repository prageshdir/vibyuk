import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/features/business/domain/entities/search_filters_entity.dart';

class FilterBottomSheet extends StatefulWidget {
  final SearchFiltersEntity initialFilters;
  final ValueChanged<SearchFiltersEntity> onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required SearchFiltersEntity initialFilters,
    required ValueChanged<SearchFiltersEntity> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        initialFilters: initialFilters,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<String> _selectedCategories;
  late double _minRating;
  late RangeValues _priceRange;
  late bool _verifiedOnly;
  late SortBy _sortBy;
  late String? _location;

  static const _allCategories = [
    'Photography', 'Videography', 'Influencer', 'Music',
    'Fitness', 'Beauty', 'Tech', 'Food', 'Travel', 'Lifestyle',
    'Fashion', 'Gaming', 'Sports', 'Comedy',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.initialFilters.categories);
    _minRating = widget.initialFilters.minRating ?? 0.0;
    _priceRange = RangeValues(
      widget.initialFilters.minRate ?? 0,
      widget.initialFilters.maxRate ?? 1000,
    );
    _verifiedOnly = widget.initialFilters.isVerifiedOnly;
    _sortBy = widget.initialFilters.sortBy;
    _location = widget.initialFilters.location;
  }

  void _apply() {
    final filters = SearchFiltersEntity(
      categories: _selectedCategories,
      minRate: _priceRange.start > 0 ? _priceRange.start : null,
      maxRate: _priceRange.end < 1000 ? _priceRange.end : null,
      location: _location?.isEmpty == true ? null : _location,
      minRating: _minRating > 0 ? _minRating : null,
      isVerifiedOnly: _verifiedOnly,
      sortBy: _sortBy,
    );
    widget.onApply(filters);
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _selectedCategories = [];
      _minRating = 0.0;
      _priceRange = const RangeValues(0, 1000);
      _verifiedOnly = false;
      _sortBy = SortBy.relevant;
      _location = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Reset all'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  bottom: mediaQuery.viewInsets.bottom + 16,
                ),
                children: [
                  _SortSection(
                    selected: _sortBy,
                    onChanged: (v) => setState(() => _sortBy = v),
                  ),
                  const _Divider(),
                  _CategoriesSection(
                    all: _allCategories,
                    selected: _selectedCategories,
                    onToggle: (cat) => setState(() {
                      if (_selectedCategories.contains(cat)) {
                        _selectedCategories.remove(cat);
                      } else {
                        _selectedCategories.add(cat);
                      }
                    }),
                  ),
                  const _Divider(),
                  _PriceRangeSection(
                    range: _priceRange,
                    onChanged: (v) => setState(() => _priceRange = v),
                  ),
                  const _Divider(),
                  _RatingSection(
                    minRating: _minRating,
                    onChanged: (v) => setState(() => _minRating = v),
                  ),
                  const _Divider(),
                  _VerifiedSection(
                    value: _verifiedOnly,
                    onChanged: (v) => setState(() => _verifiedOnly = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, 16 + mediaQuery.viewPadding.bottom),
              child: PrimaryButton(
                label: 'Apply filters',
                onPressed: _apply,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 20, endIndent: 20);
}

class _SortSection extends StatelessWidget {
  final SortBy selected;
  final ValueChanged<SortBy> onChanged;

  const _SortSection({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Sort by'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SortBy.values.map((s) {
              final isSelected = s == selected;
              return ChoiceChip(
                label: Text(s.label),
                selected: isSelected,
                onSelected: (_) => onChanged(s),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  final List<String> all;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const _CategoriesSection({
    required this.all,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Categories'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: all.map((cat) {
              final isSelected = selected.contains(cat);
              return FilterChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (_) => onToggle(cat),
                selectedColor: AppColors.primaryContainer,
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PriceRangeSection extends StatelessWidget {
  final RangeValues range;
  final ValueChanged<RangeValues> onChanged;

  const _PriceRangeSection({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle(title: 'Hourly rate'),
              Text(
                '£${range.start.toInt()} – £${range.end.toInt()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: range,
            min: 0,
            max: 1000,
            divisions: 20,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.outlineVariant,
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('£0', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              Text('£1,000+', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  final double minRating;
  final ValueChanged<double> onChanged;

  const _RatingSection({required this.minRating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle(title: 'Minimum rating'),
              if (minRating > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 16, color: AppColors.warning),
                    const SizedBox(width: 2),
                    Text(
                      minRating.toStringAsFixed(1),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'Any',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          Slider(
            value: minRating,
            min: 0,
            max: 5,
            divisions: 10,
            activeColor: AppColors.warning,
            inactiveColor: AppColors.outlineVariant,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _VerifiedSection extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _VerifiedSection({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: const Row(
        children: [
          Icon(Icons.verified_rounded, size: 18, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Verified creators only'),
        ],
      ),
      subtitle: const Text('Show only verified creators'),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
