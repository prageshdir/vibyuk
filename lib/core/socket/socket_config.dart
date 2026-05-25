import 'package:vibyuk/core/config/app_config.dart';

abstract final class SocketConfig {
  static String get url => AppConfig.flavor.wsUrl;

  static const Duration initialReconnectDelay = Duration(seconds: 1);
  static const Duration maxReconnectDelay = Duration(seconds: 30);
  static const int maxReconnectAttempts = 10;
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration pingInterval = Duration(seconds: 25);

  SocketConfig._();
}
