import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/logging/app_logger.dart';

/// Typed wrapper around FirebaseCrashlytics.
/// Provides contextual breadcrumbs and typed error reporting.
/// No-ops in dev flavor.
class CrashReportingService {
  CrashReportingService(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  bool get _enabled =>
      FlavorConfig.instance.enableCrashlytics && !kDebugMode;

  // ── Initialization ───────────────────────────────────────────────────────

  Future<void> initialize({required String? userId}) async {
    if (!_enabled) return;
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
    if (userId != null) {
      await _crashlytics.setUserIdentifier(userId);
    }
  }

  Future<void> setUserId(String? userId) async {
    if (!_enabled) return;
    try {
      await _crashlytics.setUserIdentifier(userId ?? '');
    } catch (e) {
      AppLogger.warning('CrashReportingService.setUserId failed', error: e);
    }
  }

  // ── Error recording ──────────────────────────────────────────────────────

  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
    Map<String, String>? context,
  }) async {
    AppLogger.error(
      reason ?? 'Recorded error',
      error: error,
      stackTrace: stack,
    );
    if (!_enabled) return;
    try {
      if (context != null) {
        for (final entry in context.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value);
        }
      }
      await _crashlytics.recordError(
        error,
        stack,
        reason: reason,
        fatal: fatal,
      );
    } catch (e) {
      AppLogger.warning('CrashReportingService.recordError failed', error: e);
    }
  }

  Future<void> recordFailure(Failure failure, {StackTrace? stack}) async {
    await recordError(
      Exception('${failure.code}: ${failure.message}'),
      stack,
      reason: 'Business failure: ${failure.runtimeType}',
      context: {
        'failure_type': failure.runtimeType.toString(),
        'failure_code': failure.code ?? 'unknown',
      },
    );
  }

  // ── Breadcrumbs ──────────────────────────────────────────────────────────

  Future<void> addBreadcrumb(String message, {String? category}) async {
    AppLogger.debug('Breadcrumb: $message');
    if (!_enabled) return;
    try {
      await _crashlytics.log('[$category] $message');
    } catch (_) {}
  }

  Future<void> addRouteBreadcrumb(String routeName) async {
    await addBreadcrumb('Navigate → $routeName', category: 'navigation');
  }

  Future<void> addActionBreadcrumb(String action, {String? screen}) async {
    await addBreadcrumb(
      'Action: $action${screen != null ? ' on $screen' : ''}',
      category: 'user_action',
    );
  }

  // ── Custom keys ──────────────────────────────────────────────────────────

  Future<void> setCustomKey(String key, String value) async {
    if (!_enabled) return;
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (_) {}
  }

  Future<void> setAppContext({
    required String flavor,
    required String appVersion,
    String? userRole,
  }) async {
    if (!_enabled) return;
    try {
      await _crashlytics.setCustomKey('flavor', flavor);
      await _crashlytics.setCustomKey('app_version', appVersion);
      if (userRole != null) {
        await _crashlytics.setCustomKey('user_role', userRole);
      }
    } catch (_) {}
  }
}
