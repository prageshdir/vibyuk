import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/logging/app_logger.dart';

class LoggingInterceptor extends TalkerDioLogger {
  LoggingInterceptor()
      : super(
          talker: AppLogger.talker,
          settings: TalkerDioLoggerSettings(
            enabled: FlavorConfig.instance.enableLogging,
            printRequestHeaders: FlavorConfig.instance.isDev,
            printResponseHeaders: false,
            printResponseData: FlavorConfig.instance.isDev,
            printRequestData: FlavorConfig.instance.isDev,
            printErrorData: true,
            printErrorHeaders: FlavorConfig.instance.isDev,
            requestPen: AnsiPen()..green(),
            responsePen: AnsiPen()..blue(),
            errorPen: AnsiPen()..red(),
          ),
        );
}
