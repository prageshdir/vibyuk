import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

class CreatorEmptyState extends StatelessWidget {
  const CreatorEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  const CreatorEmptyState.noPortfolio({super.key})
      : title = 'No portfolio items yet',
        description =
            'Showcase your work by uploading photos or videos to attract clients.',
        icon = Icons.photo_library_outlined,
        actionLabel = 'Add your first item',
        onAction = null;

  const CreatorEmptyState.noBookingRequests({super.key})
      : title = 'No booking requests',
        description =
            'When businesses send you booking requests they will appear here.',
        icon = Icons.inbox_outlined,
        actionLabel = null,
        onAction = null;

  const CreatorEmptyState.noApplications({super.key})
      : title = 'No applications yet',
        description =
            'Browse campaigns and apply to ones that match your skills.',
        icon = Icons.campaign_outlined,
        actionLabel = 'Explore campaigns',
        onAction = null;

  const CreatorEmptyState.noReviews({super.key})
      : title = 'No reviews yet',
        description =
            'Complete your first booking to start collecting reviews.',
        icon = Icons.star_outline_rounded,
        actionLabel = null,
        onAction = null;

  const CreatorEmptyState.noPricingPackages({super.key})
      : title = 'No packages set up',
        description =
            'Create pricing packages to let businesses book you easily.',
        icon = Icons.sell_outlined,
        actionLabel = 'Create a package',
        onAction = null;

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(description,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
