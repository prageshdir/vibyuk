import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/profile/domain/entities/profile_entity.dart';

class ProfileStatsRow extends StatelessWidget {
  final ProfileStats stats;
  final bool isCreator;

  const ProfileStatsRow({
    super.key,
    required this.stats,
    this.isCreator = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            value: stats.totalBookings.toString(),
            label: isCreator ? 'Bookings' : 'Hires',
          ),
          if (isCreator && stats.rating != null) ...[
            const _Divider(),
            _StatItem(
              value: stats.ratingDisplay,
              label: 'Rating',
              icon: Icons.star_rounded,
              iconColor: AppColors.warning,
            ),
          ],
          const _Divider(),
          _StatItem(
            value: stats.reviewsCount.toString(),
            label: 'Reviews',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;

  const _StatItem({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: iconColor ?? AppColors.primary),
                const SizedBox(width: 2),
              ],
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
