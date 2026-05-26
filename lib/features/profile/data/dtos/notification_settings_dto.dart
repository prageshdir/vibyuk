import 'package:vibyuk/features/profile/domain/entities/notification_settings_entity.dart';

class NotificationSettingsDto {
  final NotificationSettingsEntity settings;

  const NotificationSettingsDto({required this.settings});

  Map<String, dynamic> toJson() => {
        'push_enabled': settings.pushEnabled,
        'email_enabled': settings.emailEnabled,
        'booking_notifications': settings.bookingNotifications,
        'message_notifications': settings.messageNotifications,
        'review_notifications': settings.reviewNotifications,
        'marketing_notifications': settings.marketingNotifications,
        'security_notifications': settings.securityNotifications,
      };
}
