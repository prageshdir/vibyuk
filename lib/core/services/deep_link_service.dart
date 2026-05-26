import 'dart:async';

import 'package:flutter/services.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/navigation/route_names.dart';

/// Parses incoming deep links / universal links and maps them to
/// GoRouter-compatible route paths.
///
/// Supported schemes:
///   vibyuk://                 → app:// deep links
///   https://vibyuk.com/...    → universal links / App Links
///
/// Supported paths:
///   /creator/{id}             → creator profile
///   /event/{id}               → event detail
///   /booking/{id}             → booking detail
///   /reset-password?token=…   → password reset
///   /verify-email?token=…     → email verification
///   /admin                    → admin dashboard
class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService instance = DeepLinkService._();

  static const _channel = MethodChannel('com.vibyuk.app/deep_link');

  final _controller = StreamController<String>.broadcast();

  /// Emits GoRouter route paths resolved from deep links.
  Stream<String> get routeStream => _controller.stream;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Handle links that launched the app from a terminated state.
    try {
      final initialLink = await _channel.invokeMethod<String>('getInitialLink');
      if (initialLink != null && initialLink.isNotEmpty) {
        final route = _resolve(initialLink);
        if (route != null) {
          AppLogger.info('DeepLink: initial link → $route');
          _controller.add(route);
        }
      }
    } on PlatformException catch (e) {
      AppLogger.warning('DeepLink: initial link unavailable', error: e);
    }

    // Handle links while the app is foregrounded.
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onLink') {
        final link = call.arguments as String?;
        if (link != null) {
          final route = _resolve(link);
          if (route != null) {
            AppLogger.info('DeepLink: foreground link → $route');
            _controller.add(route);
          }
        }
      }
    });
  }

  void dispose() {
    _controller.close();
  }

  /// Resolves a raw URL string to a GoRouter path, or null if unrecognised.
  String? _resolve(String rawLink) {
    try {
      final uri = Uri.parse(rawLink);
      final path = uri.path;
      final query = uri.queryParameters;

      // Strip leading slash for consistent matching.
      final segments = path
          .split('/')
          .where((s) => s.isNotEmpty)
          .toList();

      if (segments.isEmpty) return RouteNames.home;

      switch (segments[0]) {
        case 'creator':
          if (segments.length >= 2) {
            return '${RouteNames.creatorProfile}/${segments[1]}';
          }
        case 'event':
          if (segments.length >= 2) {
            return '/events/${segments[1]}';
          }
        case 'booking':
          if (segments.length >= 2) {
            return '/bookings/${segments[1]}';
          }
        case 'reset-password':
          final token = query['token'];
          if (token != null) {
            return '/reset-password?token=$token';
          }
        case 'verify-email':
          final token = query['token'];
          if (token != null) {
            return '/verify-email?token=$token';
          }
        case 'admin':
          return RouteNames.adminDashboard;
      }

      AppLogger.warning('DeepLink: unrecognised path: $path');
      return null;
    } catch (e) {
      AppLogger.error('DeepLink: parse error for "$rawLink"', error: e);
      return null;
    }
  }
}
