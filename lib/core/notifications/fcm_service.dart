import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/notifications/models/push_notification_model.dart';
import 'package:vibyuk/core/notifications/notification_handler.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('FCM background message received: ${message.messageId}');
  // Minimal processing only — heavy work is done when the app opens
}

class FcmService {
  FcmService(this._handler);

  final NotificationHandler _handler;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  String? _token;
  String? get token => _token;

  Future<void> initialize() async {
    // Register the background handler before any other FCM call
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _requestPermission();
    await _fetchToken();
    _listenToTokenRefresh();
    _listenToForegroundMessages();
    _listenToMessageOpenedApp();
    await _handleInitialMessage();

    AppLogger.info('FCM initialized');
  }

  Future<void> _requestPermission() async {
    if (kIsWeb || !Platform.isIOS) return;

    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    AppLogger.info('FCM permission: ${settings.authorizationStatus.name}');
  }

  Future<void> _fetchToken() async {
    try {
      _token = await _fcm.getToken();
      AppLogger.info('FCM token: ${_token?.substring(0, 20)}...');
      if (_token != null) {
        await _handler.onTokenReceived(_token!);
      }
    } catch (e, st) {
      AppLogger.error('Failed to fetch FCM token', error: e, stackTrace: st);
    }
  }

  void _listenToTokenRefresh() {
    _fcm.onTokenRefresh.listen((newToken) async {
      _token = newToken;
      AppLogger.info('FCM token refreshed');
      await _handler.onTokenReceived(newToken);
    });
  }

  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('FCM foreground message: ${message.messageId}');
      final notification = PushNotificationModel.fromFcmMessage(message.toMap());
      _handler.onForegroundMessage(notification);
    });
  }

  void _listenToMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('App opened from notification: ${message.messageId}');
      final notification = PushNotificationModel.fromFcmMessage(message.toMap());
      _handler.onNotificationTapped(notification);
    });
  }

  Future<void> _handleInitialMessage() async {
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      AppLogger.info('App launched from notification: ${initial.messageId}');
      final notification = PushNotificationModel.fromFcmMessage(initial.toMap());
      _handler.onNotificationTapped(notification);
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    AppLogger.info('FCM subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    AppLogger.info('FCM unsubscribed from topic: $topic');
  }

  Future<void> deleteToken() async {
    await _fcm.deleteToken();
    _token = null;
    AppLogger.info('FCM token deleted');
  }
}
