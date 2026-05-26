import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/services/crash_reporting_service.dart';

// ── Fake FirebaseCrashlytics ──────────────────────────────────────────────────

class _FakeCrashlytics extends Fake implements FirebaseCrashlytics {
  bool collectionEnabled = false;
  String? userIdentifier;
  final List<String> logs = [];
  final List<Object> recordedErrors = [];
  final Map<String, String> customKeys = {};

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    collectionEnabled = enabled;
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    userIdentifier = identifier;
  }

  @override
  Future<void> log(String message) async {
    logs.add(message);
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<DiagnosticsNode> information = const [],
    bool? printDetails,
    bool fatal = false,
  }) async {
    recordedErrors.add(exception as Object);
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    customKeys[key] = value.toString();
  }
}

void main() {
  late _FakeCrashlytics fakeCrashlytics;
  late CrashReportingService service;

  // In test environment kDebugMode = true, so _enabled is always false.
  // These tests verify no-op behavior and the AppLogger path.

  group('CrashReportingService — debug mode (always no-op)', () {
    setUp(() {
      FlavorConfig.initialize(AppFlavor.production);
      fakeCrashlytics = _FakeCrashlytics();
      service = CrashReportingService(fakeCrashlytics);
    });

    tearDown(() => FlavorConfig.initialize(AppFlavor.dev));

    test('initialize does not enable collection in debug mode', () async {
      await service.initialize(userId: 'u-1');
      expect(fakeCrashlytics.collectionEnabled, isFalse);
      expect(fakeCrashlytics.userIdentifier, isNull);
    });

    test('setUserId is a no-op in debug mode', () async {
      await service.setUserId('u-2');
      expect(fakeCrashlytics.userIdentifier, isNull);
    });

    test('recordError does not call Firebase in debug mode', () async {
      await service.recordError(Exception('test'), null);
      expect(fakeCrashlytics.recordedErrors, isEmpty);
    });

    test('addBreadcrumb does not call Firebase.log in debug mode', () async {
      await service.addBreadcrumb('user tapped button', category: 'ui');
      expect(fakeCrashlytics.logs, isEmpty);
    });

    test('setCustomKey is a no-op in debug mode', () async {
      await service.setCustomKey('env', 'production');
      expect(fakeCrashlytics.customKeys, isEmpty);
    });

    test('setAppContext is a no-op in debug mode', () async {
      await service.setAppContext(flavor: 'production', appVersion: '1.0.0');
      expect(fakeCrashlytics.customKeys, isEmpty);
    });

    test('does not throw on any call', () async {
      expect(
        () async {
          await service.initialize(userId: 'u-3');
          await service.recordError(Exception('oops'), StackTrace.current);
          await service.recordFailure(const ServerFailure(message: 'bad'));
          await service.addBreadcrumb('nav');
          await service.addRouteBreadcrumb('/home');
          await service.addActionBreadcrumb('tap_button', screen: 'HomeScreen');
          await service.setUserId('u-3');
          await service.setAppContext(flavor: 'production', appVersion: '2.0.0');
        },
        returnsNormally,
      );
    });
  });

  group('CrashReportingService — dev flavor', () {
    setUp(() {
      FlavorConfig.initialize(AppFlavor.dev);
      fakeCrashlytics = _FakeCrashlytics();
      service = CrashReportingService(fakeCrashlytics);
    });

    test('recordError is always a no-op in dev (disabled via flavor)', () async {
      await service.recordError(Exception('dev error'), null);
      expect(fakeCrashlytics.recordedErrors, isEmpty);
    });

    test('recordFailure is a no-op in dev', () async {
      await service.recordFailure(
        const AuthFailure(message: 'Unauthorized'),
        stack: StackTrace.current,
      );
      expect(fakeCrashlytics.recordedErrors, isEmpty);
    });
  });
}
