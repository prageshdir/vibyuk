import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/app.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/di/injection_container.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/firebase_options_production.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig.initialize(AppFlavor.production);
  AppLogger.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Production: route all errors to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

  // No BLoC observer in production — reduces overhead
  await configureDependencies();

  runApp(const VibyukApp());
}
