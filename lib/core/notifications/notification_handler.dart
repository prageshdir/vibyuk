import 'dart:async';

import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/notifications/local_notification_service.dart';
import 'package:vibyuk/core/notifications/models/push_notification_model.dart';

/// Central dispatcher for all push notification events.
///
/// Exposes broadcast streams so feature modules can subscribe reactively.
/// The deep-link router callback is injected by the app layer to avoid
/// circular dependencies between core/notifications and core/navigation.
class NotificationHandler {
  NotificationHandler();

  final _foregroundController =
      StreamController<PushNotificationModel>.broadcast();
  final _tapController =
      StreamController<PushNotificationModel>.broadcast();
  final _tokenController = StreamController<String>.broadcast();

  /// Emits every notification received while the app is in the foreground.
  Stream<PushNotificationModel> get foregroundStream =>
      _foregroundController.stream;

  /// Emits when the user taps a notification (foreground or background).
  Stream<PushNotificationModel> get tapStream => _tapController.stream;

  /// Emits when the FCM device token is fetched or refreshed.
  Stream<String> get tokenStream => _tokenController.stream;

  // ── Router callback (injected from app layer) ─────────────────────────────

  void Function(String deepLink)? _deepLinkHandler;

  void setDeepLinkHandler(void Function(String deepLink) handler) {
    _deepLinkHandler = handler;
    AppLogger.debug('NotificationHandler: deep-link handler registered');
  }

  // ── Legacy callbacks (kept for backward compatibility) ────────────────────

  void Function(String token)? _onTokenReceived;
  void Function(PushNotificationModel)? _onForegroundMessage;
  void Function(PushNotificationModel)? _onNotificationTapped;

  void registerTokenCallback(void Function(String) callback) {
    _onTokenReceived = callback;
  }

  void registerForegroundCallback(
    void Function(PushNotificationModel) callback,
  ) {
    _onForegroundMessage = callback;
  }

  void registerTapCallback(void Function(PushNotificationModel) callback) {
    _onNotificationTapped = callback;
  }

  // ── Dispatch methods called by FcmService ─────────────────────────────────

  Future<void> onTokenReceived(String token) async {
    AppLogger.info('NotificationHandler: FCM token received');
    _tokenController.add(token);
    _onTokenReceived?.call(token);
  }

  void onForegroundMessage(PushNotificationModel notification) {
    AppLogger.info(
        'NotificationHandler: foreground [${notification.type.name}]');
    _foregroundController.add(notification);
    _onForegroundMessage?.call(notification);
    // Show OS-level banner so users see the notification while the app is open
    LocalNotificationService.show(notification).catchError(
      (Object e) => AppLogger.error('LocalNotification show failed', error: e),
    );
  }

  void onNotificationTapped(PushNotificationModel notification) {
    AppLogger.info('NotificationHandler: tapped [${notification.type.name}]');
    _tapController.add(notification);
    _onNotificationTapped?.call(notification);
    _handleDeepLink(notification);
  }

  /// Called when the user taps a local (OS-level) notification shown by
  /// [LocalNotificationService]. The payload carries the deep-link string.
  void handleLocalTap(String payload) {
    AppLogger.debug('NotificationHandler: local notification tapped → $payload');
    _deepLinkHandler?.call(payload);
  }

  void _handleDeepLink(PushNotificationModel notification) {
    final link = notification.deepLink;
    if (link == null || link.isEmpty) return;
    AppLogger.debug('NotificationHandler: deep link → $link');
    _deepLinkHandler?.call(link);
  }

  Future<void> dispose() async {
    await _foregroundController.close();
    await _tapController.close();
    await _tokenController.close();
  }
}
