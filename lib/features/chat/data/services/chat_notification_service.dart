import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vibyuk/core/navigation/app_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';

class ChatNotificationService {
  ChatNotificationService(this._messaging, this._appRouter);

  final FirebaseMessaging _messaging;
  final AppRouter _appRouter;

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
    final context = _appRouter.navigatorKey.currentContext;
    if (context == null) return;

    final title = message.notification?.title ?? 'New message';
    final body = message.notification?.body ?? '';
    final conversationId = message.data['conversationId'] as String?;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (body.isNotEmpty) Text(body, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        action: conversationId != null
            ? SnackBarAction(
                label: 'Open',
                onPressed: () => _navigateToConversation(conversationId),
              )
            : null,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleBackground(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('[ChatNotification] opened: ${message.data}');
    }
    final conversationId = message.data['conversationId'] as String?;
    if (conversationId != null) {
      _navigateToConversation(conversationId);
    }
  }

  void _navigateToConversation(String conversationId) {
    _appRouter.router.go(RouteNames.chatConversation(conversationId));
  }

  Future<String?> getToken() => _messaging.getToken();
}
