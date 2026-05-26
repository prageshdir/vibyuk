import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/services/analytics_service.dart';

// ── Fake FirebaseAnalytics ────────────────────────────────────────────────────

class _FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {
  final List<String> events = [];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {
    events.add(name);
  }

  @override
  Future<void> logScreenView({
    String? screenName,
    String? screenClass,
    AnalyticsCallOptions? callOptions,
  }) async {
    events.add('screen_view:$screenName');
  }

  @override
  Future<void> logLogin({
    required String loginMethod,
    AnalyticsCallOptions? callOptions,
  }) async {
    events.add('login:$loginMethod');
  }

  @override
  Future<void> logSignUp({
    required String signUpMethod,
    AnalyticsCallOptions? callOptions,
  }) async {
    events.add('sign_up:$signUpMethod');
  }

  @override
  Future<void> logSearch({
    required String searchTerm,
    String? destination,
    String? endDate,
    String? startDate,
    int? numberOfNights,
    int? numberOfPassengers,
    int? numberOfRooms,
    String? origin,
    String? travelClass,
    AnalyticsCallOptions? callOptions,
  }) async {
    events.add('search:$searchTerm');
  }

  @override
  Future<void> logPurchase({
    String? currency,
    String? coupon,
    double? value,
    List<AnalyticsEventItem>? items,
    double? tax,
    double? shipping,
    String? transactionId,
    String? affiliation,
    AnalyticsCallOptions? callOptions,
  }) async {
    events.add('purchase:$transactionId');
  }

  @override
  Future<void> logViewItem({
    String? currency,
    double? value,
    List<AnalyticsEventItem>? items,
    AnalyticsCallOptions? callOptions,
  }) async {
    events.add('view_item');
  }

  @override
  Future<void> setUserId({
    String? id,
    AnalyticsCallOptions? callOptions,
  }) async {
    events.add('set_user:$id');
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
    AnalyticsCallOptions? callOptions,
  }) async {
    events.add('set_property:$name=$value');
  }
}

void main() {
  late _FakeFirebaseAnalytics fakeAnalytics;
  late AnalyticsService service;

  group('AnalyticsService — dev flavor (analytics disabled)', () {
    setUp(() {
      FlavorConfig.initialize(AppFlavor.dev);
      fakeAnalytics = _FakeFirebaseAnalytics();
      service = AnalyticsService(fakeAnalytics);
    });

    test('logLogin is a no-op', () async {
      await service.logLogin(method: 'email');
      expect(fakeAnalytics.events, isEmpty);
    });

    test('logSignUp is a no-op', () async {
      await service.logSignUp(method: 'google');
      expect(fakeAnalytics.events, isEmpty);
    });

    test('logScreenView is a no-op', () async {
      await service.logScreenView(screenName: 'HomeScreen');
      expect(fakeAnalytics.events, isEmpty);
    });

    test('logSearch is a no-op', () async {
      await service.logSearch(query: 'dj london', searchType: 'creator');
      expect(fakeAnalytics.events, isEmpty);
    });

    test('setUserId is a no-op', () async {
      await service.setUserId('user-123');
      expect(fakeAnalytics.events, isEmpty);
    });

    test('logBookingCompleted is a no-op', () async {
      await service.logBookingCompleted(
        bookingId: 'bk-1',
        value: 199.99,
        currency: 'GBP',
      );
      expect(fakeAnalytics.events, isEmpty);
    });

    test('does not throw on any call', () async {
      expect(
        () async {
          await service.logLogin(method: 'email');
          await service.logLogout();
          await service.logScreenView(screenName: 'Test');
          await service.logAiFeatureUsed(featureName: 'recommendations');
          await service.logAdminAction(action: 'approve', targetType: 'creator');
        },
        returnsNormally,
      );
    });
  });

  group('AnalyticsService — production flavor (analytics enabled)', () {
    setUp(() {
      FlavorConfig.initialize(AppFlavor.production);
      fakeAnalytics = _FakeFirebaseAnalytics();
      service = AnalyticsService(fakeAnalytics);
    });

    tearDown(() => FlavorConfig.initialize(AppFlavor.dev));

    test('logLogin calls Firebase logLogin', () async {
      await service.logLogin(method: 'email');
      expect(fakeAnalytics.events, contains('login:email'));
    });

    test('logSignUp calls Firebase logSignUp', () async {
      await service.logSignUp(method: 'google');
      expect(fakeAnalytics.events, contains('sign_up:google'));
    });

    test('logScreenView calls Firebase logScreenView', () async {
      await service.logScreenView(screenName: 'ProfileScreen');
      expect(fakeAnalytics.events, contains('screen_view:ProfileScreen'));
    });

    test('logBookingCompleted calls Firebase logPurchase', () async {
      await service.logBookingCompleted(
        bookingId: 'bk-123',
        value: 250.0,
        currency: 'GBP',
      );
      expect(fakeAnalytics.events, contains('purchase:bk-123'));
    });

    test('setUserId calls Firebase setUserId', () async {
      await service.setUserId('uid-999');
      expect(fakeAnalytics.events, contains('set_user:uid-999'));
    });

    test('setUserRole calls Firebase setUserProperty', () async {
      await service.setUserRole('creator');
      expect(fakeAnalytics.events, contains('set_property:user_role=creator'));
    });

    test('logAiFeatureUsed fires ai_feature_used event', () async {
      await service.logAiFeatureUsed(featureName: 'smart_match');
      expect(fakeAnalytics.events, contains('ai_feature_used'));
    });

    test('logAdminAction fires admin_action event', () async {
      await service.logAdminAction(action: 'ban', targetType: 'user');
      expect(fakeAnalytics.events, contains('admin_action'));
    });

    test('logCreatorProfileViewed fires view_item event', () async {
      await service.logCreatorProfileViewed(creatorId: 'c-1');
      expect(fakeAnalytics.events, contains('view_item'));
    });
  });
}
