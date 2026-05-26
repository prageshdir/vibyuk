import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/logging/app_logger.dart';

/// Typed wrapper around FirebaseAnalytics.
/// All event names follow snake_case convention; properties are sanitised.
/// No-ops when analytics is disabled (dev flavor or opted-out).
class AnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  bool get _enabled => FlavorConfig.instance.enableAnalytics;

  // ── Navigation ───────────────────────────────────────────────────────────

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_enabled) return;
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      AppLogger.warning('Analytics.logScreenView failed', error: e);
    }
  }

  // ── Auth events ──────────────────────────────────────────────────────────

  Future<void> logLogin({required String method}) async {
    if (!_enabled) return;
    await _safeLog(() => _analytics.logLogin(loginMethod: method));
  }

  Future<void> logSignUp({required String method}) async {
    if (!_enabled) return;
    await _safeLog(() => _analytics.logSignUp(signUpMethod: method));
  }

  Future<void> logLogout() async {
    if (!_enabled) return;
    await _safeLog(() => _analytics.logEvent(name: 'logout'));
  }

  // ── Booking events ───────────────────────────────────────────────────────

  Future<void> logBookingStarted({
    required String creatorId,
    required String creatorCategory,
  }) async {
    if (!_enabled) return;
    await _safeLog(
      () => _analytics.logEvent(
        name: 'booking_started',
        parameters: {
          'creator_id': _truncate(creatorId),
          'creator_category': creatorCategory,
        },
      ),
    );
  }

  Future<void> logBookingCompleted({
    required String bookingId,
    required double value,
    required String currency,
  }) async {
    if (!_enabled) return;
    await _safeLog(
      () => _analytics.logPurchase(
        transactionId: bookingId,
        value: value,
        currency: currency,
      ),
    );
  }

  Future<void> logBookingCancelled({
    required String bookingId,
    required String reason,
  }) async {
    if (!_enabled) return;
    await _safeLog(
      () => _analytics.logEvent(
        name: 'booking_cancelled',
        parameters: {
          'booking_id': _truncate(bookingId),
          'reason': reason,
        },
      ),
    );
  }

  // ── AI events ────────────────────────────────────────────────────────────

  Future<void> logAiFeatureUsed({
    required String featureName,
    Map<String, Object>? parameters,
  }) async {
    if (!_enabled) return;
    await _safeLog(
      () => _analytics.logEvent(
        name: 'ai_feature_used',
        parameters: {
          'feature_name': featureName,
          ...?parameters,
        },
      ),
    );
  }

  Future<void> logAiChatMessage({required String context}) async {
    if (!_enabled) return;
    await _safeLog(
      () => _analytics.logEvent(
        name: 'ai_chat_message_sent',
        parameters: {'context': context},
      ),
    );
  }

  // ── Creator events ───────────────────────────────────────────────────────

  Future<void> logCreatorProfileViewed({required String creatorId}) async {
    if (!_enabled) return;
    await _safeLog(
      () => _analytics.logViewItem(
        items: [
          AnalyticsEventItem(
            itemId: creatorId,
            itemCategory: 'creator',
          ),
        ],
      ),
    );
  }

  Future<void> logSearch({
    required String query,
    required String searchType,
  }) async {
    if (!_enabled) return;
    await _safeLog(
      () => _analytics.logSearch(
        searchTerm: _truncate(query, max: 100),
      ),
    );
  }

  // ── Admin events ─────────────────────────────────────────────────────────

  Future<void> logAdminAction({
    required String action,
    required String targetType,
    String? targetId,
  }) async {
    if (!_enabled) return;
    await _safeLog(
      () => _analytics.logEvent(
        name: 'admin_action',
        parameters: {
          'action': action,
          'target_type': targetType,
          if (targetId != null) 'target_id': _truncate(targetId),
        },
      ),
    );
  }

  // ── User properties ──────────────────────────────────────────────────────

  Future<void> setUserId(String? userId) async {
    if (!_enabled) return;
    await _safeLog(() => _analytics.setUserId(id: userId));
  }

  Future<void> setUserRole(String role) async {
    if (!_enabled) return;
    await _safeLog(
      () => _analytics.setUserProperty(name: 'user_role', value: role),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _safeLog(Future<void> Function() call) async {
    try {
      await call();
    } catch (e) {
      AppLogger.warning('AnalyticsService: event log failed', error: e);
    }
  }

  String _truncate(String value, {int max = 36}) =>
      value.length > max ? value.substring(0, max) : value;
}
