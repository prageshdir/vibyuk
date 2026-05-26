import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibyuk/core/cache/cache_manager.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/di/injection_container.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/services/crash_reporting_service.dart';
import 'package:vibyuk/core/services/performance_service.dart';

/// Orchestrates the entire app startup sequence in prioritised stages.
/// Stage 1 (critical, synchronous): binding + flavor + logger
/// Stage 2 (critical, async): DI + Firebase
/// Stage 3 (non-critical, deferred): cache eviction + secondary services
class AppStartupService {
  AppStartupService._();

  static final AppStartupService instance = AppStartupService._();

  bool _initialized = false;

  Future<void> initialize({
    required AppFlavor flavor,
    FirebaseOptions? firebaseOptions,
  }) async {
    if (_initialized) return;

    final stopwatch = Stopwatch()..start();

    // ── Stage 1: Synchronous critical init ────────────────────────────────
    WidgetsFlutterBinding.ensureInitialized();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    FlavorConfig.initialize(flavor);
    AppLogger.initialize();

    AppLogger.info('AppStartup: Stage 1 complete (${stopwatch.elapsedMilliseconds}ms)');

    // ── Stage 2: Async critical init ──────────────────────────────────────
    await Firebase.initializeApp(
      options: firebaseOptions,
    );

    _setupErrorHandlers();

    await configureDependencies();

    AppLogger.info('AppStartup: Stage 2 complete (${stopwatch.elapsedMilliseconds}ms)');

    // ── Stage 3: Non-critical deferred init ───────────────────────────────
    unawaited(_deferredInit());

    _initialized = true;
    stopwatch.stop();
    AppLogger.info('AppStartup: total init time ${stopwatch.elapsedMilliseconds}ms');

    if (sl.isRegistered<PerformanceService>()) {
      sl<PerformanceService>().finishStartupTrace();
    }
  }

  void _setupErrorHandlers() {
    FlutterError.onError = (details) {
      AppLogger.error(
        'Flutter error: ${details.exceptionAsString()}',
        error: details.exception,
        stackTrace: details.stack,
      );
      if (FlavorConfig.instance.enableCrashlytics && !kDebugMode) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      } else {
        FlutterError.presentError(details);
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.critical('Dart error', error: error, stackTrace: stack);
      if (FlavorConfig.instance.enableCrashlytics && !kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
      return true;
    };
  }

  Future<void> _deferredInit() async {
    // Delay 2s so first frame is not blocked
    await Future<void>.delayed(const Duration(seconds: 2));

    try {
      if (sl.isRegistered<CacheManager>()) {
        await sl<CacheManager>().evictExpired();
        AppLogger.debug('AppStartup: cache eviction complete');
      }

      if (FlavorConfig.instance.enablePerformanceMonitoring) {
        await FirebasePerformance.instance
            .setPerformanceCollectionEnabled(true);
      }

      if (sl.isRegistered<CrashReportingService>()) {
        await sl<CrashReportingService>().setAppContext(
          flavor: FlavorConfig.instance.name,
          appVersion: '1.0.0',
        );
      }
    } catch (e, st) {
      AppLogger.warning(
        'AppStartup: deferred init error (non-critical)',
        error: e,
        stackTrace: st,
      );
    }
  }
}
