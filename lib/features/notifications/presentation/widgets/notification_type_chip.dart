import 'package:flutter/material.dart';
import 'package:vibyuk/core/notifications/models/push_notification_model.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

class NotificationTypeChip extends StatelessWidget {
  final NotificationType type;
  final bool compact;

  const NotificationTypeChip({
    super.key,
    required this.type,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _configFor(type);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: compact ? 10 : 12, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  _TypeConfig _configFor(NotificationType type) {
    return switch (type) {
      NotificationType.bookingRequest ||
      NotificationType.bookingConfirmed ||
      NotificationType.bookingCancelled ||
      NotificationType.bookingReminder =>
        _TypeConfig(
          label: 'Booking',
          icon: Icons.calendar_month,
          color: AppColors.primary,
        ),
      NotificationType.newMessage => _TypeConfig(
          label: 'Message',
          icon: Icons.chat_bubble,
          color: AppColors.tertiary,
        ),
      NotificationType.paymentReceived ||
      NotificationType.paymentFailed ||
      NotificationType.paymentRefunded =>
        _TypeConfig(
          label: 'Payment',
          icon: Icons.payments,
          color: AppColors.success,
        ),
      NotificationType.campaignStarted ||
      NotificationType.campaignEnded ||
      NotificationType.campaignUpdate =>
        _TypeConfig(
          label: 'Campaign',
          icon: Icons.campaign,
          color: AppColors.warning,
        ),
      NotificationType.newReview => _TypeConfig(
          label: 'Review',
          icon: Icons.star,
          color: AppColors.secondary,
        ),
      NotificationType.eventReminder ||
      NotificationType.eventUpdate ||
      NotificationType.eventCancelled =>
        _TypeConfig(
          label: 'Event',
          icon: Icons.event,
          color: AppColors.primaryLight,
        ),
      NotificationType.creatorFollowed => _TypeConfig(
          label: 'Social',
          icon: Icons.person_add,
          color: AppColors.secondaryLight,
        ),
      NotificationType.systemAlert => _TypeConfig(
          label: 'System',
          icon: Icons.info,
          color: AppColors.textSecondary,
        ),
      NotificationType.general => _TypeConfig(
          label: 'General',
          icon: Icons.notifications,
          color: AppColors.textSecondary,
        ),
    };
  }
}

class _TypeConfig {
  final String label;
  final IconData icon;
  final Color color;

  const _TypeConfig({
    required this.label,
    required this.icon,
    required this.color,
  });
}
