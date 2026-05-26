import 'package:flutter/material.dart';
import 'package:vibyuk/core/services/analytics_service.dart';
import 'package:vibyuk/core/services/crash_reporting_service.dart';

/// GoRouter does not expose a NavigatorObserver directly.
/// This observer is attached to the underlying Navigator via GoRouter.observers
/// to log screen views to Analytics and breadcrumbs to Crashlytics.
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver({
    required AnalyticsService analytics,
    required CrashReportingService crashReporting,
  })  : _analytics = analytics,
        _crashReporting = crashReporting;

  final AnalyticsService _analytics;
  final CrashReportingService _crashReporting;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _record(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _record(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _record(previousRoute);
  }

  void _record(Route<dynamic> route) {
    final name = route.settings.name ?? 'unknown';
    _analytics.logScreenView(screenName: name);
    _crashReporting.addRouteBreadcrumb(name);
  }
}
