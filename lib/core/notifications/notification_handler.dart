import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/notifications/models/push_notification_model.dart';

/// Central dispatcher for all push notification events.
/// Feature modules register their handlers here as they are built.
class NotificationHandler {
  NotificationHandler();

  // Callbacks registered by feature modules
  void Function(String token)? _onTokenReceived;
  void Function(PushNotificationModel notification)? _onForegroundMessage;
  void Function(PushNotificationModel notification)? _onNotificationTapped;

  void registerTokenCallback(void Function(String) callback) {
    _onTokenReceived = callback;
  }

  void registerForegroundCallback(
    void Function(PushNotificationModel) callback,
  ) {
    _onForegroundMessage = callback;
  }

  void registerTapCallback(
    void Function(PushNotificationModel) callback,
  ) {
    _onNotificationTapped = callback;
  }

  Future<void> onTokenReceived(String token) async {
    AppLogger.info('NotificationHandler: token received');
    _onTokenReceived?.call(token);
  }

  void onForegroundMessage(PushNotificationModel notification) {
    AppLogger.info('NotificationHandler: foreground message [${notification.type.name}]');
    _onForegroundMessage?.call(notification);
  }

  void onNotificationTapped(PushNotificationModel notification) {
    AppLogger.info('NotificationHandler: notification tapped [${notification.type.name}]');
    _handleDeepLink(notification);
    _onNotificationTapped?.call(notification);
  }

  void _handleDeepLink(PushNotificationModel notification) {
    if (notification.deepLink == null) return;
    // Router navigation is injected by the app layer to avoid circular deps
    AppLogger.debug('NotificationHandler: deep link → ${notification.deepLink}');
  }
}
