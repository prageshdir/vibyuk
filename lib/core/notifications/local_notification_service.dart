import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/notifications/models/push_notification_model.dart';

abstract final class LocalNotificationService {

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static void Function(String? payload)? _onNotificationTap;

  static Future<void> initialize({
    void Function(String? payload)? onNotificationTap,
  }) async {
    _onNotificationTap = onNotificationTap;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundResponse,
    );

    await _createNotificationChannels();
    AppLogger.info('LocalNotificationService initialized');
  }

  static void _onResponse(NotificationResponse response) {
    AppLogger.debug('Local notification tapped: ${response.id}');
    _onNotificationTap?.call(response.payload);
  }

  @pragma('vm:entry-point')
  static void _onBackgroundResponse(NotificationResponse response) {
    AppLogger.debug('Local notification background tap: ${response.id}');
  }

  static Future<void> _createNotificationChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    for (final channel in _channels.values) {
      await android.createNotificationChannel(channel);
    }
  }

  static Future<void> show(PushNotificationModel notification) async {
    final channelId = _channelIdFor(notification.type);
    final channel = _channels[channelId]!;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      groupKey: notification.type.name,
      category: notification.type.isChat
          ? AndroidNotificationCategory.message
          : AndroidNotificationCategory.reminder,
      styleInformation: BigTextStyleInformation(notification.body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: notification.deepLink,
    );

    AppLogger.debug('Local notification shown [${notification.type.name}]');
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> cancel(String notificationId) async {
    await _plugin.cancel(notificationId.hashCode);
  }

  static String _channelIdFor(NotificationType type) {
    if (type.isBooking) return 'ch_bookings';
    if (type.isChat) return 'ch_chat';
    if (type.isPayment) return 'ch_payments';
    if (type.isCampaign) return 'ch_campaigns';
    if (type.isEvent) return 'ch_events';
    if (type == NotificationType.newReview) return 'ch_reviews';
    return 'ch_general';
  }

  static final Map<String, AndroidNotificationChannel> _channels = {
    'ch_bookings': const AndroidNotificationChannel(
      'ch_bookings',
      'Booking Alerts',
      description: 'Notifications for booking requests and updates',
      importance: Importance.high,
    ),
    'ch_chat': const AndroidNotificationChannel(
      'ch_chat',
      'Messages',
      description: 'New chat message notifications',
      importance: Importance.max,
    ),
    'ch_payments': const AndroidNotificationChannel(
      'ch_payments',
      'Payment Alerts',
      description: 'Payment confirmations and alerts',
      importance: Importance.high,
    ),
    'ch_campaigns': const AndroidNotificationChannel(
      'ch_campaigns',
      'Campaign Updates',
      description: 'Campaign status and update notifications',
      importance: Importance.defaultImportance,
    ),
    'ch_events': const AndroidNotificationChannel(
      'ch_events',
      'Event Reminders',
      description: 'Event reminders and updates',
      importance: Importance.high,
    ),
    'ch_reviews': const AndroidNotificationChannel(
      'ch_reviews',
      'Reviews',
      description: 'New review notifications',
      importance: Importance.defaultImportance,
    ),
    'ch_general': const AndroidNotificationChannel(
      'ch_general',
      'General',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
    ),
  };
}
