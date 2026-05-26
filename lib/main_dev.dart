import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/app.dart';
import 'package:vibyuk/core/config/flavor_config.dart';
import 'package:vibyuk/core/di/injection_container.dart';
import 'package:vibyuk/core/observers/app_bloc_observer.dart';
import 'package:vibyuk/core/services/crash_reporting_service.dart';
import 'package:vibyuk/core/startup/app_startup_service.dart';

Future<void> main() async {
  await AppStartupService.instance.initialize(flavor: AppFlavor.dev);

  // Wire AppBlocObserver only after DI is configured
  Bloc.observer = sl<AppBlocObserver>();

  runApp(const VibyukApp());
}
