import 'package:firebase_performance/firebase_performance.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/logging/app_logger.dart';

/// Wrapper around Firebase Performance Monitoring.
/// Provides custom traces and HTTP metric helpers.
class PerformanceService {
  PerformanceService(this._performance);

  final FirebasePerformance _performance;

  bool get _enabled => FlavorConfig.instance.enablePerformanceMonitoring;

  // ── Custom traces ────────────────────────────────────────────────────────

  /// Returns an active trace or a no-op stub if monitoring is disabled.
  AppTrace startTrace(String name) {
    if (!_enabled) return _NoOpTrace(name);
    try {
      final trace = _performance.newTrace(name);
      trace.start();
      return _FirebaseTrace(trace, name);
    } catch (e) {
      AppLogger.warning('PerformanceService.startTrace failed', error: e);
      return _NoOpTrace(name);
    }
  }

  // ── Convenience trace wrappers ────────────────────────────────────────────

  Future<T> traceAsync<T>(
    String name,
    Future<T> Function() call, {
    Map<String, String>? attributes,
  }) async {
    final trace = startTrace(name);
    if (attributes != null) {
      for (final e in attributes.entries) {
        trace.putAttribute(e.key, e.value);
      }
    }
    try {
      final result = await call();
      trace.stop();
      return result;
    } catch (e) {
      trace.putAttribute('error', e.runtimeType.toString());
      trace.stop();
      rethrow;
    }
  }

  // ── App startup ──────────────────────────────────────────────────────────

  late final AppTrace _startupTrace = startTrace('app_startup');

  void startStartupTrace() => _startupTrace;

  void finishStartupTrace({bool success = true}) {
    _startupTrace
      ..putAttribute('success', success.toString())
      ..stop();
  }

  // ── Screen rendering ─────────────────────────────────────────────────────

  AppTrace startScreenTrace(String screenName) =>
      startTrace('screen_$screenName');
}

/// Public interface so callers don't depend on Firebase types.
abstract class AppTrace {
  void stop();
  void putAttribute(String name, String value);
  void incrementMetric(String name, int by);
}

class _FirebaseTrace implements AppTrace {
  _FirebaseTrace(this._trace, this._name);
  final Trace _trace;
  final String _name;

  @override
  void stop() {
    try {
      _trace.stop();
      AppLogger.debug('PerformanceService: trace "$_name" stopped');
    } catch (e) {
      AppLogger.warning('PerformanceService: stop trace failed', error: e);
    }
  }

  @override
  void putAttribute(String name, String value) {
    try {
      _trace.putAttribute(name, value);
    } catch (_) {}
  }

  @override
  void incrementMetric(String name, int by) {
    try {
      _trace.incrementMetric(name, by);
    } catch (_) {}
  }
}

class _NoOpTrace implements AppTrace {
  const _NoOpTrace(this._name);
  final String _name;

  @override
  void stop() {}

  @override
  void putAttribute(String name, String value) {}

  @override
  void incrementMetric(String name, int by) {}
}
