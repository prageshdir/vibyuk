import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/services/crash_reporting_service.dart';

/// Production BLoC observer.
/// In dev: full event + state + transition logging via AppLogger.
/// In production: only errors are forwarded to CrashReportingService.
class AppBlocObserver extends BlocObserver {
  AppBlocObserver({required CrashReportingService crashReporting})
      : _crashReporting = crashReporting;

  final CrashReportingService _crashReporting;

  bool get _verbose => FlavorConfig.instance.isDev;

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (_verbose) {
      AppLogger.logBlocEvent(bloc.runtimeType.toString(), event.toString());
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (_verbose) {
      AppLogger.logBlocState(
        bloc.runtimeType.toString(),
        transition.nextState.toString(),
      );
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    AppLogger.error(
      'BLoC error in ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
    _crashReporting.recordError(
      error,
      stackTrace,
      reason: 'BLoC error in ${bloc.runtimeType}',
      context: {'bloc': bloc.runtimeType.toString()},
    );
  }
}
