import 'package:talker_flutter/talker_flutter.dart';
import 'package:vibyuk/core/config/flavor_config.dart';

class AppLogger {
  AppLogger._();

  static late final Talker _talker;

  static Talker get talker => _talker;

  static void initialize() {
    _talker = TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: true,
        useConsoleLogs: FlavorConfig.instance.enableLogging,
        maxHistoryItems: FlavorConfig.instance.isDev ? 1000 : 200,
      ),
      logger: TalkerLogger(
        output: debugPrint,
        settings: TalkerLoggerSettings(
          enableColors: FlavorConfig.instance.isDev,
          level: FlavorConfig.instance.isDev ? LogLevel.verbose : LogLevel.warning,
        ),
      ),
    );
  }

  static void verbose(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.verbose(message, error, stackTrace);
  }

  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.debug(message, error, stackTrace);
  }

  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.info(message, error, stackTrace);
  }

  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.warning(message, error, stackTrace);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.error(message, error, stackTrace);
  }

  static void critical(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.critical(message, error, stackTrace);
  }

  static void handle(Object error, [StackTrace? stackTrace, String? message]) {
    _talker.handle(error, stackTrace, message);
  }

  // Lifecycle event logging
  static void logRoute(String routeName, {Map<String, dynamic>? params}) {
    info('ROUTE → $routeName${params != null ? ' | params: $params' : ''}');
  }

  static void logBlocEvent(String bloc, String event) {
    debug('BLOC [$bloc] → $event');
  }

  static void logBlocState(String bloc, String state) {
    debug('BLOC [$bloc] ← $state');
  }

  static void logApiRequest(String method, String path) {
    info('API ↑ $method $path');
  }

  static void logApiResponse(String method, String path, int statusCode) {
    info('API ↓ $method $path [$statusCode]');
  }
}
