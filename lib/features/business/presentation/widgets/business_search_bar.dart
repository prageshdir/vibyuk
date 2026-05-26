import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

class BusinessSearchBar extends StatefulWidget {
  final String? initialValue;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final int activeFilterCount;
  final bool autofocus;
  final VoidCallback? onClear;

  const BusinessSearchBar({
    super.key,
    this.initialValue,
    this.hintText = 'Search creators...',
    required this.onChanged,
    this.onFilterTap,
    this.activeFilterCount = 0,
    this.autofocus = false,
    this.onClear,
  });

  @override
  State<BusinessSearchBar> createState() => _BusinessSearchBarState();
}

class _BusinessSearchBarState extends State<BusinessSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: AppColors.textSecondary),
                        onPressed: () {
                          _controller.clear();
                          widget.onChanged('');
                          widget.onClear?.call();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        if (widget.onFilterTap != null) ...[
          const SizedBox(width: 8),
          _FilterButton(
            onTap: widget.onFilterTap!,
            activeCount: widget.activeFilterCount,
          ),
        ],
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final VoidCallback onTap;
  final int activeCount;

  const _FilterButton({required this.onTap, required this.activeCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: activeCount > 0 ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  activeCount > 0 ? AppColors.primary : AppColors.outlineVariant,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: activeCount > 0 ? Colors.white : AppColors.textSecondary,
              size: 20,
            ),
            onPressed: onTap,
          ),
        ),
        if (activeCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$activeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
