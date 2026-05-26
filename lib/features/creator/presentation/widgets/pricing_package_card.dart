import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/creator/domain/entities/pricing_package_entity.dart';

class PricingPackageCard extends StatelessWidget {
  const PricingPackageCard({
    super.key,
    required this.package,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isEditable = false,
  });

  final PricingPackageEntity package;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isEditable;

  Color get _typeColor {
    return switch (package.packageType) {
      PackageType.basic => Colors.blueGrey,
      PackageType.standard => AppColors.primary,
      PackageType.premium => Colors.amber.shade700,
    };
  }

  IconData get _typeIcon {
    return switch (package.packageType) {
      PackageType.basic => Icons.star_border_rounded,
      PackageType.standard => Icons.star_half_rounded,
      PackageType.premium => Icons.star_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_typeIcon, color: _typeColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          package.packageType.name.toUpperCase(),
                          style: TextStyle(
                              color: _typeColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (!package.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Inactive',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ),
                  if (isEditable)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: theme.colorScheme.error,
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(package.title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(package.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${package.currency} ${package.price.toStringAsFixed(0)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  const Spacer(),
                  _InfoChip(
                    icon: Icons.timer_outlined,
                    label: '${package.deliveryDays}d delivery',
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.refresh_rounded,
                    label: '${package.revisions} rev.',
                  ),
                ],
              ),
              if (package.inclusions.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: package.inclusions
                      .map((inc) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 14, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(inc,
                                  style: theme.textTheme.bodySmall),
                            ],
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
