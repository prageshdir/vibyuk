import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/notifications/presentation/blocs/notification_center/notification_center_bloc.dart';

class NotificationFilterBar extends StatelessWidget {
  final NotificationFilter activeFilter;
  final ValueChanged<NotificationFilter> onFilterSelected;

  const NotificationFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: NotificationFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = NotificationFilter.values[index];
          final isActive = filter == activeFilter;
          return _FilterChip(
            label: _labelFor(filter),
            icon: _iconFor(filter),
            isActive: isActive,
            onTap: () => onFilterSelected(filter),
          );
        },
      ),
    );
  }

  String _labelFor(NotificationFilter filter) {
    return switch (filter) {
      NotificationFilter.all => 'All',
      NotificationFilter.unread => 'Unread',
      NotificationFilter.bookings => 'Bookings',
      NotificationFilter.chat => 'Chat',
      NotificationFilter.payments => 'Payments',
      NotificationFilter.campaigns => 'Campaigns',
    };
  }

  IconData _iconFor(NotificationFilter filter) {
    return switch (filter) {
      NotificationFilter.all => Icons.all_inbox,
      NotificationFilter.unread => Icons.mark_email_unread_outlined,
      NotificationFilter.bookings => Icons.calendar_month_outlined,
      NotificationFilter.chat => Icons.chat_bubble_outline,
      NotificationFilter.payments => Icons.payments_outlined,
      NotificationFilter.campaigns => Icons.campaign_outlined,
    };
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? AppColors.onPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.onPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
