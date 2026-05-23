import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_bloc_observer/talker_bloc_observer.dart';
import 'package:vibyuk/app.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/di/injection_container.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/firebase_options_staging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig.initialize(AppFlavor.staging);
  AppLogger.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = (details) {
    AppLogger.error('Flutter error', error: details.exception, stackTrace: details.stack);
    FlutterError.presentError(details);
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  Bloc.observer = TalkerBlocObserver(talker: AppLogger.talker);

  await configureDependencies();

  runApp(const VibyukApp());
}
