import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class ChatNotificationService {
  const ChatNotificationService(this._messaging);

  final FirebaseMessaging _messaging;

  Future<void> init() async {
    await _messaging.requestPermission();
    FirebaseMessaging.onMessage.listen(_handleForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackground);
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleBackground(initial);
  }

  void _handleForeground(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('[ChatNotification] foreground: ${message.data}');
    }
    // TODO: show in-app notification banner
  }

  void _handleBackground(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('[ChatNotification] opened: ${message.data}');
    }
    // TODO: navigate to conversation from message.data['conversationId']
  }

  Future<String?> getToken() => _messaging.getToken();
}
