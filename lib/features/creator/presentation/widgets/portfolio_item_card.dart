import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/creator/domain/entities/portfolio_item_entity.dart';

class PortfolioItemCard extends StatelessWidget {
  const PortfolioItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
    this.isSelectable = false,
    this.isSelected = false,
  });

  final PortfolioItemEntity item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSelectable;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media
            item.thumbnailUrl != null || item.mediaUrl.isNotEmpty
                ? Image.network(
                    item.thumbnailUrl ?? item.mediaUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const _MediaPlaceholder(),
                  )
                : const _MediaPlaceholder(),

            // Gradient overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                  stops: [0.5, 1.0],
                ),
              ),
            ),

            // Video badge
            if (item.mediaType == MediaType.video)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.play_circle_fill_rounded,
                    color: Colors.white, size: 28),
              ),

            // Featured badge
            if (item.isFeatured)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Featured',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
              ),

            // Title at bottom
            Positioned(
              bottom: 8,
              left: 8,
              right: onDelete != null ? 36 : 8,
              child: Text(
                item.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Delete button
            if (onDelete != null)
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ),

            // Selection overlay
            if (isSelectable)
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.white54,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PortfolioGrid extends StatelessWidget {
  const PortfolioGrid({
    super.key,
    required this.items,
    this.onItemTap,
    this.onItemDelete,
    this.isSelectable = false,
    this.selectedIds = const {},
    this.scrollController,
  });

  final List<PortfolioItemEntity> items;
  final void Function(PortfolioItemEntity)? onItemTap;
  final void Function(String)? onItemDelete;
  final bool isSelectable;
  final Set<String> selectedIds;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return PortfolioItemCard(
          item: item,
          onTap: onItemTap != null ? () => onItemTap!(item) : null,
          onDelete:
              onItemDelete != null ? () => onItemDelete!(item.id) : null,
          isSelectable: isSelectable,
          isSelected: selectedIds.contains(item.id),
        );
      },
    );
  }
}

class _MediaPlaceholder extends StatelessWidget {
  const _MediaPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
    );
  }
}
