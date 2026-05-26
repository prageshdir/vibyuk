import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';

class BusinessEmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const BusinessEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  });

  const BusinessEmptyState.noCreators({super.key, VoidCallback? onSearch})
      : title = 'No creators found',
        description = 'Try adjusting your search or filters.',
        icon = Icons.person_search_rounded,
        actionLabel = 'Clear filters',
        onAction = onSearch;

  const BusinessEmptyState.noCampaigns({super.key, VoidCallback? onCreate})
      : title = 'No campaigns yet',
        description = 'Create your first campaign to start connecting with creators.',
        icon = Icons.campaign_rounded,
        actionLabel = 'Create campaign',
        onAction = onCreate;

  const BusinessEmptyState.noBookings({super.key})
      : title = 'No bookings yet',
        description = 'Your upcoming and past bookings will appear here.',
        icon = Icons.calendar_today_rounded,
        actionLabel = null,
        onAction = null;

  const BusinessEmptyState.noNotifications({super.key})
      : title = 'All caught up',
        description = 'New notifications will appear here.',
        icon = Icons.notifications_none_rounded,
        actionLabel = null,
        onAction = null;

  const BusinessEmptyState.noPayments({super.key})
      : title = 'No transactions',
        description = 'Your payment history will appear here.',
        icon = Icons.receipt_long_rounded,
        actionLabel = null,
        onAction = null;

  const BusinessEmptyState.noTeamMembers({super.key, VoidCallback? onInvite})
      : title = 'No team members',
        description = 'Invite colleagues to collaborate on campaigns.',
        icon = Icons.group_add_rounded,
        actionLabel = 'Invite member',
        onAction = onInvite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
