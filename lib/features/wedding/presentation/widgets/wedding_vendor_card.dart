import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_vendor_entity.dart';

class WeddingVendorCard extends StatelessWidget {
  final WeddingVendorEntity vendor;
  final VoidCallback onTap;

  const WeddingVendorCard({
    super.key,
    required this.vendor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(theme),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (vendor.isVerified)
                        const Icon(Icons.verified, size: 16, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        vendor.rating.toStringAsFixed(1),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${vendor.reviewCount})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vendor.priceRange,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          vendor.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ThemeData theme) {
    if (vendor.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: vendor.imageUrl!,
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => _imagePlaceholder(theme),
        errorWidget: (_, __, ___) => _imagePlaceholder(theme),
      );
    }
    return _imagePlaceholder(theme);
  }

  Widget _imagePlaceholder(ThemeData theme) => Container(
        height: 140,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.camera_alt_outlined,
            size: 40,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      );
}
